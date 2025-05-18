import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:educonnect/features/authentification/model/userdata.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/themes/color_mangers.dart';
import '../../../widgets/icons/custom_button.dart';
import '../../../core/utils/localData.dart';
import '../model/notification.dart';

class HomeController extends GetxController {
  final LocalData localData = LocalData();

  final RxBool isLoading = false.obs;
  final RxBool isLoadingAnnouncements = false.obs;
  final RxMap<String, dynamic> userData = <String, dynamic>{}.obs;
  var notifications = <NotificationModel>[].obs;
  var announcements = <DocumentSnapshot>[].obs;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();
    getUserData();
    loadNotifications();
    fetchAnnouncements();
  }

  Future<void> getUserData() async {
    isLoading.value = true;
    try {
      userData.value = await LocalData.getUserData();
    } catch (e) {
      // Handle error
      print("Error fetching user data: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void loadNotifications() {
    // Static notifications data
    notifications.value = [
      NotificationModel(
        id: '1',
        title: 'Session de révision planifiée',
        content:
            'Une nouvelle session de révision pour le cours de Mathématiques a été planifiée pour demain à 14h.',
        type: 'SessionRevision',
        dateCreation: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      NotificationModel(
        id: '2',
        title: 'Nouveau document partagé',
        content:
            'Votre professeur a partagé un nouveau document dans le cours de Programmation.',
        type: 'Document',
        dateCreation: DateTime.now().subtract(const Duration(days: 1)),
      ),
      NotificationModel(
        id: '3',
        title: 'Événement à venir',
        content:
            'N\'oubliez pas la conférence sur l\'Intelligence Artificielle ce vendredi à 18h.',
        type: 'Evenement',
        dateCreation: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];
  }

  void markAsRead(String notificationId) {
    final index = notifications
        .indexWhere((notification) => notification.id == notificationId);
    if (index != -1) {
      var updatedNotification = NotificationModel(
        id: notifications[index].id,
        title: notifications[index].title,
        content: notifications[index].content,
        type: notifications[index].type,
        dateCreation: notifications[index].dateCreation,
        isRead: true,
        imageUrl: notifications[index].imageUrl,
      );
      notifications[index] = updatedNotification;
    }
  }

  Future<void> fetchAnnouncements() async {
    isLoadingAnnouncements.value = true;
    try {
      // Get user ID if needed for filtering
      String? userId;
      if (userData.containsKey('uid')) {
        userId = userData['uid'];
      }

      QuerySnapshot snapshot;

      // Fetch announcements - you could filter by user or other criteria
      snapshot = await _firestore
          .collection('announcements')
          .orderBy('createdAt', descending: true)
          .limit(10)
          .get();

      announcements.value = snapshot.docs;
    } catch (e) {
      print('Error fetching announcements: $e');
    } finally {
      isLoadingAnnouncements.value = false;
    }
  }

  Future<void> markAnnouncementAsRead(String announcementId) async {
    try {
      // Find the announcement in the list
      final index = announcements.indexWhere((doc) => doc.id == announcementId);
      if (index != -1) {
        // Update in Firestore
        await _firestore
            .collection('announcements')
            .doc(announcementId)
            .update({'isRead': true});

        // Optional: Refresh the announcements to reflect changes
        fetchAnnouncements();
      }
    } catch (e) {
      print('Error marking announcement as read: $e');
    }
  }
}

class HomecontrollerImp extends HomeController {}
