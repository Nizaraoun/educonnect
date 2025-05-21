import 'package:educonnect/features/document/controller/document_controller.dart';
import 'package:educonnect/features/document/model/document_file_model.dart';
import 'package:educonnect/features/document/view/DocumentViewerScreen.dart';
import 'package:educonnect/widgets/customAppBar.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:educonnect/core/themes/color_mangers.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter_animator/flutter_animator.dart';
import 'package:timeago/timeago.dart' as timeago;

class PartageDocScreen extends StatefulWidget {
  const PartageDocScreen({super.key});

  @override
  State<PartageDocScreen> createState() => _PartageDocScreenState();
}

class _PartageDocScreenState extends State<PartageDocScreen> {
  late final DocumentController _controller;

  @override
  void initState() {
    super.initState();
    // Try to find existing controller or create a new one if needed
    try {
      _controller = Get.find<DocumentController>();
    } catch (e) {
      _controller = Get.put(DocumentController());
    }
    // Load shared documents
    _controller.loadSharedDocuments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.lightGrey3,
      appBar: customAppBar(
        title: 'Documents Partagés',
      ),
      body: Obx(() {
        if (_controller.isLoading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: ColorManager.primaryColor,
                ),
                const Gap(12),
                Text(
                  'Chargement...',
                  style: TextStyle(
                    color: ColorManager.SoftBlack,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }

        // Display shared documents
        return _buildSharedDocumentsView();
      }),
    );
  }

  Widget _buildSharedDocumentsView() {
    return Obx(() {
      if (_controller.sharedDocuments.isEmpty) {
        return FadeInUp(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      FeatherIcons.share2,
                      size: 80,
                      color: ColorManager.primaryColor.withOpacity(0.7),
                    ),
                    const Gap(20),
                    Text(
                      'Aucun document partagé',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: ColorManager.SoftBlack,
                      ),
                    ),
                    const Gap(8),
                    Text(
                      'Vous n\'avez pas encore reçu de documents partagés',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }

      return FadeInUp(
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _controller.sharedDocuments.length,
          itemBuilder: (context, index) {
            final document = _controller.sharedDocuments[index];
            return _buildDocumentListItem(document);
          },
        ),
      );
    });
  }

  Widget _buildDocumentListItem(DocumentFileModel document) {
    final bool isPdf = document.type == 'pdf';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        onTap: () {
          Get.to(() => DocumentViewerScreen(document: document));
        },
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 50,
          height: 50,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isPdf
                ? ColorManager.primaryColor.withOpacity(0.1)
                : Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            isPdf ? FeatherIcons.fileText : FeatherIcons.image,
            color: isPdf ? ColorManager.primaryColor : Colors.orange,
          ),
        ),
        title: Text(
          document.name,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: ColorManager.SoftBlack,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Gap(4),
            Text(
              'Partagé ${timeago.format(document.createdAt, locale: 'fr')}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            if (document.sharedBy != null)
              FutureBuilder<String>(
                future: _controller.getUserNameById(document.sharedBy),
                builder: (context, snapshot) {
                  return Text(
                    'Par: ${snapshot.data ?? 'Chargement...'}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  );
                },
              ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(FeatherIcons.eye, size: 20),
          onPressed: () {
            Get.to(() => DocumentViewerScreen(document: document));
          },
        ),
      ),
    );
  }
}
