import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalData {
  // User data methods
  static Future<void> saveUserData({
    required String id,
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String userType,
    String? major,
    int? yearOfStudy,
    String? department,
    String? specialization,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('id', id);
    await prefs.setString('firstName', firstName);
    await prefs.setString('lastName', lastName);
    await prefs.setString('email', email);
    await prefs.setString('phone', phone);
    await prefs.setString('userType', userType);

    // Store user type-specific fields
    if (userType == 'student') {
      if (major != null) await prefs.setString('major', major);
      if (yearOfStudy != null) await prefs.setInt('yearOfStudy', yearOfStudy);
    } else if (userType == 'teacher') {
      if (department != null) await prefs.setString('department', department);
      if (specialization != null)
        await prefs.setString('specialization', specialization);
    }
  }

  static Future<Map<String, dynamic>> getUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userType = prefs.getString('userType') ?? 'student';

    Map<String, dynamic> userData = {
      'id': prefs.getString('id') ?? '',
      'firstName': prefs.getString('firstName') ?? '',
      'lastName': prefs.getString('lastName') ?? '',
      'email': prefs.getString('email') ?? '',
      'phone': prefs.getString('phone') ?? '',
      'userType': userType,
    };

    // Add user type-specific fields
    if (userType == 'student') {
      userData['major'] = prefs.getString('major') ?? '';
      userData['yearOfStudy'] = prefs.getInt('yearOfStudy') ?? 0;
    } else if (userType == 'teacher') {
      userData['department'] = prefs.getString('department') ?? '';
      userData['specialization'] = prefs.getString('specialization') ?? '';
    }
    print(userData);
    return userData;
  }

  static Future<String?> getCardDataByName(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  // Token methods - Kept from original
  static Future<void> saveToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  static Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // User ID methods - Kept from original
  static Future<void> saveUserId(String userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userId);
  }

  static Future<String?> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  // Clear data method - Kept from original
  static Future<bool> clearUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.clear();
  }
}
