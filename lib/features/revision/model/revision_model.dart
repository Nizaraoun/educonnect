import 'package:flutter/material.dart';

class RevisionModel {
  final String id;
  final String title;
  final String subject;
  final String description;
  final DateTime date;
  final DateTime deadlineDate;
  final String duration;
  final String status;
  final int priority;
  final List<String> topics;
  final int completionPercentage;
  final int maxGroupe; // Added maxGroupe property for group saturation
  final int currentMembers; // Added currentMembers to track actual members

  RevisionModel({
    required this.id,
    required this.title,
    required this.subject,
    required this.description,
    required this.date,
    required this.deadlineDate,
    required this.duration,
    required this.status,
    required this.priority,
    required this.topics,
    required this.completionPercentage,
    this.maxGroupe = 30, // Default max members is 30
    this.currentMembers = 0, // Default current members is 0
  });

  // Factory constructor to create a RevisionModel from a Firebase document
  factory RevisionModel.fromJson(Map<String, dynamic> json) {
    return RevisionModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      subject: json['subject'] ?? '',
      description: json['description'] ?? '',
      date:
          json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      deadlineDate: json['deadlineDate'] != null
          ? DateTime.parse(json['deadlineDate'])
          : DateTime.now().add(const Duration(days: 7)),
      duration: json['duration'] ?? '',
      status: json['status'] ?? 'À faire',
      priority: json['priority'] ?? 1,
      topics: List<String>.from(json['topics'] ?? []),
      completionPercentage: json['completionPercentage'] ?? 0,
      maxGroupe: json['maxGroupe'] ?? 30,
      currentMembers: json['currentMembers'] ?? 0,
    );
  }

  // Convert RevisionModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subject': subject,
      'description': description,
      'date': date.toIso8601String(),
      'deadlineDate': deadlineDate.toIso8601String(),
      'duration': duration,
      'status': status,
      'priority': priority,
      'topics': topics,
      'completionPercentage': completionPercentage,
      'maxGroupe': maxGroupe,
      'currentMembers': currentMembers,
    };
  }

  // Calculate group saturation percentage
  int get saturationPercentage {
    if (maxGroupe <= 0) return 100; // Avoid division by zero
    return ((currentMembers / maxGroupe) * 100).round().clamp(0, 100);
  }
}
