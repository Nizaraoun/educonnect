import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../groupe/view/group_detail_screen.dart';
import '../model/revision_model.dart';
import '../../groupe/model/group_model.dart'; // Import GroupModel to access RevisionGroupModel

class RevisionController extends GetxController {
  // Observable variables
  final RxBool isLoading = false.obs;
  final RxList<RevisionModel> revisions = <RevisionModel>[].obs;
  final RxList<RevisionGroupModel> groupRevisions =
      <RevisionGroupModel>[].obs; // Added for group revisions
  final RxList<RevisionModel> publicRevisions =
      <RevisionModel>[].obs; // Added for public revisions
  final RxString currentFilter = 'Tous'.obs;
  final RxString selectedTab = 'À faire'.obs;
  final RxString selectedTypeTab =
      'Privé'.obs; // Track whether viewing private or public revisions

  // Tab controllers
  late TabController tabController;
  late TabController
      typeTabController; // For switching between public and private revisions

  @override
  void onInit() {
    super.onInit();
    loadRevisions();
    loadGroupRevisions(); // Load user's group revisions
    loadPublicRevisions(); // Load public revisions
  }

  // Load revisions from Firebase or mock data
  void loadRevisions() {
    isLoading.value = true;

    // For now, we'll use mock data
    // In a real app, you would fetch data from Firebase
    Future.delayed(const Duration(seconds: 1), () {
      // revisions.value = _getMockRevisions();
      isLoading.value = false;
    });
  }

