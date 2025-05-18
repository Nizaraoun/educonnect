import 'package:cloud_firestore/cloud_firestore.dart';

class Announcement {
  final String id;
  final String groupId;
  final String authorId;
  final String authorName;
  final String content;
  final String? attachmentUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  Announcement({
    required this.id,
    required this.groupId,
    required this.authorId,
    required this.authorName,
    required this.content,
    this.attachmentUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      id: json['id'] ?? '',
      groupId: json['groupId'] ?? '',
      authorId: json['authorId'] ?? '',
      authorName: json['authorName'] ?? 'Utilisateur',
      content: json['content'] ?? '',
      attachmentUrl: json['attachmentUrl'],
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (json['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'groupId': groupId,
      'authorId': authorId,
      'authorName': authorName,
      'content': content,
      'attachmentUrl': attachmentUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}

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

  factory GroupAnnouncementModel.fromJson(Map<String, dynamic> json) {
    return GroupAnnouncementModel(
      id: json['id'] ?? '',
      groupId: json['groupId'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      authorId: json['authorId'] ?? '',
      authorName: json['authorName'] ?? 'Utilisateur',
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      attachments: (json['attachments'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'groupId': groupId,
      'title': title,
      'content': content,
      'authorId': authorId,
      'authorName': authorName,
      'createdAt': Timestamp.fromDate(createdAt),
      'attachments': attachments,
    };
  }
}

// Define the RevisionGroupModel class since it's used in the controller
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
  });

  // Create from JSON (for Firestore data)
  factory RevisionGroupModel.fromJson(Map<String, dynamic> json) {
    return RevisionGroupModel(
      id: json['id'] ?? '',
      parentGroupId: json['parentGroupId'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      subject: json['subject'] ?? '',
      creatorId: json['creatorId'] ?? '',
      creatorName: json['creatorName'] ?? 'Utilisateur',
      memberIds: (json['memberIds'] != null)
          ? List<String>.from(json['memberIds'])
          : [],
      createdAt: (json['createdAt'] is Timestamp)
          ? (json['createdAt'] as Timestamp).toDate()
          : (json['createdAt'] != null)
              ? DateTime.parse(json['createdAt'].toString())
              : DateTime.now(),
      meetingDate: (json['meetingDate'] is Timestamp)
          ? (json['meetingDate'] as Timestamp).toDate()
          : (json['meetingDate'] != null)
              ? DateTime.parse(json['meetingDate'].toString())
              : DateTime.now(),
      meetingTime: json['meetingTime'] ?? '',
      meetingLocation: json['meetingLocation'] ?? '',
      memberCount: json['memberCount'] ?? 0,
    );
  }

  // Convert to JSON (for Firestore storage)
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
      'createdAt': createdAt,
      'meetingDate': meetingDate,
      'meetingTime': meetingTime,
      'meetingLocation': meetingLocation,
      'memberCount': memberCount,
    };
  }
}
