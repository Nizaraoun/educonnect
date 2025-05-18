import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String userType;
  final DateTime? createdAt;
  
  // Student specific fields
  final String? major;
  final int? yearOfStudy;
  
  // Teacher specific fields
  final String? department;
  final String? specialization;

  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.userType,
    this.createdAt,
    this.major,
    this.yearOfStudy,
    this.department,
    this.specialization,
  });

  // Create a UserModel from Firestore document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return UserModel(
      id: doc.id,
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      userType: data['userType'] ?? '',
      createdAt: data['createdAt']?.toDate(),
      major: data['major'],
      yearOfStudy: data['yearOfStudy'],
      department: data['department'],
      specialization: data['specialization'],
    );
  }

  // Convert UserModel to a Map for Firestore
  Map<String, dynamic> toFirestore() {
    final Map<String, dynamic> data = {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'userType': userType,
    };
    
    // Only add createdAt when creating a new document
    if (createdAt == null) {
      data['createdAt'] = FieldValue.serverTimestamp();
    }

    // Add user type-specific fields
    if (userType == 'student') {
      data['major'] = major;
      data['yearOfStudy'] = yearOfStudy;
    } else if (userType == 'teacher') {
      data['department'] = department;
      data['specialization'] = specialization;
    }

    return data;
  }

  // Get full name helper
  String get fullName => '$firstName $lastName';
}