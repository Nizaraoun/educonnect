import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:educonnect/routes/app_routing.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';

// Adding a FakeDocumentSnapshot class to simulate Firestore DocumentSnapshot
// ignore: subtype_of_sealed_class
class FakeDocumentSnapshot implements DocumentSnapshot {
  final Map<String, dynamic> _data;
  final String _id;

  FakeDocumentSnapshot(this._data, this._id);

  @override
  Map<String, dynamic> data() => _data;

  @override
  String get id => _id;

  @override
  @override
  bool get exists => true;

  @override
  dynamic get(Object field) => _data[field as String];

  @override
  SnapshotMetadata get metadata => throw UnimplementedError();

  @override
  DocumentReference get reference => throw UnimplementedError();

  @override
  SnapshotOptions? get snapshotOptions => throw UnimplementedError();

  @override
  operator [](Object field) {
    // TODO: implement []
    throw UnimplementedError();
  }
}

class TeacherHomeController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Teacher data
  final RxMap<String, dynamic> userData = <String, dynamic>{}.obs;

  // Courses
  final RxList<Map<String, dynamic>> courses = <Map<String, dynamic>>[].obs;
  final RxBool isLoadingCourses = true.obs;

  // Announcements
  final RxList<DocumentSnapshot> announcements = <DocumentSnapshot>[].obs;
  final RxBool isLoadingAnnouncements = true.obs;

  // Student statistics
  final RxInt totalStudents = 0.obs;
  final RxInt activeStudents = 0.obs;
  final RxDouble averageEngagement = 0.0.obs;

  // Exams
  final RxList<Map<String, dynamic>> upcomingExams =
      <Map<String, dynamic>>[].obs;
  final RxBool isLoadingExams = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadTeacherData();
    loadAnnouncements();
    loadUpcomingExams();
  }

  Future<void> loadTeacherData() async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        final DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(currentUser.uid).get();

        if (userDoc.exists) {
          userData.value = userDoc.data() as Map<String, dynamic>;
        }
      }
    } catch (e) {
      print('Error loading teacher data: $e');
    }
  }

  Future<void> loadAnnouncements() async {
    try {
      isLoadingAnnouncements.value = true;

      // In a real app, you would fetch announcements from Firestore
      // For demo purposes, we'll create some sample announcements
      await Future.delayed(Duration(seconds: 1)); // Simulate network delay

      announcements.value = [];

      // Since we're not actually querying Firestore, we'll create fake announcements
      final List<Map<String, dynamic>> sampleAnnouncements = [
        {
          'id': '1',
          'title': 'Mise à jour du cours CS101',
          'description':
              'Le programme du cours a été mis à jour. Veuillez consulter les nouveaux documents.',
          'createdAt': {
            'seconds': DateTime.now()
                    .subtract(Duration(days: 2))
                    .millisecondsSinceEpoch ~/
                1000,
            'nanoseconds': 0
          },
          'colorHex': '#4CAF50',
          'read': false,
        },
        {
          'id': '2',
          'title': 'Modifications des horaires d\'examen',
          'description':
              'Les horaires des examens de mi-semestre ont été modifiés. Consultez le nouveau planning.',
          'createdAt': {
            'seconds': DateTime.now()
                    .subtract(Duration(days: 5))
                    .millisecondsSinceEpoch ~/
                1000,
            'nanoseconds': 0
          },
          'colorHex': '#2196F3',
          'read': false,
        },
        {
          'id': '3',
          'title': 'Conférence sur l\'IA',
          'description':
              'Une conférence sur l\'intelligence artificielle aura lieu le 15 mai. La présence est recommandée.',
          'createdAt': {
            'seconds': DateTime.now()
                    .subtract(Duration(days: 1))
                    .millisecondsSinceEpoch ~/
                1000,
            'nanoseconds': 0
          },
          'colorHex': '#FF9800',
          'read': false,
        },
      ];

      // Create fake DocumentSnapshot objects
      final random = Random();
      announcements.value = sampleAnnouncements.map((data) {
        // We're not actually creating real DocumentSnapshots, but simulating their behavior
        return FakeDocumentSnapshot(data, random.nextInt(10000).toString());
      }).toList();
    } catch (e) {
      print('Error loading announcements: $e');
    } finally {
      isLoadingAnnouncements.value = false;
    }
  }

  Future<void> loadUpcomingExams() async {
    try {
      isLoadingExams.value = true;

      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        print('No authenticated user found');
        return;
      }

      // Get the current date
      print("+++++++++++++++++++++++++");
      print(currentUser.uid);
      print("+++++++++++++++++++++++++");

      // Query upcoming exams from Firestore
      final QuerySnapshot examSnapshot = await _firestore
          .collection('exams')
          .where('teacherId', isEqualTo: currentUser.uid)
          .limit(5) // Limit to 5 upcoming exams
          .get();

      final List<Map<String, dynamic>> examsList = [];

      for (var doc in examSnapshot.docs) {
        Map<String, dynamic> exam =
            Map<String, dynamic>.from(doc.data() as Map<String, dynamic>);
        exam['id'] = doc.id;

        // Convert Firestore Timestamp to DateTime
        if (exam['date'] is Timestamp) {
          exam['date'] = (exam['date'] as Timestamp).toDate();
        }

        // Ensure all required fields exist
        if (!exam.containsKey('title')) {
          exam['title'] = 'Untitled Exam';
        }

        if (!exam.containsKey('course')) {
          exam['course'] = 'Unspecified Course';
        }

        if (!exam.containsKey('duration')) {
          exam['duration'] = 'Unspecified';
        }

        if (!exam.containsKey('location') && exam.containsKey('salle')) {
          exam['location'] = exam['salle'];
        } else if (!exam.containsKey('location')) {
          exam['location'] = 'Unspecified';
        }

        examsList.add(exam);
      }

      // If no exams are found in Firestore, provide a message or fallback data
      if (examsList.isEmpty) {
        print('No upcoming exams found for teacher ${currentUser.uid}');
      }

      upcomingExams.value = examsList;
    } catch (e) {
      print('Error loading upcoming exams: $e');
    } finally {
      isLoadingExams.value = false;
    }
  }
 // Method to navigate to detailed course view
  void navigateToExamPlanning() {
    Get.toNamed(AppRoutes.teacherExamPlanning);
  }

  // Method to navigate to exam details
  void navigateToExamDetails(String examId) {
    // Find the exam in the list by ID
    final exam = upcomingExams.firstWhere(
      (exam) => exam['id'] == examId,
      orElse: () => <String, dynamic>{},
    );

    if (exam.isNotEmpty) {
      // Pass the entire exam object to the details page
      Get.toNamed(AppRoutes.examDetails, arguments: exam);
    } else {
      print('Exam with ID $examId not found');
    }
  }

  // Method to create a new announcement
  Future<void> createAnnouncement(String title, String description) async {
    // In a real app, you would add this to Firestore
    print('Creating new announcement: $title');
    // After creating, reload announcements
    loadAnnouncements();
  }
}
