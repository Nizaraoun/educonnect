import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import '../../../core/utils/localData.dart';

class ProfileDetailsController extends GetxController {
  final RxMap<String, dynamic> userData = <String, dynamic>{}.obs;
  final RxString invitationCode = ''.obs;
  final RxBool isLoading = false.obs;
  final RxBool isGeneratingCode = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserData();
    fetchInvitationCode();
  }

  Future<void> loadUserData() async {
    isLoading.value = true;
    try {
      userData.value = await LocalData.getUserData();
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de charger les données utilisateur',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchInvitationCode() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      final docSnapshot = await FirebaseFirestore.instance
          .collection('invitations')
          .doc(userId)
          .get();

      if (docSnapshot.exists && docSnapshot.data() != null) {
        invitationCode.value = docSnapshot.data()!['code'] ?? '';
      }
    } catch (e) {
      print('Error fetching invitation code: $e');
    }
  }

  Future<void> generateInvitationCode() async {
    isGeneratingCode.value = true;
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        Get.snackbar(
          'Erreur',
          'Vous devez être connecté pour générer un code',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.7),
          colorText: Colors.white,
        );
        return;
      }

      // Generate a unique code using UUID
      final uuid = Uuid();
      final code = uuid.v4().substring(0, 8).toUpperCase();

      // Save to Firestore
      await FirebaseFirestore.instance.collection('invitations').doc(userId).set({
        'code': code,
        'userId': userId,
        'userName': '${userData['firstName']} ${userData['lastName']}',
        'createdAt': FieldValue.serverTimestamp(),
        'isActive': true,
      });

      // Update the local value
      invitationCode.value = code;

      Get.snackbar(
        'Succès',
        'Code d\'invitation généré avec succès',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.7),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de générer le code d\'invitation',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
      );
    } finally {
      isGeneratingCode.value = false;
    }
  }
}