import 'package:cloud_firestore/cloud_firestore.dart';

class GroupModel {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final String category;
  final String creatorId;
  final String creatorName;
  final List<String> memberIds;
  final List<String> adminIds;
  final int memberCount;
  final DateTime createdAt;
  final DateTime lastActivity;
  final bool isPublic;
  final bool hasChat;
  final String invitationCode;
  final int maxMembers; // Added maximum members variable

  GroupModel({
    required this.id,
    required this.name,
    required this.description,
    this.imageUrl = '',
    required this.category,
    required this.creatorId,
    required this.creatorName,
    required this.memberIds,
    required this.adminIds,
    required this.memberCount,
    required this.createdAt,
    required this.lastActivity,
    this.isPublic = true,
    this.hasChat = true,
    this.invitationCode = '',
    this.maxMembers = 30, // Default max members is 30
  });

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    return GroupModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      category: json['category'] ?? 'Général',
      creatorId: json['creatorId'] ?? '',
      creatorName: json['creatorName'] ?? 'Utilisateur',
      memberIds: List<String>.from(json['memberIds'] ?? []),
      adminIds: List<String>.from(json['adminIds'] ?? []),
      memberCount: json['memberCount'] ?? 0,
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastActivity:
          (json['lastActivity'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isPublic: json['isPublic'] ?? true,
      hasChat: json['hasChat'] ?? true,
      invitationCode: json['invitationCode'] ?? '',
      maxMembers: json['maxMembers'] ?? 30, // Default max members is 30
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'category': category,
      'creatorId': creatorId,
      'creatorName': creatorName,
      'memberIds': memberIds,
      'adminIds': adminIds,
      'memberCount': memberCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastActivity': Timestamp.fromDate(lastActivity),
      'isPublic': isPublic,
      'hasChat': hasChat,
      'invitationCode': invitationCode,
      'maxMembers': maxMembers,
    };
  }

  // Calculate group saturation percentage
  int get saturationPercentage {
    if (maxMembers <= 0) return 100; // Avoid division by zero
    return ((memberCount / maxMembers) * 100).round().clamp(0, 100);
  }
}

class RevisionGroupModel {
  final String id;
  final String parentGroupId;
  final String name;
  final String description;
  final String subject;
  final String creatorId;
  final String creatorName;
  final List<String> memberIds;
  final DateTime createdAt;
  final DateTime meetingDate;
  final String meetingTime;
  final String meetingLocation;
  final int memberCount;
  final int maxMembers; // Added maximum members variable

  RevisionGroupModel({
    required this.id,
    required this.parentGroupId,
    required this.name,
    required this.description,
    required this.subject,
    required this.creatorId,
    required this.creatorName,
    required this.memberIds,
    required this.createdAt,
    required this.meetingDate,
    required this.meetingTime,
    required this.meetingLocation,
    required this.memberCount,
    this.maxMembers = 20, // Default max members is 20 for revision groups
  });

  factory RevisionGroupModel.fromJson(Map<String, dynamic> json) {
    return RevisionGroupModel(
      id: json['id'] ?? '',
      parentGroupId: json['parentGroupId'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      subject: json['subject'] ?? '',
      creatorId: json['creatorId'] ?? '',
      creatorName: json['creatorName'] ?? 'Utilisateur',
      memberIds: List<String>.from(json['memberIds'] ?? []),
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      meetingDate:
          (json['meetingDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      meetingTime: json['meetingTime'] ?? '',
      meetingLocation: json['meetingLocation'] ?? '',
      memberCount: json['memberCount'] ?? 0,
      maxMembers: json['maxMembers'] ?? 20, // Default max members is 20
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'parentGroupId': parentGroupId,
      'name': name,
      'description': description,
      'subject': subject,
      'creatorId': creatorId,
      'creatorName': creatorName,
      'memberIds': memberIds,
      'createdAt': Timestamp.fromDate(createdAt),
      'meetingDate': Timestamp.fromDate(meetingDate),
      'meetingTime': meetingTime,
      'meetingLocation': meetingLocation,
      'memberCount': memberCount,
      'maxMembers': maxMembers,
    };
  }

  // Calculate group saturation percentage
  int get saturationPercentage {
    if (maxMembers <= 0) return 100; // Avoid division by zero
    return ((memberCount / maxMembers) * 100).round().clamp(0, 100);
  }
}

// Model for group announcements
class GroupAnnouncementModel {
  final String id;
  final String groupId;
  final String title;
  final String content;
  final String authorId;
  final String authorName;
  final DateTime createdAt;
  final List<String> attachments;

  GroupAnnouncementModel({
    required this.id,
    required this.groupId,
    required this.title,
    required this.content,
    required this.authorId,
    required this.authorName,
    required this.createdAt,
    this.attachments = const [],
  });

  // Factory constructor to create a GroupAnnouncementModel from a Firebase document
  factory GroupAnnouncementModel.fromJson(Map<String, dynamic> json) {
    return GroupAnnouncementModel(
      id: json['id'] ?? '',
      groupId: json['groupId'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      authorId: json['authorId'] ?? '',
      authorName: json['authorName'] ?? '',
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      attachments: List<String>.from(json['attachments'] ?? []),
    );
  }

  // Convert GroupAnnouncementModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'groupId': groupId,
      'title': title,
      'content': content,
      'authorId': authorId,
      'authorName': authorName,
      'createdAt': createdAt,
      'attachments': attachments,
    };
  }
}
