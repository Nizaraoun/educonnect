// filepath: c:\Users\nizar\Desktop\Nour\educonnect\lib\features\chat\controller\ChatController.dart
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../model/chat_message_model.dart';

class ChatController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Observable variables
  final RxList<ChatMessageModel> messages = <ChatMessageModel>[].obs;
  final RxList<ForumModel> forums = <ForumModel>[].obs;
  final Rx<ForumModel?> currentForum = Rx<ForumModel?>(null);
  final RxMap<String, String> lastMessages =
      <String, String>{}.obs; // Store last message for each forum
  final RxMap<String, DateTime> lastMessageTimes =
      <String, DateTime>{}.obs; // Store last message time
  final RxBool isLoading = false.obs;

  // Stream subscription for real-time message updates
  StreamSubscription<QuerySnapshot>? _messagesSubscription;
  StreamSubscription<QuerySnapshot>? _forumsSubscription;

  @override
  void onInit() {
    super.onInit();
    // Load forums when controller is initialized
    loadUserForums();
  }

  @override
  void onClose() {
    // Cancel subscriptions when controller is closed
    _messagesSubscription?.cancel();
    _forumsSubscription?.cancel();
    super.onClose();
  }

  // Load all forums the user is a member of
  Future<void> loadUserForums() async {
    // Don't set loading if we're already loading
    if (isLoading.value) return;

    isLoading.value = true;
    try {
      final userId = _auth.currentUser?.uid;

      if (userId == null) {
        isLoading.value = false;
        return;
      }

      // Set up a real-time listener for forums
      _forumsSubscription?.cancel();

      // First get the initial data
      final QuerySnapshot snapshot = await _firestore
          .collection('forums')
          .where('memberIds', arrayContains: userId)
          .get();

      final loadedForums =
          snapshot.docs.map((doc) => ForumModel.fromFirestore(doc)).toList();

      forums.value = loadedForums;

      // Load last message for each forum
      for (var forum in loadedForums) {
        await _loadLastMessage(forum.id);
      }

      // Now set up the listener for future changes
      _forumsSubscription = _firestore
          .collection('forums')
          .where('memberIds', arrayContains: userId)
          .snapshots()
          .listen((snapshot) {
        final updatedForums =
            snapshot.docs.map((doc) => ForumModel.fromFirestore(doc)).toList();

        forums.value = updatedForums;

        // Also update last messages
        for (var forum in updatedForums) {
          _loadLastMessage(forum.id);
        }
      }, onError: (error) {
        print("Error in forums stream: $error");
      });
    } catch (e) {
      print("Error loading forums: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Load the last message for a forum
  Future<void> _loadLastMessage(String forumId) async {
    try {
      final messages = await _firestore
          .collection('messages')
          .where('groupId', isEqualTo: forumId)
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (messages.docs.isNotEmpty) {
        final lastMessage = ChatMessageModel.fromFirestore(messages.docs.first);
        lastMessages[forumId] = lastMessage.message;
        lastMessageTimes[forumId] = lastMessage.timestamp;
      } else {
        lastMessages[forumId] = "Pas de messages";
        // Use forum creation time as fallback for lastMessageTime
        final forumDoc =
            await _firestore.collection('forums').doc(forumId).get();
        if (forumDoc.exists) {
          final forum = ForumModel.fromFirestore(forumDoc);
          lastMessageTimes[forumId] = forum.createdAt;
        }
      }
    } catch (e) {
      print("Error loading last message: $e");
      lastMessages[forumId] = "Erreur de chargement";
    }
  }

  // Load and subscribe to messages for a specific forum
  Future<void> loadForumMessages(String forumId) async {
    try {
      isLoading.value = true;
      messages.clear();

      // Cancel any existing subscription
      _messagesSubscription?.cancel();

      // Get forum details
      final forumDoc = await _firestore.collection('forums').doc(forumId).get();

      if (forumDoc.exists) {
        currentForum.value = ForumModel.fromFirestore(forumDoc);

        // Set up real-time listener for messages
        _messagesSubscription = _firestore
            .collection('messages')
            .where('groupId', isEqualTo: forumId)
            .orderBy('timestamp', descending: true)
            .limit(100) // Increased limit for better history
            .snapshots()
            .listen((snapshot) {
          final loadedMessages = snapshot.docs
              .map((doc) => ChatMessageModel.fromFirestore(doc))
              .toList();

          messages.value = loadedMessages;
          isLoading.value = false;
        }, onError: (error) {
          print("Error in messages stream: $error");
          isLoading.value = false;
        });
      } else {
        isLoading.value = false;
      }
    } catch (e) {
      print("Error loading forum messages: $e");
      isLoading.value = false;
    }
  }

  // Send a message to a forum
  Future<bool> sendMessage({
    required String forumId,
    required String message,
    String? attachment,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      // Get user name from Firestore
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      String senderName = 'Utilisateur';

      if (userDoc.exists) {
        final userData = userDoc.data();
        if (userData != null) {
          final firstName = userData['firstName'] ?? '';
          final lastName = userData['lastName'] ?? '';
          senderName = '$firstName $lastName'.trim();
          if (senderName.isEmpty)
            senderName = userData['fullName'] ?? 'Utilisateur';
        }
      }

      // Create a new message document
      final messageId = _firestore.collection('messages').doc().id;

      // Current timestamp
      final timestamp = DateTime.now();
      final newMessage = ChatMessageModel(
        id: messageId,
        groupId: forumId,
        senderId: user.uid,
        senderName: senderName,
        message: message,
        timestamp: timestamp,
        attachment: attachment,
      );

      // Add message to local list immediately for instant UI update
      // Since our list is sorted in descending order by timestamp, add it at the beginning
      messages.insert(0, newMessage);

      // Save to Firestore
      await _firestore
          .collection('messages')
          .doc(messageId)
          .set(newMessage.toJson());

      // Save a copy to 'chats' collection with simplified structure for easier access
      await _firestore.collection('chats').add({
        'senderName': senderName,
        'message': message,
        'timestamp': Timestamp.fromDate(timestamp),
        'forumId': forumId,
        'senderId': user.uid,
      });

      // Update forum's last activity
      await _firestore.collection('forums').doc(forumId).update({
        'lastActivity': FieldValue.serverTimestamp(),
        'lastMessage': message,
        'lastMessageSender': senderName,
        'lastMessageTime': Timestamp.fromDate(timestamp),
      });

      // Update the last message for this forum in our local state
      lastMessages[forumId] = message;
      lastMessageTimes[forumId] = timestamp;

      return true;
    } catch (e) {
      print("Error sending message: $e");
      return false;
    }
  }

  // Create a new forum for a group
  Future<String> createForum({
    required String groupId,
    required String groupName,
    required List<String> memberIds,
  }) async {
    try {
      // Create a new forum using the group's ID
      final forum = ForumModel(
        id: groupId,
        groupName: groupName,
        memberIds: memberIds,
        createdAt: DateTime.now(),
      );

      // Save to Firestore
      await _firestore.collection('forums').doc(groupId).set(forum.toJson());

      return groupId;
    } catch (e) {
      print("Error creating forum: $e");
      return '';
    }
  }

  // Make sure we reload the data when the controller is put back on top
  void refreshData() {
    // Cancel any existing subscriptions to avoid duplication
    _forumsSubscription?.cancel();
    _forumsSubscription = null;

    // Clean state and reload
    forums.clear();
    lastMessages.clear();
    lastMessageTimes.clear();
    loadUserForums();
  }
}
