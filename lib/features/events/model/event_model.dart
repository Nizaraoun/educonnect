import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String startTime;
  final String endTime;
  final String location;
  final String category;
  final int participants;
  final String organizerId;
  final String organizerName;
  final bool isUserParticipating;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.location,
    required this.category,
    required this.participants,
    required this.organizerId,
    required this.organizerName,
    this.isUserParticipating = false,
  });

  // Factory constructor to create an EventModel from a Firebase document
  factory EventModel.fromJson(Map<String, dynamic> json) {
    // Handle date conversion properly
    DateTime eventDate = DateTime.now();
    if (json['date'] != null) {
      if (json['date'] is DateTime) {
        // If it's already a DateTime (from the service class)
        eventDate = json['date'];
      } else if (json['date'] is Timestamp) {
        // If it's a Firestore Timestamp
        eventDate = (json['date'] as Timestamp).toDate();
      } else if (json['date'] is String) {
        // If it's a String (ISO format)
        eventDate = DateTime.parse(json['date']);
      }
    }

    return EventModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      date: eventDate,
      startTime: json['startTime'] ?? '',
      endTime: json['endTime'] ?? '',
      location: json['location'] ?? '',
      category: json['category'] ?? '',
      participants: json['participants'] ?? 0,
      organizerId: json['organizerId'] ?? '',
      organizerName: json['organizerName'] ?? '',
      isUserParticipating: json['isUserParticipating'] ?? false,
    );
  }

  // Convert EventModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'startTime': startTime,
      'endTime': endTime,
      'location': location,
      'category': category,
      'participants': participants,
      'organizerId': organizerId,
      'organizerName': organizerName,
      'isUserParticipating': isUserParticipating,
    };
  }
}