  // Load all revision groups the user is a member of
  void loadGroupRevisions() async {
    isLoading.value = true;

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;

      if (userId == null) {
        isLoading.value = false;
        return;
      }

      // Query all revision groups where user is a member
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('revisionGroups')
          .where('memberIds', arrayContains: userId)
          .get();

      final loadedGroupRevisions = snapshot.docs.map((doc) {
        return RevisionGroupModel.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();

      // Sort by meeting date (upcoming first)
      loadedGroupRevisions
          .sort((a, b) => a.meetingDate.compareTo(b.meetingDate));

      groupRevisions.value = loadedGroupRevisions;
    } catch (e) {
      print("Error loading group revisions: $e");
      // Fallback to empty list
      groupRevisions.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  // Load all public revisions
  void loadPublicRevisions() async {
    isLoading.value = true;

    try {
      // Query all public revisions
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('publicRevisions')
          .orderBy('meetingDate', descending: false)
          .get();

      final loadedPublicRevisions = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        // Convert Firestore data to RevisionModel
        return RevisionModel(
          id: doc.id,
          title: data['title'] ?? '',
          subject: data['subject'] ?? '',
          description: data['description'] ?? '',
          date: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          deadlineDate:
              (data['meetingDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
          duration: data['meetingTime'] ?? '',
          status: _getStatusFromDate(
              (data['meetingDate'] as Timestamp?)?.toDate() ?? DateTime.now()),
          priority: _getPriorityFromDate(
              (data['meetingDate'] as Timestamp?)?.toDate() ?? DateTime.now()),
          topics: List<String>.from(data['topics'] ?? []),
          completionPercentage: 0, // Default for public revisions
          maxGroupe: data['maxMembers'] ?? 30,
          currentMembers: data['memberCount'] ?? 0,
        );
      }).toList();

      publicRevisions.value = loadedPublicRevisions;
    } catch (e) {
      print("Error loading public revisions: $e");
      // Fallback to empty list
      publicRevisions.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  // Get status based on date
  String _getStatusFromDate(DateTime date) {
    final now = DateTime.now();
    if (date.isBefore(now)) {
      return 'Terminé';
    } else if (date.difference(now).inDays <= 3) {
      return 'En cours';
    }
    return 'À faire';
  }

  // Convert RevisionGroupModel to RevisionModel for unified display
  RevisionModel convertGroupRevisionToRevision(
      RevisionGroupModel groupRevision) {
    // Get status based on date
    String status = 'À faire';
    int completionPercentage = 0;

    final now = DateTime.now();
    if (groupRevision.meetingDate.isBefore(now)) {
      status = 'Terminé';
      completionPercentage = 100;
    } else if (groupRevision.meetingDate.difference(now).inDays <= 3) {
      status = 'En cours';
      completionPercentage = 50;
    }

    return RevisionModel(
      id: groupRevision.id,
      title: groupRevision.name,
      subject: groupRevision.subject,
      description: groupRevision.description,
      date: groupRevision.createdAt,
      deadlineDate: groupRevision.meetingDate,
      duration: groupRevision.meetingTime,
      status: status,
      priority: _getPriorityFromDate(groupRevision.meetingDate),
      topics: [
        groupRevision.subject,
        'Groupe de révision',
        groupRevision.meetingLocation
      ],
      completionPercentage: completionPercentage,
      maxGroupe: groupRevision
          .maxMembers, // Using the maxMembers from RevisionGroupModel
      currentMembers: groupRevision.memberCount, // Using actual member count
    );
  }

  // Get revisions including group revisions for a specific status
  List<RevisionModel> getAllRevisions(String status) {
    if (selectedTypeTab.value == 'Public') {
      // Return only public revisions
      return publicRevisions.where((r) => r.status == status).toList();
    } else {
      // Return private (personal + group) revisions
      final personalRevisions =
          revisions.where((r) => r.status == status).toList();

      // Convert and filter group revisions by status
      final convertedGroupRevisions = groupRevisions
          .map((gr) => convertGroupRevisionToRevision(gr))
          .where((r) => r.status == status)
          .toList();

      // Combine both lists
      return [...personalRevisions, ...convertedGroupRevisions];
    }
  }

  // Calculate priority based on deadline proximity
  int _getPriorityFromDate(DateTime date) {
    final daysUntil = date.difference(DateTime.now()).inDays;

    if (daysUntil < 3) return 3; // High priority
    if (daysUntil < 7) return 2; // Medium priority
    return 1; // Low priority
  }

  // Filter revisions by status
  void filterByStatus(String status) {
    selectedTab.value = status;

    if (status == 'Tous') {
      loadRevisions();
      loadGroupRevisions();
      loadPublicRevisions();
    } else {
      isLoading.value = true;
      Future.delayed(const Duration(milliseconds: 300), () {
        // No need to reload data, just update the UI
        isLoading.value = false;
      });
    }
  }

  // Toggle between public and private revisions
  void toggleRevisionType(String type) {
    selectedTypeTab.value = type;

    // Refresh data based on selected type
    if (type == 'Public') {
      loadPublicRevisions();
    } else {
      loadRevisions();
      loadGroupRevisions();
    }
  }

  // Filter revisions by subject
  void filterBySubject(String subject) {
    currentFilter.value = subject;

    if (subject == 'Tous') {
      loadRevisions();
      loadGroupRevisions();
      loadPublicRevisions();
    } else {
      isLoading.value = true;
      Future.delayed(const Duration(milliseconds: 300), () {
        // Also filter group revisions
        groupRevisions.value =
            groupRevisions.where((gr) => gr.subject == subject).toList();

        // Filter public revisions too
        publicRevisions.value =
            publicRevisions.where((pr) => pr.subject == subject).toList();

        isLoading.value = false;
      });
    }
  }

  // Navigate to create revision screen
  void navigateToCreateRevision({bool isPublic = false}) {
    // Pass the isPublic parameter to the creation screen
    Get.snackbar(
      'Créer une révision',
      isPublic
          ? 'Vous allez créer une révision publique'
          : 'Cette fonctionnalité sera bientôt disponible',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  // Join a group revision session
  void joinRevisionSession(String revisionGroupId) {
    // Find the revision group in the list
    final revisionGroup = groupRevisions.firstWhere(
      (gr) => gr.id == revisionGroupId,
      orElse: () => RevisionGroupModel(
        id: '',
        parentGroupId: '',
        name: '',
        description: '',
        subject: '',
        creatorId: '',
        creatorName: '',
        memberIds: [],
        createdAt: DateTime.now(),
        meetingDate: DateTime.now(),
        meetingTime: '',
        meetingLocation: '',
        memberCount: 0,
      ),
    );

    // If the revision group doesn't exist, return
    if (revisionGroup.id.isEmpty) return;

    // Navigate to group detail screen
    Get.to(() => GroupDetailScreen(
          groupId: revisionGroup.id,
        ));
  }

  // Join a public revision
  void joinPublicRevision(String revisionId) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      // Find the public revision
      final revision = publicRevisions.firstWhere(
        (r) => r.id == revisionId,
        orElse: () => RevisionModel(
          id: '',
          title: '',
          subject: '',
          description: '',
          date: DateTime.now(),
          deadlineDate: DateTime.now(),
          duration: '',
          status: '',
          priority: 1,
          topics: [],
          completionPercentage: 0,
        ),
      );

      // Check if revision exists and has not reached capacity
      if (revision.id.isEmpty) return;
      if (revision.currentMembers >= revision.maxGroupe) {
        Get.snackbar(
          'Session complète',
          'Cette session de révision a atteint sa capacité maximale',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // Add user to the public revision members
      await FirebaseFirestore.instance
          .collection('publicRevisions')
          .doc(revisionId)
          .update({
        'memberIds': FieldValue.arrayUnion([userId]),
        'memberCount': FieldValue.increment(1),
      });

      Get.snackbar(
        'Inscription réussie',
        'Vous avez rejoint la session de révision',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Reload public revisions to update the UI
      loadPublicRevisions();
    } catch (e) {
      print('Error joining public revision: $e');
      Get.snackbar(
        'Erreur',
        'Impossible de rejoindre cette session',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Create a new public revision
  void createPublicRevision({
    required String title,
    required String description,
    required String subject,
    required DateTime meetingDate,
    required String meetingTime,
    required String meetingLocation,
    required int maxMembers,
  }) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      final userName =
          FirebaseAuth.instance.currentUser?.displayName ?? 'Utilisateur';

      if (userId == null) return;

      // Create the public revision document
      DocumentReference docRef =
          await FirebaseFirestore.instance.collection('publicRevisions').add({
        'title': title,
        'description': description,
        'subject': subject,
        'createdAt': Timestamp.now(),
        'meetingDate': Timestamp.fromDate(meetingDate),
        'meetingTime': meetingTime,
        'meetingLocation': meetingLocation,
        'creatorId': userId,
        'creatorName': userName,
        'memberIds': [userId],
        'memberCount': 1,
        'maxMembers': maxMembers,
        'topics': [subject, meetingLocation, 'Révision publique'],
        'isPublic': true,
      });

      // Update the document with its ID
      await docRef.update({'id': docRef.id});

      Get.snackbar(
        'Succès',
        'Révision publique créée avec succès',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Reload public revisions
      loadPublicRevisions();
    } catch (e) {
      print('Error creating public revision: $e');
      Get.snackbar(
        'Erreur',
        'Impossible de créer la révision publique',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
