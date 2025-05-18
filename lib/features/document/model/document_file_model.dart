import 'package:cloud_firestore/cloud_firestore.dart';

class DocumentFileModel {
  final String id;
  final String name;
  final String folderId;
  final String userId;
  final String url;
  final String type; // "pdf" or "image"
  final DateTime createdAt;

  DocumentFileModel({
    required this.id,
    required this.name,
    required this.folderId,
    required this.userId,
    required this.url,
    required this.type,
    required this.createdAt,
  });

  // Create a DocumentFileModel from Firestore document
  factory DocumentFileModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return DocumentFileModel(
      id: doc.id,
      name: data['name'] ?? 'Untitled Document',
      folderId: data['folderId'] ?? '',
      userId: data['userId'] ?? '',
      url: data['url'] ?? '',
      type: data['type'] ?? 'unknown',
      createdAt: data['createdAt']?.toDate() ?? DateTime.now(),
    );
  }

  // Convert DocumentFileModel to a Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'folderId': folderId,
      'userId': userId,
      'url': url,
      'type': type,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
