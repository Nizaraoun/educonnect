import 'package:flutter/material.dart';
import 'package:get/get.dart';

showSnackError(String title, String message) {
  Get.snackbar(
    title,
    message,
    boxShadows: [
      BoxShadow(
        color: Colors.black.withOpacity(0.25),
        spreadRadius: 0,
        blurRadius: 2,
        offset: const Offset(0, 4),
      ),
    ],
    animationDuration: const Duration(seconds: 2),
    titleText: Text(
      title,
      style: const TextStyle(
        color: Color.fromARGB(255, 4, 4, 4),
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    ),
    duration: const Duration(seconds: 2),
    overlayBlur: 2,
  );
}
