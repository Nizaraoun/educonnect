import 'package:cloud_firestore/cloud_firestore.dart';

class DocumentFileModel {
  final String id;
  final String name;
  final String folderId;
  final String userId;
  final String url;
  final String type; // "pdf" or "image"
  final DateTime createdAt;
  final String? sharedBy; // ID of user who shared this document
  final String? originalDocumentId; // Original document ID if this is shared

  DocumentFileModel({
    required this.id,
    required this.name,
    required this.folderId,
    required this.userId,
    required this.url,
    required this.type,
    required this.createdAt,
    this.sharedBy,
    this.originalDocumentId,
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
      sharedBy: data['sharedBy'],
      originalDocumentId: data['originalDocumentId'],
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
      if (sharedBy != null) 'sharedBy': sharedBy,
      if (originalDocumentId != null) 'originalDocumentId': originalDocumentId,
    };
  }
}
