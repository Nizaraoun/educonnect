import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:educonnect/features/document/model/folder_model.dart';
import 'package:educonnect/features/document/model/document_file_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DocumentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Create a new folder
  Future<FolderModel?> createFolder(String folderName) async {
    try {
      final userId = currentUserId;
      if (userId == null) return null;

      final folderId = const Uuid().v4();
      final folderModel = FolderModel(
        id: folderId,
        name: folderName,
        userId: userId,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('folders')
          .doc(folderId)
          .set(folderModel.toFirestore());

      return folderModel;
    } catch (e) {
      print('Error creating folder: $e');
      return null;
    }
  }

  // Get all folders for current user
  Stream<List<FolderModel>> getUserFolders() {
    final userId = currentUserId;
    if (userId == null) {
      return Stream.value([]);
    }

    try {
      // Simplified query without timestamp ordering to avoid index requirements
      return _firestore
          .collection('folders')
          .where('userId', isEqualTo: userId)
          .snapshots()
          .map((snapshot) {
        List<FolderModel> folders =
            snapshot.docs.map((doc) => FolderModel.fromFirestore(doc)).toList();

        // Sort in-memory instead of in the query
        folders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return folders;
      });
    } catch (e) {
      print('Error getting folders: $e');
      Get.snackbar(
        'Error',
        'Failed to load folders. Please create the required index in Firebase Console.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
        duration: Duration(seconds: 5),
      );
      return Stream.value([]);
    }
  }

  // Upload document to a folder
  Future<DocumentFileModel?> uploadDocument(
      File file, String folderId, String fileName) async {
    try {
      final userId = currentUserId;
      if (userId == null) return null;

      // Determine file type
      final String extension = path.extension(file.path).toLowerCase();
      final String type = (extension == '.pdf') ? 'pdf' : 'image';

      // Create a unique filename
      final String uniqueFileName =
          '${DateTime.now().millisecondsSinceEpoch}_$fileName';

      // Upload to Firebase Storage
      final storageRef = _storage
          .ref()
          .child('users/$userId/documents/$folderId/$uniqueFileName');

      final uploadTask = storageRef.putFile(file);
      final snapshot = await uploadTask;

      // Get download URL
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      // Create a new document record in Firestore
      final docId = const Uuid().v4();
      final docModel = DocumentFileModel(
        id: docId,
        name: fileName,
        folderId: folderId,
        userId: userId,
        url: downloadUrl,
        type: type,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('documents')
          .doc(docId)
          .set(docModel.toFirestore());

      return docModel;
    } catch (e) {
      print('Error uploading document: $e');
      return null;
    }
  }

  // Get all documents in a folder
  Stream<List<DocumentFileModel>> getFolderDocuments(String folderId) {
    final userId = currentUserId;
    if (userId == null) {
      return Stream.value([]);
    }

    try {
      // Simplified query to avoid index requirement
      return _firestore
          .collection('documents')
          .where('folderId', isEqualTo: folderId)
          .where('userId', isEqualTo: userId)
          .snapshots()
          .map((snapshot) {
        List<DocumentFileModel> documents = snapshot.docs
            .map((doc) => DocumentFileModel.fromFirestore(doc))
            .toList();

        // Sort in-memory instead of in the query
        documents.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return documents;
      });
    } catch (e) {
      print('Error getting documents: $e');
      Get.snackbar(
        'Error',
        'Failed to load documents. Please create the required index in Firebase Console.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
        duration: Duration(seconds: 5),
      );
      return Stream.value([]);
    }
  }

  // Delete a document
  Future<bool> deleteDocument(DocumentFileModel document) async {
    try {
      // Delete from Storage
      final storageRef = _storage.refFromURL(document.url);
      await storageRef.delete();

      // Delete from Firestore
      await _firestore.collection('documents').doc(document.id).delete();

      return true;
    } catch (e) {
      print('Error deleting document: $e');
      return false;
    }
  }

  // Delete a folder and all its documents
  Future<bool> deleteFolder(FolderModel folder) async {
    try {
      // Get all documents in this folder
      final querySnapshot = await _firestore
          .collection('documents')
          .where('folderId', isEqualTo: folder.id)
          .get();

      // Delete each document
      for (var doc in querySnapshot.docs) {
        final document = DocumentFileModel.fromFirestore(doc);
        await deleteDocument(document);
      }

      // Delete the folder
      await _firestore.collection('folders').doc(folder.id).delete();

      return true;
    } catch (e) {
      print('Error deleting folder: $e');
      return false;
    }
  }

  // Helper method to display the index creation link if needed
  void showIndexCreationHelp() {
    Get.dialog(
      AlertDialog(
        title: Text('Firestore Index Required'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('This feature requires a Firebase index to work properly.'),
            SizedBox(height: 12),
            Text('Please follow these steps:'),
            SizedBox(height: 8),
            Text('1. Click on the links in your error logs'),
            Text(
                '2. Create the suggested composite indexes in Firebase Console'),
            Text(
                '3. Wait for the indexes to be created (may take a few minutes)'),
            Text('4. Try using the feature again'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}
