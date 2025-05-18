import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String title;
  final String content;
  final String type;
  final DateTime dateCreation;
  final bool isRead;
  final String? imageUrl;

  NotificationModel({
    required this.id,
    required this.title,
    required this.content,
    required this.type,
    required this.dateCreation,
    this.isRead = false,
    this.imageUrl,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      type: json['type'] ?? '',
      dateCreation: json['dateCreation'] is Timestamp
          ? (json['dateCreation'] as Timestamp).toDate()
          : json['dateCreation'] is String
              ? DateTime.parse(json['dateCreation'])
              : DateTime.now(),
      isRead: json['isRead'] ?? false,
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'type': type,
      'dateCreation': Timestamp.fromDate(dateCreation),
      'isRead': isRead,
      'imageUrl': imageUrl,
    };
  }

  NotificationModel copyWith({
    String? id,
    String? title,
    String? content,
    String? type,
    DateTime? dateCreation,
    bool? isRead,
    String? imageUrl,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      type: type ?? this.type,
      dateCreation: dateCreation ?? this.dateCreation,
      isRead: isRead ?? this.isRead,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
