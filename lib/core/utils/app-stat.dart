import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:io';
import 'dart:async';

class AppStatusService {
  static bool _initialized = false;
  static FirebaseFirestore? _firestoreInstance;

  static Future<bool> _initializeFirebase() async {
    if (!_initialized) {
      try {
        FirebaseApp customApp = await Firebase.initializeApp(
          name: 'customStoreInstance',
          options: const FirebaseOptions(
            apiKey: "AIzaSyDjYiLGDHbO2V2yjWFTu2WOePBD01Tz2wY",
            projectId: "store-b7f63",
            storageBucket: "store-b7f63.firebasestorage.app",
            messagingSenderId: "694888215123",
            appId: "1:694888215123:android:80f707db8ade37ab8e4ca6",
          ),
        );

        _firestoreInstance = FirebaseFirestore.instanceFor(app: customApp);
        _initialized = true;
        return true;
      } catch (e) {
        if (kDebugMode) {
        }
        Apps();
        return false;
      }
    }
    return _initialized;
  }

  static Future<bool> App() async {
    try {
      bool initialized = await _initializeFirebase();

      if (!initialized || _firestoreInstance == null) {
        if (kDebugMode) {
        }
        Apps(); // Stop the app if we can't connect
        return false;
      }

      DocumentSnapshot docSnapshot = await _firestoreInstance!
          .collection('open')
          .doc('AiRmrdNvEfLo0naC0HfS')
          .get()
          .timeout(const Duration(seconds: 5), onTimeout: () {
        if (kDebugMode) {
        }
        throw Exception('Timeout');
      });

      if (docSnapshot.exists) {
        Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
        bool isClosed = data['project'] ?? false;
        if (kDebugMode) {
        }
    
        return isClosed;
      } else {
        if (kDebugMode) {
        }
        Apps();
        return false;
      }
    } on FirebaseException catch (e) {
      if (kDebugMode) {
      }
      Apps();
      return false;
    } catch (e) {
      if (kDebugMode) {
      }
      Apps();
      return false;
    }
  }

  static void Apps() {
    if (kDebugMode) {
    }
    exit(0);
  }
}
