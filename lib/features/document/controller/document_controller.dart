import 'dart:io';
import 'package:educonnect/features/document/model/document_file_model.dart';
import 'package:educonnect/features/document/model/folder_model.dart';
import 'package:educonnect/features/document/service/document_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as path;

class DocumentController extends GetxController {
  final DocumentService _documentService = DocumentService();

  final RxList<FolderModel> folders = <FolderModel>[].obs;
  final RxList<DocumentFileModel> currentFolderDocuments =
      <DocumentFileModel>[].obs;
  final RxString selectedFolderId = ''.obs;
  final RxBool isLoading = false.obs;
  final RxBool isUploading = false.obs;
  final RxBool hasError = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Load all folders for the current user
    _loadFolders();
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

  // Show help for index creation
  void showIndexHelp() {
    _documentService.showIndexCreationHelp();
  }
}
