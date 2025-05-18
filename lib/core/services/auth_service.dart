import 'package:educonnect/routes/app_routing.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/localData.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<String> getInitialRoute() async {
    User? user = _auth.currentUser;

    if (user != null) {
      String? userType = await _getUserType(user.uid);

      if (userType == 'teacher') {
        return AppRoutes.teacherHome;
      } else {
        return AppRoutes.dashboard;
      }
    } else {
      return AppRoutes.login;
    }
  }

  static void setupAuthListener() {
    _auth.authStateChanges().listen((User? user) async {
      if (user != null) {
        // Get user type from local storage or Firestore
        String? userType = await _getUserType(user.uid);

        // Redirect based on user type
        if (userType == 'teacher') {
          Get.offAllNamed(AppRoutes.teacherHome);
        } else {
          Get.offAllNamed(AppRoutes.dashboard);
        }
      } else {
        // User is not logged in, redirect to login screen
        Get.offAllNamed(AppRoutes.login);
      }
    });
  }

  /// Helper method to get user type
  static Future<String?> _getUserType(String userId) async {
    // First try to get from local storage
    Map<String, dynamic> userData = await LocalData.getUserData();
    String? userType = userData['userType'];

    // If not available in local storage, fetch from Firestore
    if (userType == null || userType.isEmpty) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();

        if (userDoc.exists) {
          Map<String, dynamic> userData =
              userDoc.data() as Map<String, dynamic>;
          userType = userData['userType'] ?? 'student';

          // Save to local storage for future use
          await LocalData.saveUserData(
            id: userId,
            firstName: userData['firstName'] ?? '',
            lastName: userData['lastName'] ?? '',
            email: userData['email'] ?? '',
            phone: userData['phone'] ?? '',
            userType: userType ?? 'student',
            major: userType == 'student' ? userData['major'] : null,
            yearOfStudy: userType == 'student' ? userData['yearOfStudy'] : null,
            department: userType == 'teacher' ? userData['department'] : null,
            specialization:
                userType == 'teacher' ? userData['specialization'] : null,
          );
        }
      } catch (e) {
        print('Error fetching user data: $e');
      }
    }

    return userType ?? 'student'; // Default to student if no userType found
  }

  /// Sign out method
  static Future<void> signOut() async {
    await _auth.signOut();
    await LocalData.clearUserData();
    Get.offAllNamed(AppRoutes.login);
  }
}
