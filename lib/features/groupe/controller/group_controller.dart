import 'package:educonnect/features/groupe/model/group_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';

import '../../../core/utils/localData.dart';
import '../model/Announcement_model.dart' as announcement_model;
import '../../chat/controller/ChatController.dart';

class GroupController extends GetxController {
  // Observable variables
  final RxBool isLoading = false.obs;
  final RxList<GroupModel> groups = <GroupModel>[].obs;
  final RxList<GroupModel> myGroups = <GroupModel>[].obs;
  final RxList<RevisionGroupModel> revisionGroups = <RevisionGroupModel>[].obs;
  final RxString selectedCategory = 'Tous'.obs;
  final RxBool isSearching = false.obs;
  final RxString searchQuery = ''.obs;
  final RxList<GroupAnnouncementModel> announcements =
      <GroupAnnouncementModel>[].obs;
  final RxBool isInGroup = false.obs;
  final Rx<GroupModel?> currentGroup = Rx<GroupModel?>(null);
  final RxBool isLoadingAnnouncements = false.obs;
  final RxBool isCreating = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadGroups();
    loadMyGroups();
  }

  // Load all groups from Firebase
  void loadGroups() async {
    isLoading.value = true;
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;

      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('groups')
          .orderBy('createdAt', descending: true)
          .get();

      final List<GroupModel> loadedGroups = snapshot.docs.map((doc) {
        return GroupModel.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();

      // Filter out private groups where the user is not a member
      if (userId != null) {
        groups.value = loadedGroups
            .where(
                (group) => group.isPublic || group.memberIds.contains(userId))
            .toList();
      } else {
        // If no user is logged in, only show public groups
        groups.value = loadedGroups.where((group) => group.isPublic).toList();
      }
    } catch (e) {
      print("Error loading groups: $e");
      Get.snackbar(
        'Erreur',
        'Impossible de charger les groupes',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Load groups the user is a member of
  void loadMyGroups() async {
    isLoading.value = true;
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        isLoading.value = false;
        return;
      }

      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('groups')
          .where('memberIds', arrayContains: user.uid)
          .get();

      final loadedGroups = snapshot.docs.map((doc) {
        return GroupModel.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();

      myGroups.value = loadedGroups;
    } catch (e) {
      print("Error loading my groups: $e");
      Get.snackbar(
        'Erreur',
        'Impossible de charger vos groupes',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Filter groups by category
  void filterByCategory(String category) async {
    selectedCategory.value = category;
    isLoading.value = true;

    try {
      // Filter groups based on category
      if (category == 'Tous') {
        loadGroups(); // Already implemented with Firebase
      } else {
        // Use Firestore query to filter by category
        final QuerySnapshot snapshot = await FirebaseFirestore.instance
            .collection('groups')
            .where('category', isEqualTo: category)
            .orderBy('createdAt', descending: true)
            .get();

        final loadedGroups = snapshot.docs.map((doc) {
          return GroupModel.fromJson(doc.data() as Map<String, dynamic>);
        }).toList();

        groups.value = loadedGroups;
      }
    } catch (e) {
      print("Error filtering groups by category: $e");
      Get.snackbar(
        'Erreur',
        'Impossible de filtrer les groupes',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Search for groups by name
  void searchGroups(String query) async {
    searchQuery.value = query;

    if (query.isEmpty) {
      loadGroups();
      isSearching.value = false;
      return;
    }

    isSearching.value = true;
    isLoading.value = true;

    try {
      // Use Firestore to search for groups
      // Note: Firestore doesn't support native full-text search, so we're doing a simple
      // query using array-contains or beginning-of-string matches

      // Convert query to lowercase for case-insensitive search
      final lowercaseQuery = query.toLowerCase();

      // Get all groups (this is not efficient for large databases,
      // but Firestore doesn't support full text search without additional services)
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('groups')
          .orderBy('name')
          .get();

      // Filter results client-side
      final loadedGroups = snapshot.docs
          .map((doc) => GroupModel.fromJson(doc.data() as Map<String, dynamic>))
          .where((group) =>
              group.name.toLowerCase().contains(lowercaseQuery) ||
              group.description.toLowerCase().contains(lowercaseQuery))
          .toList();

      groups.value = loadedGroups;
    } catch (e) {
      print("Error searching groups: $e");
      Get.snackbar(
        'Erreur',
        'Une erreur est survenue lors de la recherche de groupes',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Join a group
  void joinGroup(String groupId) async {
    isLoading.value = true;
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;

      if (userId == null) {
        Get.snackbar(
          'Erreur',
          'Vous devez être connecté pour rejoindre un groupe',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.7),
          colorText: Colors.white,
        );
        return;
      }

      // Get the group document reference
      final groupRef =
          FirebaseFirestore.instance.collection('groups').doc(groupId);

      // Get the current group data
      final groupDoc = await groupRef.get();
      if (!groupDoc.exists) {
        Get.snackbar(
          'Erreur',
          'Ce groupe n\'existe plus',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.7),
          colorText: Colors.white,
        );
        return;
      }

      final groupData = groupDoc.data() as Map<String, dynamic>;
      final List<dynamic> memberIds = groupData['memberIds'] ?? [];

      // Check if user is already a member
      if (memberIds.contains(userId)) {
        Get.snackbar(
          'Information',
          'Vous êtes déjà membre de ce groupe',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      } // Update the group document with the new member
      await groupRef.update({
        'memberIds': FieldValue.arrayUnion([userId]),
        'memberCount': FieldValue.increment(1),
        'lastActivity': FieldValue.serverTimestamp(),
      });

      // If the group has chat enabled, add the user to the forum
      if (groupData['hasChat'] == true) {
        try {
          final chatController = Get.find<ChatController>();

          // Update forum's member list
          await FirebaseFirestore.instance
              .collection('forums')
              .doc(groupId)
              .update({
            'memberIds': FieldValue.arrayUnion([userId]),
          });
        } catch (e) {
          print("Error adding user to forum: $e");
          // Continue even if forum update fails
        }
      }

      Get.snackbar(
        'Groupe rejoint',
        'Vous avez rejoint le groupe avec succès',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.7),
        colorText: Colors.white,
      );

      // Refresh groups
      loadGroups();
      loadMyGroups();
    } catch (e) {
      print("Error joining group: $e");
      Get.snackbar(
        'Erreur',
        'Une erreur est survenue lors de la tentative de rejoindre le groupe',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Leave a group
  void leaveGroup(String groupId) async {
    isLoading.value = true;
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;

      if (userId == null) {
        Get.snackbar(
          'Erreur',
          'Vous devez être connecté pour quitter un groupe',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.7),
          colorText: Colors.white,
        );
        return;
      }

      // Get the group document reference
      final groupRef =
          FirebaseFirestore.instance.collection('groups').doc(groupId);

      // Get the current group data
      final groupDoc = await groupRef.get();
      if (!groupDoc.exists) {
        Get.snackbar(
          'Erreur',
          'Ce groupe n\'existe plus',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.7),
          colorText: Colors.white,
        );
        return;
      }

      final groupData = groupDoc.data() as Map<String, dynamic>;
      final List<dynamic> memberIds = groupData['memberIds'] ?? [];
      final List<dynamic> adminIds = groupData['adminIds'] ?? [];
      final String creatorId = groupData['creatorId'] ?? '';

      // Check if user is a member
      if (!memberIds.contains(userId)) {
        Get.snackbar(
          'Information',
          'Vous n\'êtes pas membre de ce groupe',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // Check if user is the creator and prevent leaving if they are the only admin
      if (userId == creatorId && adminIds.length <= 1) {
        Get.snackbar(
          'Action impossible',
          'En tant que créateur, vous ne pouvez pas quitter le groupe. Vous devez d\'abord désigner un autre administrateur ou supprimer le groupe.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.withOpacity(0.7),
          colorText: Colors.white,
        );
        return;
      } // Update the group document to remove the user
      await groupRef.update({
        'memberIds': FieldValue.arrayRemove([userId]),
        'adminIds': FieldValue.arrayRemove([userId]),
        'memberCount': FieldValue.increment(-1),
        'lastActivity': FieldValue.serverTimestamp(),
      });

      // If the group has chat enabled, remove the user from the forum
      if (groupData['hasChat'] == true) {
        try {
          // Update forum's member list to remove the user
          await FirebaseFirestore.instance
              .collection('forums')
              .doc(groupId)
              .update({
            'memberIds': FieldValue.arrayRemove([userId]),
          });
          print("User removed from forum successfully");
        } catch (e) {
          print("Error removing user from forum: $e");
          // Continue even if forum update fails
        }
      }

      Get.snackbar(
        'Groupe quitté',
        'Vous avez quitté le groupe',
        snackPosition: SnackPosition.BOTTOM,
      );

      // Refresh groups
      loadGroups();
      loadMyGroups();
    } catch (e) {
      print("Error leaving group: $e");
      Get.snackbar(
        'Erreur',
        'Une erreur est survenue lors de la tentative de quitter le groupe',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Create a new group
  void createGroup({
    required String name,
    required String description,
    required String category,
    String imageUrl = '',
    required bool isPublic,
    bool hasChat = true,
  }) async {
    isLoading.value = true;
    try {
      // Get current user info from local storage
      final userData = await LocalData.getUserData();
      final userId = FirebaseAuth.instance.currentUser?.uid;

      if (userId == null) {
        Get.snackbar(
          'Erreur',
          'Vous devez être connecté pour créer un groupe',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.7),
          colorText: Colors.white,
        );
        isLoading.value = false;
        return;
      }

      // Generate a unique invitation code (6 alphanumeric characters)
      final invitationCode = _generateInvitationCode();

      // Create a new document in Firestore
      final groupId = const Uuid().v4();
      final groupData = {
        'id': groupId,
        'name': name,
        'description': description,
        'imageUrl': imageUrl,
        'category': category,
        'creatorId': userId,
        'creatorName':
            userData['firstName'] + ' ' + userData['lastName'] ?? 'Utilisateur',
        'memberIds': [userId],
        'adminIds': [userId],
        'memberCount': 1,
        'createdAt': FieldValue.serverTimestamp(),
        'lastActivity': FieldValue.serverTimestamp(),
        'isPublic': isPublic,
        'hasChat': hasChat,
        'invitationCode': invitationCode,
      };

      // Add to Firestore
      await FirebaseFirestore.instance
          .collection('groups')
          .doc(groupId)
          .set(groupData);

      // Create a new GroupModel
      final newGroup = GroupModel(
        id: groupId,
        name: name,
        description: description,
        imageUrl: imageUrl,
        category: category,
        creatorId: userId,
        creatorName:
            userData['firstName'] + ' ' + userData['lastName'] ?? 'Utilisateur',
        memberIds: [userId],
        adminIds: [userId],
        memberCount: 1,
        createdAt: DateTime.now(),
        lastActivity: DateTime.now(),
        isPublic: isPublic,
        hasChat: hasChat,
        invitationCode: invitationCode,
      );
      print("New group created: $newGroup");

      // Create a chat forum for the group if chat is enabled
      if (hasChat) {
        try {
          // Create an instance of ChatController to use createForum method
          final chatController = Get.find<ChatController>();

          // Create a forum for this group
          await chatController.createForum(
            groupId: groupId,
            groupName: name,
            memberIds: [userId],
          );
          print("Forum created for group: $groupId");
        } catch (e) {
          // If ChatController is not registered yet, create it
          try {
            final chatController = Get.put(ChatController());
            await chatController.createForum(
              groupId: groupId,
              groupName: name,
              memberIds: [userId],
            );
            print("Forum created for group: $groupId");
          } catch (e) {
            print("Error creating forum: $e");
            // Continue even if forum creation fails
          }
        }
      }

      // Add to local lists
      groups.add(newGroup);
      myGroups.add(newGroup);
      Get.back();

      Get.snackbar(
        'Groupe créé',
        'Votre groupe a été créé avec succès',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.7),
        colorText: Colors.white,
      );

      // Navigate back to groups list
    } catch (e) {
      print("Error creating group: $e");
      Get.snackbar(
        'Erreur',
        'Une erreur est survenue lors de la création du groupe',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Open a specific group and load its details
  void openGroup(String groupId) async {
    isLoading.value = true;
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;

      // Get the group document
      final groupDoc = await FirebaseFirestore.instance
          .collection('groups')
          .doc(groupId)
          .get();

      if (!groupDoc.exists) {
        Get.snackbar(
          'Erreur',
          'Ce groupe n\'existe plus',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.7),
          colorText: Colors.white,
        );
        return;
      }

      // Parse the group data
      final group =
          GroupModel.fromJson(groupDoc.data() as Map<String, dynamic>);
      currentGroup.value = group;

      // Check if user is a member
      isInGroup.value = userId != null && group.memberIds.contains(userId);

      // Load group announcements
      loadGroupAnnouncements(groupId);

      // Load revision groups if user is a member
      if (isInGroup.value) {
        loadRevisionGroups(groupId);
      }
    } catch (e) {
      print("Error opening group: $e");
      Get.snackbar(
        'Erreur',
        'Une erreur est survenue lors de l\'ouverture du groupe',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Load revision groups for a parent group
  void loadRevisionGroups(String parentGroupId) async {
    isLoading.value = true;

    try {
      // Modified query to not use ordering which requires composite index
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('revisionGroups')
          .where('parentGroupId', isEqualTo: parentGroupId)
          // Removing the orderBy since it requires a composite index
          // .orderBy('meetingDate')
          .get();

      final loadedRevisionGroups = snapshot.docs.map((doc) {
        return RevisionGroupModel.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();

      // Sort the results client-side instead
      loadedRevisionGroups
          .sort((a, b) => a.meetingDate.compareTo(b.meetingDate));

      revisionGroups.value = loadedRevisionGroups;
    } catch (e) {
      print("Error loading revision groups: $e");

      // Check if it's a missing index error
      if (e.toString().contains("FAILED_PRECONDITION") &&
          e.toString().contains("requires an index")) {
        // Extract the index creation URL
        final indexUrlRegex =
            RegExp(r'https://console\.firebase\.google\.com[^\s,]+');
        final match = indexUrlRegex.firstMatch(e.toString());
        final indexUrl = match?.group(0) ?? '';

        Get.snackbar(
          'Index manquant',
          'Cette requête nécessite un index dans Firebase. ${indexUrl.isNotEmpty ? 'Créez-le en visitant le lien affiché dans la console.' : ''}',
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 7),
          backgroundColor: Colors.orange.withOpacity(0.7),
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Erreur',
          'Impossible de charger les groupes de révision',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.7),
          colorText: Colors.white,
        );
      }
      // Fallback to empty list
      revisionGroups.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  // Load announcements for a specific group from Firebase
  Future<void> loadAnnouncements(String groupId) async {
    isLoadingAnnouncements.value = true;
    announcements.clear();

    try {
      // Query announcements for this group from Firestore
      final QuerySnapshot announcementsSnapshot = await FirebaseFirestore
          .instance
          .collection('announcements')
          .where('groupId', isEqualTo: groupId)
          .orderBy('createdAt', descending: true)
          .get();

      if (announcementsSnapshot.docs.isEmpty) {
        isLoadingAnnouncements.value = false;
        return;
      }

      // Convert Firestore documents to Announcement objects
      final List<announcement_model.GroupAnnouncementModel>
          loadedAnnouncements = announcementsSnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return announcement_model.GroupAnnouncementModel(
          id: data['id'] ?? doc.id,
          groupId: data['groupId'] ?? '',
          title: data['title'] ?? '',
          content: data['content'] ?? '',
          authorId: data['authorId'] ?? '',
          authorName: data['authorName'] ?? 'Utilisateur',
          createdAt:
              (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          attachments: List<String>.from(data['attachments'] ?? []),
        );
      }).toList();

      // Update the announcements list with the loaded data
      announcements
          .assignAll(loadedAnnouncements as Iterable<GroupAnnouncementModel>);
    } catch (e) {
      print("Error loading announcements: $e");
      Get.snackbar(
        'Erreur',
        'Impossible de charger les annonces',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
      );
    } finally {
      isLoadingAnnouncements.value = false;
    }
  }

  // Load announcements for a specific group
  void loadGroupAnnouncements(String groupId) async {
    isLoadingAnnouncements.value = true;
    try {
      // Modified query to not use ordering which requires composite index
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('groupAnnouncements')
          .where('groupId', isEqualTo: groupId)
          // Removing the orderBy since it requires a composite index
          // .orderBy('createdAt', descending: true)
          .get();

      final loadedAnnouncements = snapshot.docs.map((doc) {
        return GroupAnnouncementModel.fromJson(
            doc.data() as Map<String, dynamic>);
      }).toList();

      // Sort the results client-side instead
      loadedAnnouncements.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      announcements.value = loadedAnnouncements;
    } catch (e) {
      print("Error loading announcements: $e");

      // Check if it's a missing index error
      if (e.toString().contains("FAILED_PRECONDITION") &&
          e.toString().contains("requires an index")) {
        // Extract the index creation URL
        final indexUrlRegex =
            RegExp(r'https://console\.firebase\.google\.com[^\s,]+');
        final match = indexUrlRegex.firstMatch(e.toString());
        final indexUrl = match?.group(0) ?? '';

        Get.snackbar(
          'Index manquant',
          'Cette requête nécessite un index dans Firebase. ${indexUrl.isNotEmpty ? 'Créez-le en visitant le lien affiché dans la console.' : ''}',
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 7),
          backgroundColor: Colors.orange.withOpacity(0.7),
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Erreur',
          'Impossible de charger les annonces',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.7),
          colorText: Colors.white,
        );
      }
    } finally {
      isLoadingAnnouncements.value = false;
    }
  }

  // Create a revision group with Firebase integration
  void createRevisionGroup({
    required String parentGroupId,
    required String name,
    required String description,
    required String subject,
    required DateTime meetingDate,
    required String meetingTime,
    required String meetingLocation,
  }) async {
    isLoading.value = true;

    try {
      // Get current user info
      final user = FirebaseAuth.instance.currentUser;
      final userData = await LocalData.getUserData();

      if (user == null) {
        Get.snackbar(
          'Erreur',
          'Vous devez être connecté pour créer un groupe de révision',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.7),
          colorText: Colors.white,
        );
        return;
      }

      // Create a new revision group ID
      final revisionGroupId = const Uuid().v4();

      // Get user name from userData
      final userName =
          '${userData['firstName'] ?? ''} ${userData['lastName'] ?? ''}';

      // Create the revision group document
      final revisionGroupData = {
        'id': revisionGroupId,
        'parentGroupId': parentGroupId,
        'name': name,
        'description': description,
        'subject': subject,
        'creatorId': user.uid,
        'creatorName': userName.trim().isNotEmpty
            ? userName
            : user.displayName ?? 'Utilisateur',
        'memberIds': [user.uid],
        'createdAt': FieldValue.serverTimestamp(),
        'meetingDate': meetingDate,
        'meetingTime': meetingTime,
        'meetingLocation': meetingLocation,
        'memberCount': 1,
      };

      // Add to Firestore
      await FirebaseFirestore.instance
          .collection('revisionGroups')
          .doc(revisionGroupId)
          .set(revisionGroupData);

      // Update the parent group with last activity timestamp
      await FirebaseFirestore.instance
          .collection('groups')
          .doc(parentGroupId)
          .update({
        'lastActivity': FieldValue.serverTimestamp(),
      });

      // Create a new RevisionGroupModel for local state
      final newRevisionGroup = RevisionGroupModel(
        id: revisionGroupId,
        parentGroupId: parentGroupId,
        name: name,
        description: description,
        subject: subject,
        creatorId: user.uid,
        creatorName: userName.trim().isNotEmpty
            ? userName
            : user.displayName ?? 'Utilisateur',
        memberIds: [user.uid],
        createdAt: DateTime.now(),
        meetingDate: meetingDate,
        meetingTime: meetingTime,
        meetingLocation: meetingLocation,
        memberCount: 1,
      );

      // Add to local list
      revisionGroups.add(newRevisionGroup);

      Get.snackbar(
        'Groupe de révision créé',
        'Votre groupe de révision a été créé avec succès',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.7),
        colorText: Colors.white,
      );

      // Navigate back
      Get.back();
    } catch (e) {
      print("Error creating revision group: $e");
      Get.snackbar(
        'Erreur',
        'Une erreur est survenue lors de la création du groupe de révision',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Create a revision group (study session)
  Future<bool> createStudySession({
    required String parentGroupId,
    required String name,
    required String description,
    required String subject,
    required DateTime meetingDate,
    required String meetingTime,
    required String meetingLocation,
    int maxMembers = 20, // Added maxMembers parameter with default value of 20
  }) async {
    isCreating.value = true;
    try {
      // Get current user info
      final userData = await LocalData.getUserData();
      final userId = FirebaseAuth.instance.currentUser?.uid;

      if (userId == null) {
        Get.snackbar(
          'Erreur',
          'Vous devez être connecté pour créer une session d\'étude',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.7),
          colorText: Colors.white,
        );
        return false;
      }

      // Check if parent group exists
      final parentGroupDoc = await FirebaseFirestore.instance
          .collection('groups')
          .doc(parentGroupId)
          .get();

      if (!parentGroupDoc.exists) {
        Get.snackbar(
          'Erreur',
          'Le groupe parent n\'existe pas',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.7),
          colorText: Colors.white,
        );
        return false;
      }

      // Check if user is a member of the parent group
      final parentGroupData = parentGroupDoc.data() as Map<String, dynamic>;
      final List<dynamic> memberIds = parentGroupData['memberIds'] ?? [];

      if (!memberIds.contains(userId)) {
        Get.snackbar(
          'Erreur',
          'Vous devez être membre du groupe parent pour créer une session d\'étude',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.7),
          colorText: Colors.white,
        );
        return false;
      }

      // Generate unique ID for the revision group
      final String revisionGroupId = const Uuid().v4();

      // Create revision group model
      final revisionGroup = RevisionGroupModel(
        id: revisionGroupId,
        parentGroupId: parentGroupId,
        name: name,
        description: description,
        subject: subject,
        creatorId: userId,
        creatorName:
            '${userData['firstName'] ?? ''} ${userData['lastName'] ?? ''}'
                    .trim()
                    .isNotEmpty
                ? '${userData['firstName']} ${userData['lastName']}'
                : 'Utilisateur',
        memberIds: [userId],
        createdAt: DateTime.now(),
        meetingDate: meetingDate,
        meetingTime: meetingTime,
        meetingLocation: meetingLocation,
        memberCount: 1,
        maxMembers: maxMembers, // Set the maximum members limit
      );

      // Save revision group to Firestore
      await FirebaseFirestore.instance
          .collection('revisionGroups')
          .doc(revisionGroupId)
          .set(revisionGroup.toJson());

      // Update parent group to include the revision group ID
      await FirebaseFirestore.instance
          .collection('groups')
          .doc(parentGroupId)
          .update({
        'revisionGroupIds': FieldValue.arrayUnion([revisionGroupId]),
        'lastActivity': FieldValue.serverTimestamp(),
      });

      Get.snackbar(
        'Session créée',
        'La session d\'étude a été créée avec succès',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.7),
        colorText: Colors.white,
      );

      // Refresh revision groups
      loadRevisionGroups(parentGroupId);
      return true;
    } catch (e) {
      print("Error creating revision group: $e");
      Get.snackbar(
        'Erreur',
        'Une erreur est survenue lors de la création de la session d\'étude',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
      );
      return false;
    } finally {
      isCreating.value = false;
    }
  }

  // Join a revision group
  void joinRevisionGroup(String revisionGroupId) async {
    isLoading.value = true;
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;

      if (userId == null) {
        Get.snackbar(
          'Erreur',
          'Vous devez être connecté pour rejoindre une session d\'étude',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.7),
          colorText: Colors.white,
        );
        return;
      }

      // Get the revision group document
      final revisionGroupRef = FirebaseFirestore.instance
          .collection('revisionGroups')
          .doc(revisionGroupId);

      final revisionGroupDoc = await revisionGroupRef.get();
      if (!revisionGroupDoc.exists) {
        Get.snackbar(
          'Erreur',
          'Cette session d\'étude n\'existe plus',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.7),
          colorText: Colors.white,
        );
        return;
      }

      final revisionGroupData = revisionGroupDoc.data() as Map<String, dynamic>;
      final List<dynamic> memberIds = revisionGroupData['memberIds'] ?? [];
      final String parentGroupId = revisionGroupData['parentGroupId'] ?? '';

      // Check if user is already a member
      if (memberIds.contains(userId)) {
        Get.snackbar(
          'Information',
          'Vous êtes déjà inscrit à cette session d\'étude',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // Check if user is a member of the parent group
      final parentGroupDoc = await FirebaseFirestore.instance
          .collection('groups')
          .doc(parentGroupId)
          .get();

      if (!parentGroupDoc.exists) {
        Get.snackbar(
          'Erreur',
          'Le groupe parent n\'existe plus',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.7),
          colorText: Colors.white,
        );
        return;
      }

      final parentGroupData = parentGroupDoc.data() as Map<String, dynamic>;
      final List<dynamic> parentMemberIds = parentGroupData['memberIds'] ?? [];

      if (!parentMemberIds.contains(userId)) {
        Get.snackbar(
          'Erreur',
          'Vous devez d\'abord rejoindre le groupe principal pour participer à cette session d\'étude',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.withOpacity(0.7),
          colorText: Colors.white,
        );
        return;
      }

      // Update the revision group with the new member
      await revisionGroupRef.update({
        'memberIds': FieldValue.arrayUnion([userId]),
        'memberCount': FieldValue.increment(1),
      });

      Get.snackbar(
        'Session rejointe',
        'Vous êtes inscrit à la session d\'étude',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.7),
        colorText: Colors.white,
      );

      // Reload revision groups
      loadRevisionGroups(parentGroupId);
    } catch (e) {
      print("Error joining revision group: $e");
      Get.snackbar(
        'Erreur',
        'Une erreur est survenue lors de l\'inscription à la session d\'étude',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Leave a revision group
  void leaveRevisionGroup(String revisionGroupId) async {
    isLoading.value = true;
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;

      if (userId == null) {
        Get.snackbar(
          'Erreur',
          'Vous devez être connecté pour quitter une session d\'étude',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.7),
          colorText: Colors.white,
        );
        return;
      }

      // Get the revision group document
      final revisionGroupRef = FirebaseFirestore.instance
          .collection('revisionGroups')
          .doc(revisionGroupId);

      final revisionGroupDoc = await revisionGroupRef.get();
      if (!revisionGroupDoc.exists) {
        Get.snackbar(
          'Erreur',
          'Cette session d\'étude n\'existe plus',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.7),
          colorText: Colors.white,
        );
        return;
      }

      final revisionGroupData = revisionGroupDoc.data() as Map<String, dynamic>;
      final List<dynamic> memberIds = revisionGroupData['memberIds'] ?? [];
      final String creatorId = revisionGroupData['creatorId'] ?? '';
      final String parentGroupId = revisionGroupData['parentGroupId'] ?? '';

      // Check if user is a member
      if (!memberIds.contains(userId)) {
        Get.snackbar(
          'Information',
          'Vous n\'êtes pas inscrit à cette session d\'étude',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // Check if user is the creator
      if (userId == creatorId) {
        // If creator wants to leave, delete the revision group instead
        await revisionGroupRef.delete();

        // Update parent group to remove the revision group ID
        await FirebaseFirestore.instance
            .collection('groups')
            .doc(parentGroupId)
            .update({
          'revisionGroupIds': FieldValue.arrayRemove([revisionGroupId]),
        });

        Get.snackbar(
          'Session supprimée',
          'En tant que créateur, votre départ a entraîné la suppression de la session d\'étude',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.withOpacity(0.7),
          colorText: Colors.white,
        );
      } else {
        // Regular member leaving
        await revisionGroupRef.update({
          'memberIds': FieldValue.arrayRemove([userId]),
          'memberCount': FieldValue.increment(-1),
        });

        Get.snackbar(
          'Session quittée',
          'Vous avez quitté la session d\'étude',
          snackPosition: SnackPosition.BOTTOM,
        );
      }

      // Reload revision groups
      loadRevisionGroups(parentGroupId);
    } catch (e) {
      print("Error leaving revision group: $e");
      Get.snackbar(
        'Erreur',
        'Une erreur est survenue lors de la tentative de quitter la session d\'étude',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Create a new announcement in a group and save it to Firebase
  Future<void> createAnnouncement(String groupId, String content,
      {String? attachmentUrl}) async {
    try {
      // Get current user information
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        Get.snackbar(
          'Erreur',
          'Vous devez être connecté pour créer une annonce',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.7),
          colorText: Colors.white,
        );
        return;
      }

      // Get user name from Firestore
      String authorName = 'Utilisateur';
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (userDoc.exists) {
          final userData = userDoc.data();
          authorName = userData?['fullName'] ?? authorName;
        }
      } catch (e) {
        print("Error getting user name: $e");
      }

      // Create a new announcement document in Firestore
      final announcementId =
          FirebaseFirestore.instance.collection('announcements').doc().id;
      final now = DateTime.now();

      final newAnnouncement = GroupAnnouncementModel(
        id: announcementId,
        groupId: groupId,
        title: "Nouvelle annonce",
        content: content,
        authorId: user.uid,
        authorName: authorName,
        createdAt: now,
        attachments: attachmentUrl != null ? [attachmentUrl] : [],
      );

      await FirebaseFirestore.instance
          .collection('announcements')
          .doc(announcementId)
          .set(newAnnouncement.toJson());

      // Add the new announcement to the local list
      announcements.insert(0, newAnnouncement);

      Get.snackbar(
        'Succès',
        'Annonce publiée avec succès',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.7),
        colorText: Colors.white,
      );
    } catch (e) {
      print("Error creating announcement: $e");
      Get.snackbar(
        'Erreur',
        'Impossible de créer l\'annonce',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
      );
    }
  }

  // Create a group announcement
  Future<bool> createGroupAnnouncement({
    required String groupId,
    required String title,
    required String content,
    List<String> attachments = const [],
  }) async {
    isCreating.value = true;
    try {
      final userData = await LocalData.getUserData();
      final userId = FirebaseAuth.instance.currentUser?.uid;

      if (userId == null) {
        Get.snackbar(
          'Erreur',
          'Vous devez être connecté pour créer une annonce',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.7),
          colorText: Colors.white,
        );
        return false;
      }

      // Check if group exists
      final groupDoc = await FirebaseFirestore.instance
          .collection('groups')
          .doc(groupId)
          .get();

      if (!groupDoc.exists) {
        Get.snackbar(
          'Erreur',
          'Le groupe n\'existe pas',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.7),
          colorText: Colors.white,
        );
        return false;
      }

      // Check if user is an admin of the group
      final groupData = groupDoc.data() as Map<String, dynamic>;
      final List<dynamic> adminIds = groupData['adminIds'] ?? [];

      if (!adminIds.contains(userId)) {
        Get.snackbar(
          'Erreur',
          'Seuls les administrateurs peuvent créer des annonces',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.7),
          colorText: Colors.white,
        );
        return false;
      }

      // Generate unique ID for the announcement
      final String announcementId = const Uuid().v4();

      // Create announcement model
      final announcement = GroupAnnouncementModel(
        id: announcementId,
        groupId: groupId,
        title: title,
        content: content,
        authorId: userId,
        authorName: userData['name'] ?? 'Administrateur',
        createdAt: DateTime.now(),
        attachments: attachments,
      );

      // Save announcement to Firestore
      await FirebaseFirestore.instance
          .collection('groupAnnouncements')
          .doc(announcementId)
          .set(announcement.toJson());

      // Update group's last activity
      await FirebaseFirestore.instance
          .collection('groups')
          .doc(groupId)
          .update({
        'lastActivity': FieldValue.serverTimestamp(),
      });

      Get.snackbar(
        'Annonce publiée',
        'L\'annonce a été publiée avec succès',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.7),
        colorText: Colors.white,
      );

      // Refresh announcements
      loadGroupAnnouncements(groupId);
      return true;
    } catch (e) {
      print("Error creating announcement: $e");
      Get.snackbar(
        'Erreur',
        'Une erreur est survenue lors de la création de l\'annonce',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
      );
      return false;
    } finally {
      isCreating.value = false;
    }
  }

  // Delete a group announcement
  void deleteAnnouncement(String announcementId) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;

      if (userId == null) {
        Get.snackbar(
          'Erreur',
          'Vous devez être connecté pour supprimer une annonce',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.7),
          colorText: Colors.white,
        );
        return;
      }

      // Get the announcement
      final announcementDoc = await FirebaseFirestore.instance
          .collection('groupAnnouncements')
          .doc(announcementId)
          .get();

      if (!announcementDoc.exists) {
        Get.snackbar(
          'Erreur',
          'Cette annonce n\'existe plus',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.7),
          colorText: Colors.white,
        );
        return;
      }

      final announcementData = announcementDoc.data() as Map<String, dynamic>;
      final String authorId = announcementData['authorId'] ?? '';
      final String groupId = announcementData['groupId'] ?? '';

      // Check if user is the author or an admin of the group
      final groupDoc = await FirebaseFirestore.instance
          .collection('groups')
          .doc(groupId)
          .get();

      if (!groupDoc.exists) {
        Get.snackbar(
          'Erreur',
          'Le groupe associé n\'existe plus',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.7),
          colorText: Colors.white,
        );
        return;
      }

      final groupData = groupDoc.data() as Map<String, dynamic>;
      final List<dynamic> adminIds = groupData['adminIds'] ?? [];

      // Check if user has permission to delete
      if (userId != authorId && !adminIds.contains(userId)) {
        Get.snackbar(
          'Erreur',
          'Vous n\'êtes pas autorisé à supprimer cette annonce',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.7),
          colorText: Colors.white,
        );
        return;
      }

      // Delete the announcement
      await FirebaseFirestore.instance
          .collection('groupAnnouncements')
          .doc(announcementId)
          .delete();

      Get.snackbar(
        'Annonce supprimée',
        'L\'annonce a été supprimée avec succès',
        snackPosition: SnackPosition.BOTTOM,
      );

      // Refresh announcements
      loadGroupAnnouncements(groupId);
    } catch (e) {
      print("Error deleting announcement: $e");
      Get.snackbar(
        'Erreur',
        'Une erreur est survenue lors de la suppression de l\'annonce',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
      );
    }
  }

  // Return to groups list
  void exitGroup() {
    isInGroup.value = false;
    currentGroup.value = null;
  }

  // Show create group dialog/screen
  void showCreateGroupScreen() {
    Get.toNamed('/create-group');
  }

  // Show filter options modal
  void showFilterOptions() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filtrer les groupes',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            // Filter options here
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Get.back();
                },
                child: const Text('Appliquer'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Generate mock groups for testing
  List<GroupModel> _getMockGroups() {
    return [
      GroupModel(
        id: '1',
        name: 'Classe de Mathématiques Avancées',
        description:
            'Groupe pour les étudiants en mathématiques avancées. Partagez vos astuces et posez vos questions.',
        imageUrl: 'assets/images/math_group.png',
        category: 'Académique',
        creatorId: 'prof101',
        creatorName: 'Prof. Martin',
        memberIds: ['prof101', 'student1', 'student2', 'student3'],
        adminIds: ['prof101'],
        memberCount: 24,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        lastActivity: DateTime.now().subtract(const Duration(hours: 2)),
        isPublic: true,
      ),
      GroupModel(
        id: '2',
        name: 'Club de Robotique',
        description:
            'Passionnés de robotique, venez partager vos projets et apprendre ensemble.',
        imageUrl: 'assets/images/robotics_group.png',
        category: 'Technique',
        creatorId: 'tech203',
        creatorName: 'Alex Dupont',
        memberIds: ['tech203', 'student5', 'student6'],
        adminIds: ['tech203', 'student5'],
        memberCount: 18,
        createdAt: DateTime.now().subtract(const Duration(days: 45)),
        lastActivity: DateTime.now().subtract(const Duration(hours: 5)),
        isPublic: true,
      ),
      GroupModel(
        id: '3',
        name: 'Préparation aux Examens de Physique',
        description:
            'Entraide pour la préparation des examens de physique du semestre.',
        imageUrl: 'assets/images/physics_group.png',
        category: 'Académique',
        creatorId: 'student42',
        creatorName: 'Sophie Laurent',
        memberIds: ['student42', 'student12', 'student13'],
        adminIds: ['student42'],
        memberCount: 15,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        lastActivity: DateTime.now().subtract(const Duration(days: 1)),
        isPublic: true,
      ),
      GroupModel(
        id: '4',
        name: 'Club de Littérature',
        description: 'Pour les amoureux des livres et de la littérature.',
        imageUrl: 'assets/images/literature_group.png',
        category: 'Culturel',
        creatorId: 'prof202',
        creatorName: 'Prof. Lemaire',
        memberIds: ['prof202', 'student9', 'student10'],
        adminIds: ['prof202'],
        memberCount: 12,
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
        lastActivity: DateTime.now().subtract(const Duration(hours: 12)),
        isPublic: true,
      ),
      GroupModel(
        id: '5',
        name: 'Informatique - Projets de Développement',
        description:
            'Projets collaboratifs en informatique et développement web.',
        imageUrl: 'assets/images/coding_group.png',
        category: 'Technique',
        creatorId: 'tech101',
        creatorName: 'Thomas Mercier',
        memberIds: ['tech101', 'student20', 'student21'],
        adminIds: ['tech101', 'student20'],
        memberCount: 30,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        lastActivity: DateTime.now().subtract(const Duration(minutes: 30)),
        isPublic: false,
      ),
    ];
  }

  // Generate mock revision groups for testing
  List<RevisionGroupModel> _getMockRevisionGroups() {
    return [
      RevisionGroupModel(
        id: 'r1',
        parentGroupId: '1',
        name: 'Révision Algèbre Linéaire',
        description:
            'Session de révision intensive sur l\'algèbre linéaire avant l\'examen final.',
        subject: 'Mathématiques',
        creatorId: 'student1',
        creatorName: 'Jean Dupont',
        memberIds: ['student1', 'student2', 'student3'],
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        meetingDate: DateTime.now().add(const Duration(days: 2)),
        meetingTime: '14:00 - 16:00',
        meetingLocation: 'Bibliothèque, Salle A3',
        memberCount: 8,
      ),
      RevisionGroupModel(
        id: 'r2',
        parentGroupId: '1',
        name: 'Préparation Examen Calcul Différentiel',
        description:
            'Entraide sur les concepts difficiles du calcul différentiel.',
        subject: 'Mathématiques',
        creatorId: 'student2',
        creatorName: 'Marie Lambert',
        memberIds: ['student2', 'student3'],
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        meetingDate: DateTime.now().add(const Duration(days: 4)),
        meetingTime: '10:00 - 12:00',
        meetingLocation: 'Salle d\'étude 2C',
        memberCount: 5,
      ),
      RevisionGroupModel(
        id: 'r3',
        parentGroupId: '3',
        name: 'Préparation TP Mécanique',
        description:
            'Préparation pour le TP de mécanique de la semaine prochaine.',
        subject: 'Physique',
        creatorId: 'student42',
        creatorName: 'Sophie Laurent',
        memberIds: ['student42', 'student12', 'student13'],
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        meetingDate: DateTime.now().add(const Duration(days: 1)),
        meetingTime: '15:30 - 17:30',
        meetingLocation: 'Laboratoire B4',
        memberCount: 6,
      ),
    ];
  }

  // Generate mock announcements for testing
  List<GroupAnnouncementModel> _getMockAnnouncements() {
    return [
      GroupAnnouncementModel(
        id: 'a1',
        groupId: '1',
        title: 'Documents de cours mis à jour',
        content:
            'Les notes de cours pour le chapitre 5 ont été mises à jour. Vous pouvez les consulter dans les fichiers du groupe.',
        authorId: 'prof101',
        authorName: 'Prof. Martin',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        attachments: ['cours_chapitre5.pdf'],
      ),
      GroupAnnouncementModel(
        id: 'a2',
        groupId: '1',
        title: 'Report du rendu de projet',
        content:
            'Suite à plusieurs demandes, la date limite pour le rendu du projet est reportée au 15 mai.',
        authorId: 'prof101',
        authorName: 'Prof. Martin',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      GroupAnnouncementModel(
        id: 'a3',
        groupId: '3',
        title: 'Annulation du cours de vendredi',
        content:
            'Le cours de physique de vendredi 8 avril est annulé. Un cours de rattrapage sera programmé ultérieurement.',
        authorId: 'student42',
        authorName: 'Sophie Laurent',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];
  }

  // Generate a random 6-character alphanumeric invitation code
  String _generateInvitationCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(
        6, // 6-character code
        (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );
  }

  // Join a group using invitation code
  Future<bool> joinGroupByInvitationCode(String invitationCode) async {
    isLoading.value = true;
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;

      if (userId == null) {
        Get.snackbar(
          'Erreur',
          'Vous devez être connecté pour rejoindre un groupe',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.7),
          colorText: Colors.white,
        );
        return false;
      }

      // Find the group with this invitation code
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('groups')
          .where('invitationCode', isEqualTo: invitationCode)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        Get.snackbar(
          'Erreur',
          'Code d\'invitation invalide ou expiré',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.7),
          colorText: Colors.white,
        );
        return false;
      }

      final groupDoc = snapshot.docs.first;
      final groupId = groupDoc.id;
      final groupData = groupDoc.data() as Map<String, dynamic>;
      final List<dynamic> memberIds = groupData['memberIds'] ?? [];

      // Check if user is already a member
      if (memberIds.contains(userId)) {
        Get.snackbar(
          'Information',
          'Vous êtes déjà membre de ce groupe',
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }

      // Join the group
      await FirebaseFirestore.instance
          .collection('groups')
          .doc(groupId)
          .update({
        'memberIds': FieldValue.arrayUnion([userId]),
        'memberCount': FieldValue.increment(1),
        'lastActivity': FieldValue.serverTimestamp(),
      });

      Get.snackbar(
        'Groupe rejoint',
        'Vous avez rejoint le groupe avec succès',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.7),
        colorText: Colors.white,
      );

      // Refresh groups
      loadGroups();
      loadMyGroups();
      return true;
    } catch (e) {
      print("Error joining group by invitation code: $e");
      Get.snackbar(
        'Erreur',
        'Une erreur est survenue lors de la tentative de rejoindre le groupe',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Add a user to group using their personal invitation code
  Future<void> addUserByInvitationCode(
      String groupId, String invitationCode) async {
    isLoading.value = true;
    try {
      final adminId = FirebaseAuth.instance.currentUser?.uid;

      if (adminId == null) {
        Get.snackbar(
          'Erreur',
          'Vous devez être connecté pour ajouter un membre',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.7),
          colorText: Colors.white,
        );
        return;
      }

      // Check if the current user is an admin of the group
      final groupDoc = await FirebaseFirestore.instance
          .collection('groups')
          .doc(groupId)
          .get();

      if (!groupDoc.exists) {
        Get.snackbar(
          'Erreur',
          'Ce groupe n\'existe plus',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.7),
          colorText: Colors.white,
        );
        return;
      }

      final groupData = groupDoc.data() as Map<String, dynamic>;
      final List<dynamic> adminIds = groupData['adminIds'] ?? [];

      if (!adminIds.contains(adminId)) {
        Get.snackbar(
          'Accès refusé',
          'Vous devez être administrateur du groupe pour ajouter des membres',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.7),
          colorText: Colors.white,
        );
        return;
      }

      // Find the user with this invitation code
      final QuerySnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('invitations')
          .where('code', isEqualTo: invitationCode)
          .limit(1)
          .get();

      if (userSnapshot.docs.isEmpty) {
        Get.snackbar(
          'Code invalide',
          'Aucun utilisateur trouvé avec ce code d\'invitation',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.withOpacity(0.7),
          colorText: Colors.white,
        );
        return;
      }

      final userData = userSnapshot.docs.first.data() as Map<String, dynamic>;
      final userId = userData['userId'];

      // Check if user is already a member
      final List<dynamic> memberIds = groupData['memberIds'] ?? [];
      if (memberIds.contains(userId)) {
        Get.snackbar(
          'Information',
          'Cet utilisateur est déjà membre du groupe',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.blue.withOpacity(0.7),
          colorText: Colors.white,
        );
        return;
      }

      // Add the user to the group
      await FirebaseFirestore.instance
          .collection('groups')
          .doc(groupId)
          .update({
        'memberIds': FieldValue.arrayUnion([userId]),
        'memberCount': FieldValue.increment(1),
        'lastActivity': FieldValue.serverTimestamp(),
      });

      Get.snackbar(
        'Membre ajouté',
        'L\'utilisateur a été ajouté au groupe avec succès',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.7),
        colorText: Colors.white,
      );

      // Refresh group data
      openGroup(groupId);
    } catch (e) {
      print("Error adding user by invitation code: $e");
      Get.snackbar(
        'Erreur',
        'Une erreur est survenue lors de l\'ajout de l\'utilisateur',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Check if current user is an admin of the group
  bool isCurrentUserAdmin() {
    if (currentGroup.value == null) return false;

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return false;

    return currentGroup.value!.adminIds.contains(userId);
  }
}
