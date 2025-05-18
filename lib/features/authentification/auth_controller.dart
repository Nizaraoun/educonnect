import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:educonnect/generated/l10n.dart';
import 'package:educonnect/routes/app_routing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/utils/localData.dart';
import 'login/login.dart';
import 'model/userdata.dart';

// Define a UserId typedef for consistent user ID handling
typedef UserId = String;

abstract class Authcontroller extends GetxController {
  // void singinwidget();
  // void singupwidget();
  // void back();
  login();
  signUp();
}

class AthControllerImp extends Authcontroller {
  GlobalKey<FormState> formstatelogin = GlobalKey<FormState>();
  GlobalKey<FormState> formstatesingup = GlobalKey<FormState>();
  GlobalKey<FormState> formstateotp = GlobalKey<FormState>();
  GlobalKey<FormState> newpassword = GlobalKey<FormState>();

  List<String> inputsignup = ["", "", "", "", "", "", ""];
  List<String> inputlogin = ["", ""];
  List<String> inputotp = ["", "", "", "", "", ""];
  List<String> inputnewpassword = ["", ""];

  // Convert normal variables to Rx variables
  RxString name = RxString("");
  RxString email = RxString("");
  RxString dateOfBirth = RxString("");
  RxString phone = RxString("");
  RxString id = RxString("");
  RxString image = RxString("");
  RxString token = RxString("");

  final Rx<String?> userType = Rx<String?>('student');

  RxString major = RxString("");
  RxInt yearOfStudy = RxInt(0);
  RxString department = RxString("");
  RxString specialization = RxString("");

  // Loading state
  RxBool isLoading = false.obs;

  @override
  signUp() async {
    var formdata = formstatesingup.currentState;
    if (formdata!.validate()) {
      try {
        isLoading.value = true;

        // Collect user data
        String firstName = inputsignup[0];
        String lastName = inputsignup[1];
        String userEmail = inputsignup[2];
        String userPhone = inputsignup[3];
        String password = inputsignup[6];

        // Set user type-specific fields
        if (userType.value == 'student') {
          major.value = inputsignup[4];
          yearOfStudy.value = int.tryParse(inputsignup[5]) ?? 0;
        } else if (userType.value == 'teacher') {
          department.value = inputsignup[4];
          specialization.value = inputsignup[5];
        }

        // Register user with Firebase Auth
        await registerUser(
          firstName: firstName,
          lastName: lastName,
          email: userEmail,
          phone: userPhone,
          password: password,
        );
      } catch (e) {
        Get.snackbar(
          'Erreur',
          'Échec de l\'inscription : ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      } finally {
        isLoading.value = false;
      }
    }
  }

  Future<void> registerUser({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      // Create user with email and password
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Get the user ID
      String uid = userCredential.user!.uid;

      UserModel newUser = UserModel(
        id: uid,
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
        userType: userType.value ?? 'student',
        major: userType.value == 'student' ? major.value : null,
        yearOfStudy: userType.value == 'student' ? yearOfStudy.value : null,
        department: userType.value == 'teacher' ? department.value : null,
        specialization:
            userType.value == 'teacher' ? specialization.value : null,
      );

      // Save to Firestore using the model
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set(newUser.toFirestore());

      // Save basic user info to local storage      // Update display name
      await userCredential.user!.updateDisplayName(newUser.fullName);

      // Show success message
      Get.snackbar(
        'Succès',
        'Compte créé avec succès !',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Navigate to login screen
      Get.offAllNamed(AppRoutes.login);
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Une erreur est survenue lors de l\'inscription';

      if (e.code == 'weak-password') {
        errorMessage = 'Le mot de passe fourni est trop faible.';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'Un compte existe déjà pour cet email.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'L\'adresse email n\'est pas valide.';
      }

      Get.snackbar(
        'Échec de l\'inscription',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );

      throw Exception(errorMessage);
    } catch (e) {
      print('Unexpected error: $e');
      throw Exception('Registration failed due to an unexpected error.');
    }
  }

  @override
  login() async {
    var formdata = formstatelogin.currentState;
    if (formdata!.validate()) {
      try {
        isLoading.value = true;

        String email = inputlogin[0];
        String password = inputlogin[1];

        UserCredential userCredential =
            await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Get user data from Firestore
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .get();

        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        String userType = userData['userType'] ?? 'student';

        // Save user data to local storage using LocalData class
        await LocalData.saveUserData(
          id: userCredential.user!.uid,
          firstName: userData['firstName'] ?? '',
          lastName: userData['lastName'] ?? '',
          email: userData['email'] ?? '',
          phone: userData['phone'] ?? '',
          userType: userType,
          major: userType == 'student' ? userData['major'] : null,
          yearOfStudy: userType == 'student' ? userData['yearOfStudy'] : null,
          department: userType == 'teacher' ? userData['department'] : null,
          specialization:
              userType == 'teacher' ? userData['specialization'] : null,
        );

        String? token = await userCredential.user?.getIdToken();
        if (token != null) {
          await LocalData.saveToken(token);
        }
        await LocalData.saveUserId(userCredential.user!.uid);

        // Redirect based on user type
        if (userType == 'teacher') {
          Get.offAllNamed(AppRoutes.teacherHome);
        } else {
          Get.offAllNamed(AppRoutes.dashboard);
        }
      } on FirebaseAuthException catch (e) {
        String errorMessage = 'Échec de la connexion';

        if (e.code == 'user-not-found') {
          errorMessage = 'Aucun utilisateur trouvé pour cet email.';
        } else if (e.code == 'wrong-password') {
          errorMessage = 'Mot de passe incorrect.';
        }

        Get.snackbar(
          'Échec de la connexion',
          errorMessage,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      } catch (e) {
        Get.snackbar(
          'Erreur',
          'Échec de la connexion : ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      } finally {
        isLoading.value = false;
      }
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      Get.snackbar(
        'Succès',
        'Un email de réinitialisation de mot de passe a été envoyé.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      Get.offAllNamed(AppRoutes.login);
    } on FirebaseAuthException catch (e) {
      String errorMessage =
          'Une erreur est survenue lors de la réinitialisation';

      if (e.code == 'user-not-found') {
        errorMessage = 'Aucun utilisateur trouvé pour cet email.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'L\'adresse email n\'est pas valide.';
      }

      Get.snackbar(
        'Échec de la réinitialisation',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Échec de la réinitialisation : ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
