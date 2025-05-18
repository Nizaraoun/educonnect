import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessageModel {
  final String id;
  final String groupId; // ID of the group this message belongs to
  final String senderId; // User ID of the sender
  final String senderName; // Name of the sender
  final String message; // Message content
  final DateTime timestamp; // Message timestamp
  final String? attachment; // Optional attachment URL (e.g., image, file)

  ChatMessageModel({
    required this.id,
    required this.groupId,
    required this.senderId,
    required this.senderName,
    required this.message,
    required this.timestamp,
    this.attachment,
  });

  // Create a ChatMessageModel from Firebase document
  factory ChatMessageModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return ChatMessageModel(
      id: doc.id,
      groupId: data['groupId'] ?? '',
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? '',
      message: data['message'] ?? '',
      timestamp: data['timestamp'] != null
          ? (data['timestamp'] as Timestamp).toDate()
          : DateTime.now(),
      attachment: data['attachment'],
    );
  }

  // Convert ChatMessageModel to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'groupId': groupId,
      'senderId': senderId,
      'senderName': senderName,
      'message': message,
      'timestamp': Timestamp.fromDate(timestamp),
      'attachment': attachment,
    };
  }
}

// Forum model represents a chat forum for a group
class ForumModel {
  final String id; // Same as group ID
  final String groupName; // Name of the group
  final List<String> memberIds; // Members who can access the forum
  final DateTime createdAt; // Forum creation date
  final bool isActive; // Whether the forum is active

  ForumModel({
    required this.id,
    required this.groupName,
    required this.memberIds,
    required this.createdAt,
    this.isActive = true,
  });

  // Create a ForumModel from Firebase document
  factory ForumModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return ForumModel(
      id: doc.id,
      groupName: data['groupName'] ?? '',
      memberIds: List<String>.from(data['memberIds'] ?? []),
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      isActive: data['isActive'] ?? true,
    );
  }

  // Convert ForumModel to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'groupName': groupName,
      'memberIds': memberIds,
      'createdAt': Timestamp.fromDate(createdAt),
      'isActive': isActive,
    };
  }
}
