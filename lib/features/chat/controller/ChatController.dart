import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../model/chat_message_model.dart';

class ChatController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Observable variables  final RxBool isLoading = false.obs;
  final RxList<ChatMessageModel> messages = <ChatMessageModel>[].obs;
  final RxList<ForumModel> forums = <ForumModel>[].obs;
  final Rx<ForumModel?> currentForum = Rx<ForumModel?>(null);
  final RxMap<String, String> lastMessages =
      <String, String>{}.obs; // Store last message for each forum
  final RxMap<String, DateTime> lastMessageTimes =
      <String, DateTime>{}.obs; // Store last message time
  final RxBool isLoading = false.obs;
  // Load all forums the user is a member of
  Future<void> loadUserForums() async {
    isLoading.value = true;
    try {
      final userId = _auth.currentUser?.uid;

      if (userId == null) {
        isLoading.value = false;
        return;
      }

      // Query forums where user is a member
      final QuerySnapshot snapshot = await _firestore
          .collection('forums')
          .where('memberIds', arrayContains: userId)
          .get();

      final loadedForums =
          snapshot.docs.map((doc) => ForumModel.fromFirestore(doc)).toList();

      forums.value = loadedForums;

      // Load last message for each forum
      for (var forum in loadedForums) {
        _loadLastMessage(forum.id);
      }
    } catch (e) {
      print("Error loading forums: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Load the last message for a forum
  // Removed duplicate _loadLastMessage method to resolve the naming conflict.

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
      } else {
        lastMessages[forumId] = "Pas de messages";
      }
    } catch (e) {
      print("Error loading last message: $e");
      lastMessages[forumId] = "Erreur de chargement";
    }
  }

  // Stream subscription for real-time message updates
  StreamSubscription<QuerySnapshot>? _messagesSubscription;

  @override
  void onClose() {
    // Cancel subscription when controller is closed
    _messagesSubscription?.cancel();
    super.onClose();
  }

  // Load and subscribe to messages for a specific forum
  Future<void> loadForumMessages(String forumId) async {
    isLoading.value = true;
    messages.clear();

    // Cancel any existing subscription
    _messagesSubscription?.cancel();

    try {
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
}
