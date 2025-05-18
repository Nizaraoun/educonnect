import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/userInfo.dart';

class PersonalInformationController extends GetxController {
  final personalInfo = PersonalInformation().obs;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final RxBool isLoading = false.obs;

  // Get current user ID
  String? get userId => _auth.currentUser?.uid;

  void updatePersonalInfo({
    String? fullName,
    DateTime? birthDate,
    String? gender,
    String? maritalStatus,
    int? dependents,
    bool? hasVehicle,
  }) {
    personalInfo.update((info) {
      info?.fullName = fullName ?? info.fullName;
      info?.birthDate = birthDate ?? info.birthDate;
      info?.gender = gender ?? info.gender;
      info?.maritalStatus = maritalStatus ?? info.maritalStatus;
      info?.dependents = dependents ?? info.dependents;
      info?.hasVehicle = hasVehicle ?? info.hasVehicle;
    });
  }

 double? safeParseDouble(String value) {
  if (value.isEmpty) {
    return null;
  }
  
  try {
    return double.parse(value.replaceAll(' ', '').replaceAll(',', '.'));
  } catch (e) {
    print('Error parsing double: $e');
    return null;
  }
}
// Helper method to safely parse int values
int? safeParseInt(String value) {
  if (value.isEmpty) {
    return null;
  }
  
  try {
    return int.parse(value.replaceAll(' ', ''));
  } catch (e) {
    print('Error parsing int: $e');
    return null;
  }
}

// Update your methods to use these safe parsers
void updateVehicleInfo({
  String? brand,
  String? model,
  String? acquisitionYearStr,
  String? estimatedValueStr,
  bool? isFinanced,
}) {
  // Parse numeric values safely
  int? acquisitionYear = acquisitionYearStr != null 
      ? safeParseInt(acquisitionYearStr) 
      : null;
  
  double? estimatedValue = estimatedValueStr != null 
      ? safeParseDouble(estimatedValueStr) 
      : null;

  if (personalInfo.value.vehicle == null) {
    personalInfo.value.vehicle = Vehicle();
  }
  
  personalInfo.update((info) {
    info?.vehicle?.brand = brand ?? info.vehicle?.brand;
    info?.vehicle?.model = model ?? info.vehicle?.model;
    info?.vehicle?.acquisitionYear = acquisitionYear ?? info.vehicle?.acquisitionYear;
    info?.vehicle?.estimatedValue = estimatedValue ?? info.vehicle?.estimatedValue;
    info?.vehicle?.isFinanced = isFinanced ?? info.vehicle?.isFinanced;
  });
}
  void updateProfessionalInfo({
    String? profession,
    String? sector,
    String? employer,
    String? contractType,
    int? yearsOfService,
  }) {
    if (personalInfo.value.professional == null) {
      personalInfo.value.professional = Professional();
    }
    personalInfo.update((info) {
      info?.professional?.profession =
          profession ?? info.professional?.profession;
      info?.professional?.sector = sector ?? info.professional?.sector;
      info?.professional?.employer = employer ?? info.professional?.employer;
      info?.professional?.contractType =
          contractType ?? info.professional?.contractType;
      info?.professional?.yearsOfService =
          yearsOfService ?? info.professional?.yearsOfService;
    });
  }
void updateFinancialInfo({
  String? monthlyNetSalaryStr,
  String? additionalIncomeStr,
  String? fixedChargesStr,
}) {
  // Parse numeric values safely
  double? monthlyNetSalary = monthlyNetSalaryStr != null 
      ? safeParseDouble(monthlyNetSalaryStr) 
      : null;
  
  double? additionalIncome = additionalIncomeStr != null 
      ? safeParseDouble(additionalIncomeStr) 
      : null;
  
  double? fixedCharges = fixedChargesStr != null 
      ? safeParseDouble(fixedChargesStr) 
      : null;

  if (personalInfo.value.financial == null) {
    personalInfo.value.financial = Financial();
  }
  
  personalInfo.update((info) {
    info?.financial?.monthlyNetSalary = monthlyNetSalary ?? info.financial?.monthlyNetSalary;
    info?.financial?.additionalIncome = additionalIncome ?? info.financial?.additionalIncome;
    info?.financial?.fixedCharges = fixedCharges ?? info.financial?.fixedCharges;
  });
}

// Add this method to your PersonalInformationController class

bool validateForm() {
  if (personalInfo.value.fullName == null || personalInfo.value.fullName!.isEmpty) {
    Get.snackbar(
      'Erreur de validation',
      'Veuillez entrer votre nom complet',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.withOpacity(0.8),
      colorText: Colors.white
    );
    return false;
  }

  if (personalInfo.value.gender == null) {
    Get.snackbar(
      'Erreur de validation',
      'Veuillez sélectionner votre genre',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.withOpacity(0.8),
      colorText: Colors.white
    );
    return false;
  }

  if (personalInfo.value.maritalStatus == null) {
    Get.snackbar(
      'Erreur de validation',
      'Veuillez sélectionner votre statut marital',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.withOpacity(0.8),
      colorText: Colors.white
    );
    return false;
  }

  // Validate vehicle information if the user has a vehicle
  if (personalInfo.value.hasVehicle == true) {
    if (personalInfo.value.vehicle?.brand == null || personalInfo.value.vehicle!.brand!.isEmpty) {
      Get.snackbar(
        'Erreur de validation',
        'Veuillez entrer la marque de votre véhicule',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white
      );
      return false;
    }

    if (personalInfo.value.vehicle?.model == null || personalInfo.value.vehicle!.model!.isEmpty) {
      Get.snackbar(
        'Erreur de validation',
        'Veuillez entrer le modèle de votre véhicule',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white
      );
      return false;
    }
  }

  // Validate professional information
  if (personalInfo.value.professional?.profession == null || 
      personalInfo.value.professional!.profession!.isEmpty) {
    Get.snackbar(
      'Erreur de validation',
      'Veuillez entrer votre profession',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.withOpacity(0.8),
      colorText: Colors.white
    );
    return false;
  }

  // Validate financial information
  if (personalInfo.value.financial?.monthlyNetSalary == null) {
    Get.snackbar(
      'Erreur de validation',
      'Veuillez entrer votre salaire mensuel net',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.withOpacity(0.8),
      colorText: Colors.white
    );
    return false;
  }

  return true;
}

// Update your submitForm method to use the validation
Future<void> submitForm() async {
  try {
    // Validate form
    if (!validateForm()) {
      return;
    }
    
    // Set loading state
    isLoading.value = true;
    
    // Check if user is authenticated
    if (userId == null) {
      Get.snackbar(
        'Erreur', 
        'Vous devez être connecté pour soumettre vos informations',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white
      );
      return;
    }
    
    // Convert personal info to JSON
    final userData = personalInfo.value.toJson();
    
    // Add timestamp
    userData['updatedAt'] = FieldValue.serverTimestamp();
    
    // Save to Firestore
    await _firestore.collection('users').doc(userId).set(
      userData,
      SetOptions(merge: true), // This will merge data with existing document
    );
    
    Get.snackbar(
      'Succès', 
      'Vos informations ont été enregistrées avec succès',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.withOpacity(0.8),
      colorText: Colors.white
    );
    
    // Optionally navigate back or to another screen
    // Get.back();
  } catch (e) {
    Get.snackbar(
      'Erreur', 
      'Une erreur est survenue: ${e.toString()}',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.withOpacity(0.8),
      colorText: Colors.white
    );
    print('Error saving data: $e');
  } finally {
    isLoading.value = false;
  }
}


}
