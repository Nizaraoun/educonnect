import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';
import '../model/course_model.dart';

class CourseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collection references
  CollectionReference get _coursesCollection =>
      _firestore.collection('courses');

  // Get user ID
  String? get _userId => _auth.currentUser?.uid;

  // Get courses by teacher ID
  Stream<List<Course>> getCourses() {
    if (_userId == null) {
      return Stream.value([]);
    }

    return _coursesCollection
        .where('teacherId', isEqualTo: _userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Course.fromFirestore(doc)).toList();
    });
  }

  // Get a single course by ID
  Future<Course?> getCourse(String courseId) async {
    DocumentSnapshot doc = await _coursesCollection.doc(courseId).get();
    if (doc.exists) {
      return Course.fromFirestore(doc);
    }
    return null;
  }

  // Add a new course
  Future<String> addCourse(Course course) async {
    if (_userId == null) {
      throw Exception('User not authenticated');
    }

    Map<String, dynamic> data = course.toFirestore();
    data['teacherId'] = _userId;
    data['createdAt'] = FieldValue.serverTimestamp();

    DocumentReference docRef = await _coursesCollection.add(data);
    return docRef.id;
  }

  // Update an existing course
  Future<void> updateCourse(String courseId, Course course) async {
    await _coursesCollection.doc(courseId).update(course.toFirestore());
  }

  // Delete a course
  Future<void> deleteCourse(String courseId) async {
    // First get all document references to delete from storage
    Course? course = await getCourse(courseId);
    if (course != null) {
      for (var module in course.modules) {
        for (var document in module.documents) {
          if (document.downloadUrl != null) {
            try {
              await _storage.refFromURL(document.downloadUrl!).delete();
            } catch (e) {
              print('Error deleting file: $e');
            }
          }
        }
      }
    }

    // Then delete the course document
    await _coursesCollection.doc(courseId).delete();
  }

  // Add a new module to a course
  Future<void> addModule(String courseId, Module module) async {
    DocumentSnapshot courseDoc = await _coursesCollection.doc(courseId).get();
    if (!courseDoc.exists) {
      throw Exception('Course not found');
    }

    List<dynamic> modules =
        (courseDoc.data() as Map<String, dynamic>)['modules'] ?? [];
    modules.add(module.toMap());

    await _coursesCollection.doc(courseId).update({'modules': modules});
  }

  // Add a document to a module
  Future<Document> addDocument(
    String courseId,
    String moduleId,
    String title,
    File file,
  ) async {
    // Generate a unique ID for the document
    String documentId = const Uuid().v4();

    // Upload file to Firebase Storage
    String fileName = path.basename(file.path);
    String extension = path.extension(fileName).replaceFirst('.', '');

    // Create a reference to the file location in Firebase Storage
    String storagePath =
        'courses/$courseId/modules/$moduleId/$documentId-$fileName';
    Reference storageRef = _storage.ref().child(storagePath);

    // Upload the file
    UploadTask uploadTask = storageRef.putFile(file);
    TaskSnapshot taskSnapshot = await uploadTask;
    String downloadUrl = await taskSnapshot.ref.getDownloadURL();

    // Create document object
    Document document = Document(
      id: documentId,
      title: title,
      type: extension,
      size: _getFileSize(await file.length()),
      uploadDate: DateTime.now().toString().substring(0, 10),
      downloadUrl: downloadUrl,
    );

    // Update the course document in Firestore
    DocumentSnapshot courseDoc = await _coursesCollection.doc(courseId).get();
    if (courseDoc.exists) {
      Map<String, dynamic> courseData =
          courseDoc.data() as Map<String, dynamic>;
      List<dynamic> modules = courseData['modules'] ?? [];

      // Find the module to update
      for (int i = 0; i < modules.length; i++) {
        if (modules[i]['id'] == moduleId) {
          List<dynamic> documents = modules[i]['documents'] ?? [];
          documents.add(document.toMap());
          modules[i]['documents'] = documents;
          break;
        }
      }

      await _coursesCollection.doc(courseId).update({'modules': modules});
    }

    return document;
  }

  // Delete a document
  Future<void> deleteDocument(
    String courseId,
    String moduleId,
    String documentId,
    String? downloadUrl,
  ) async {
    // Delete file from storage if URL exists
    if (downloadUrl != null) {
      try {
        await _storage.refFromURL(downloadUrl).delete();
      } catch (e) {
        print('Error deleting file: $e');
      }
    }

    // Update the course document in Firestore
    DocumentSnapshot courseDoc = await _coursesCollection.doc(courseId).get();
    if (courseDoc.exists) {
      Map<String, dynamic> courseData =
          courseDoc.data() as Map<String, dynamic>;
      List<dynamic> modules = courseData['modules'] ?? [];

      // Find the module containing the document
      for (int i = 0; i < modules.length; i++) {
        if (modules[i]['id'] == moduleId) {
          List<dynamic> documents = modules[i]['documents'] ?? [];
          documents.removeWhere((doc) => doc['id'] == documentId);
          modules[i]['documents'] = documents;
          break;
        }
      }

      await _coursesCollection.doc(courseId).update({'modules': modules});
    }
  }

  // Get all documents across all courses
  Future<List<Map<String, dynamic>>> getAllDocuments() async {
    if (_userId == null) {
      return [];
    }

    List<Map<String, dynamic>> allDocuments = [];

    QuerySnapshot coursesSnapshot =
        await _coursesCollection.where('teacherId', isEqualTo: _userId).get();

    for (var courseDoc in coursesSnapshot.docs) {
      final courseData = courseDoc.data() as Map<String, dynamic>;
      final courseTitle = courseData['title'] as String;
      final courseCode = courseData['code'] as String;
      final courseColor = courseData['color'] as String;

      if (courseData['modules'] != null) {
        for (var module in courseData['modules'] as List<dynamic>) {
          final moduleTitle = module['title'] as String;

          if (module['documents'] != null) {
            for (var document in module['documents'] as List<dynamic>) {
              allDocuments.add({
                ...document as Map<String, dynamic>,
                'courseTitle': courseTitle,
                'courseCode': courseCode,
                'moduleTitle': moduleTitle,
                'color': courseColor,
                'courseId': courseDoc.id,
                'moduleId': module['id'],
              });
            }
          }
        }
      }
    }

    return allDocuments;
  }

  // Upload a file and get a document object
  Future<Document> uploadFile(
    String courseId,
    String moduleId,
    String title,
  ) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result == null || result.files.single.path == null) {
      throw Exception('No file selected');
    }

    File file = File(result.files.single.path!);
    return addDocument(courseId, moduleId, title, file);
  }

  // Utility function to format file size
  String _getFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  // Get download statistics for documents
  Future<Map<String, int>> getDocumentDownloadStats() async {
    // This would typically connect to a separate collection that tracks document views/downloads
    // For this example, we'll return mock data
    return {
      'document1': 42,
      'document2': 36,
      'document3': 29,
      'document4': 27,
    };
  }

  // Get statistics for the statistics tab
  Future<Map<String, dynamic>> getStatistics() async {
    if (_userId == null) {
      return {
        'totalCourses': 0,
        'totalDocuments': 0,
        'totalStudents': 0,
        'courseActivity': [],
        'popularDocuments': []
      };
    }

    try {
      // Get courses
      QuerySnapshot coursesSnapshot =
          await _coursesCollection.where('teacherId', isEqualTo: _userId).get();

      List<Course> courses =
          coursesSnapshot.docs.map((doc) => Course.fromFirestore(doc)).toList();

      // Calculate total students and document count
      int totalStudents = 0;
      int totalDocuments = 0;
      List<Map<String, dynamic>> courseActivity = [];

      for (var course in courses) {
        totalStudents += course.students;

        // Count documents
        int courseDocuments = 0;
        for (var module in course.modules) {
          courseDocuments += module.documents.length;
        }
        totalDocuments += courseDocuments;

        // Add to course activity
        if (courseDocuments > 0) {
          courseActivity.add({
            'title': course.title,
            'code': course.code,
            'color': course.color,
            'activity': (0.3 + (courseDocuments / 10)).clamp(0.0, 1.0),
            'count': courseDocuments,
          });
        }
      }

      // Sort course activity by count
      courseActivity.sort((a, b) => b['count'].compareTo(a['count']));

      // Get document download stats
      Map<String, int> downloadStats = await getDocumentDownloadStats();

      // Get all documents and combine with download stats
      List<Map<String, dynamic>> allDocs = await getAllDocuments();

      // Find most popular documents based on mock stats
      List<Map<String, dynamic>> popularDocuments = allDocs.take(4).map((doc) {
        String docId = doc['id'];
        int downloads = downloadStats[docId] ?? 0;
        return {
          ...doc,
          'downloads': downloads,
        };
      }).toList();

      // Sort by downloads
      popularDocuments.sort((a, b) => b['downloads'].compareTo(a['downloads']));

      return {
        'totalCourses': courses.length,
        'totalDocuments': totalDocuments,
        'totalStudents': totalStudents,
        'courseActivity': courseActivity,
        'popularDocuments': popularDocuments,
      };
    } catch (e) {
      print('Error getting statistics: $e');
      return {
        'totalCourses': 0,
        'totalDocuments': 0,
        'totalStudents': 0,
        'courseActivity': [],
        'popularDocuments': []
      };
    }
  }
}
