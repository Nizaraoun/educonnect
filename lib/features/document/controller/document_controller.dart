import 'dart:io';
import 'package:educonnect/features/document/model/document_file_model.dart';
import 'package:educonnect/features/document/model/folder_model.dart';
import 'package:educonnect/features/document/service/document_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as path;
import 'package:cloud_firestore/cloud_firestore.dart';

class DocumentController extends GetxController {
  final DocumentService _documentService = DocumentService();
  final RxList<FolderModel> folders = <FolderModel>[].obs;
  final RxList<DocumentFileModel> currentFolderDocuments =
      <DocumentFileModel>[].obs;
  final RxList<DocumentFileModel> sharedDocuments = <DocumentFileModel>[].obs;
  final RxString selectedFolderId = ''.obs;
  final RxBool isLoading = false.obs;
  final RxBool isUploading = false.obs;
  final RxBool hasError = false.obs;
  final RxBool isSharing = false.obs;
  final RxBool isShowingSharedDocs = false.obs;

  // Cache for user names to avoid repeated Firestore queries
  final RxMap<String, String> userNameCache = <String, String>{}.obs;

  // Text controller for invitation code
  final TextEditingController invitationCodeController =
      TextEditingController();

  @override
  void onInit() {
    super.onInit();
    // Load all folders for the current user
    _loadFolders();
    // Load shared documents
    _loadSharedDocuments();
  }

  // Get user name by ID (with caching for better performance)
  Future<String> getUserNameById(String? userId) async {
    if (userId == null) return 'Utilisateur inconnu';

    // Check if it's already in cache
    if (userNameCache.containsKey(userId)) {
      return userNameCache[userId]!;
    }

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (userDoc.exists) {
        final userData = userDoc.data();
        final String firstName = userData?['firstName'] ?? '';
        final String lastName = userData?['lastName'] ?? '';
        final String fullName = '$firstName $lastName'.trim();

        // Cache the result
        userNameCache[userId] =
            fullName.isNotEmpty ? fullName : 'Utilisateur inconnu';
        return userNameCache[userId]!;
      }

      userNameCache[userId] = 'Utilisateur inconnu';
      return 'Utilisateur inconnu';
    } catch (e) {
      print('Error getting user name: $e');
      userNameCache[userId] = 'Utilisateur inconnu';
      return 'Utilisateur inconnu';
    }
  }

  @override
  void onClose() {
    invitationCodeController.dispose();
    super.onClose();
  }

  void _loadFolders() {
    try {
      // Subscribe to the user folders stream
      _documentService.getUserFolders().listen((foldersList) {
        folders.value = foldersList;
        hasError.value = false;
      }, onError: (error) {
        print('Error loading folders: $error');
        hasError.value = true;
        // Show the index creation help
        _documentService.showIndexCreationHelp();
      });
    } catch (e) {
      print('Exception in _loadFolders: $e');
      hasError.value = true;
    }
  }

  // Load shared documents for the current user
  void loadSharedDocuments() {
    isLoading.value = true;
    try {
      _documentService.getSharedDocuments().listen((documents) {
        sharedDocuments.value = documents;
        isLoading.value = false;
      }, onError: (error) {
        print('Error loading shared documents: $error');
        isLoading.value = false;
      });
    } catch (e) {
      print('Exception loading shared documents: $e');
      isLoading.value = false;
    }
  }

  void _loadSharedDocuments() {
    loadSharedDocuments();
  }

  // Create a new folder
  Future<void> createFolder(String folderName) async {
    if (folderName.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Folder name cannot be empty',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;
      final newFolder = await _documentService.createFolder(folderName);
      if (newFolder != null) {
        Get.snackbar(
          'Success',
          'Folder created successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.7),
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to create folder',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.7),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Select a folder and load its documents
  void selectFolder(String folderId) {
    selectedFolderId.value = folderId;

    // Clear current documents and load new ones
    currentFolderDocuments.clear();

    try {
      // Subscribe to the folder documents stream
      _documentService.getFolderDocuments(folderId).listen((documentsList) {
        currentFolderDocuments.value = documentsList;
        hasError.value = false;
      }, onError: (error) {
        print('Error loading documents: $error');
        hasError.value = true;
        // Show the index creation help
        _documentService.showIndexCreationHelp();
      });
    } catch (e) {
      print('Exception in selectFolder: $e');
      hasError.value = true;
    }
  }

  // Upload a file to the selected folder
  Future<void> uploadFile() async {
    if (selectedFolderId.value.isEmpty) {
      Get.snackbar(
        'Error',
        'Please select a folder first',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
      );
      return;
    }

    try {
      isUploading.value = true;

      // Pick a file (PDF or image)
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );

      if (result == null || result.files.isEmpty) {
        isUploading.value = false;
        return;
      }

      // Get the file and its path
      final file = File(result.files.single.path!);
      final fileName = path.basename(file.path);

      // Validate the file size (limit to 10MB)
      final fileSize = await file.length();
      if (fileSize > 10 * 1024 * 1024) {
        Get.snackbar(
          'Error',
          'File size exceeds 10MB limit',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.7),
          colorText: Colors.white,
        );
        isUploading.value = false;
        return;
      }

      // Upload the file
      final uploadedDoc = await _documentService.uploadDocument(
        file,
        selectedFolderId.value,
        fileName,
      );

      if (uploadedDoc != null) {
        Get.snackbar(
          'Success',
          'Document uploaded successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.7),
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to upload document',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.7),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
      );
    } finally {
      isUploading.value = false;
    }
  }

  // Delete a document
  Future<void> deleteDocument(DocumentFileModel document) async {
    try {
      isLoading.value = true;
      final success = await _documentService.deleteDocument(document);
      if (success) {
        Get.snackbar(
          'Success',
          'Document deleted successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.7),
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to delete document',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.7),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Delete a folder
  Future<void> deleteFolder(FolderModel folder) async {
    try {
      isLoading.value = true;
      final success = await _documentService.deleteFolder(folder);
      if (success) {
        // If currently selected folder is deleted, clear selection
        if (selectedFolderId.value == folder.id) {
          selectedFolderId.value = '';
          currentFolderDocuments.clear();
        }

        Get.snackbar(
          'Success',
          'Folder deleted successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.7),
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to delete folder',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.7),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Share a document with another user via invitation code
  Future<void> shareDocument(
      DocumentFileModel document, String invitationCode) async {
    if (invitationCode.trim().isEmpty) {
      Get.snackbar(
        'Erreur',
        'Le code d\'invitation ne peut pas être vide',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
      );
      return;
    }

    try {
      isSharing.value = true;
      final success = await _documentService.shareDocumentWithInvitationCode(
          document, invitationCode);

      if (success) {
        Get.back(); // Close dialog
        Get.snackbar(
          'Succès',
          'Document partagé avec succès',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.7),
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Erreur',
          'Code d\'invitation invalide ou utilisateur introuvable',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.7),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Une erreur est survenue: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
      );
    } finally {
      isSharing.value = false;
    }
  }

  // Show help for index creation
  void showIndexHelp() {
    _documentService.showIndexCreationHelp();
  }

  // Add a virtual folder for shared documents
  void showSharedDocuments() {
    selectedFolderId.value = 'partagedoc';
    isShowingSharedDocs.value = true;
    // We're using the sharedDocuments list instead of loading from a folder
  }

  // Method to go back from shared documents
  void goBackFromSharedDocuments() {
    selectedFolderId.value = '';
    isShowingSharedDocs.value = false;
  }
}
