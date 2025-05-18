import 'package:cloud_firestore/cloud_firestore.dart';

class FolderModel {
  final String id;
  final String name;
  final String userId;
  final DateTime createdAt;

  FolderModel({
    required this.id,
    required this.name,
    required this.userId,
    required this.createdAt,
  });

  // Create a FolderModel from Firestore document
  factory FolderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return FolderModel(
      id: doc.id,
      name: data['name'] ?? 'Untitled Folder',
      userId: data['userId'] ?? '',
      createdAt: data['createdAt']?.toDate() ?? DateTime.now(),
    );
  }

  // Convert FolderModel to a Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'userId': userId,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
