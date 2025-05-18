import 'package:educonnect/core/themes/color_mangers.dart';
import 'package:educonnect/features/document/model/document_file_model.dart';
import 'package:educonnect/widgets/customAppBar.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animator/flutter_animator.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class DocumentViewerScreen extends StatefulWidget {
  final DocumentFileModel document;

  const DocumentViewerScreen({Key? key, required this.document})
      : super(key: key);

  @override
  State<DocumentViewerScreen> createState() => _DocumentViewerScreenState();
}

class _DocumentViewerScreenState extends State<DocumentViewerScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.lightGrey3,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: ColorManager.primaryColor,
      elevation: 0,
      title: Text(
        widget.document.name,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: Colors.white,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(20),
        ),
      ),
      leading: IconButton(
        icon: const Icon(FeatherIcons.arrowLeft, color: Colors.white),
        onPressed: () => Get.back(),
      ),
      actions: [
        IconButton(
          icon: const Icon(FeatherIcons.share2, color: Colors.white),
          onPressed: () {
            // Implement share functionality
            Get.snackbar(
              'Partage',
              'Partage de ${widget.document.name}',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.teal.withOpacity(0.7),
              colorText: Colors.white,
            );
          },
        ),
      ],
    );
  }

  Widget _buildBody() {
    return FadeIn(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildDocumentInfoCard(),
            const Gap(20),
            Expanded(
              child: _buildDocumentPreview(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentInfoCard() {
    final bool isPdf = widget.document.type == 'pdf';
    final iconColor = isPdf ? Colors.red : Colors.blue;
    final bgColor =
        isPdf ? Colors.red.withOpacity(0.1) : Colors.blue.withOpacity(0.1);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Icon(
                isPdf ? FeatherIcons.fileText : FeatherIcons.image,
                color: iconColor,
                size: 30,
              ),
            ),
          ),
          const Gap(16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.document.name,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: ColorManager.SoftBlack,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const Gap(4),
                Text(
                  'Type: ${widget.document.type.toUpperCase()}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const Gap(2),
                Text(
                  'Ajouté le: ${_formatDate(widget.document.createdAt)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentPreview() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: ColorManager.primaryColor,
            ),
            const Gap(16),
            Text(
              'Chargement du document...',
              style: TextStyle(
                color: ColorManager.SoftBlack,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    if (widget.document.type == 'pdf') {
      return _buildPdfViewer();
    } else if (widget.document.type == 'image') {
      return _buildImageViewer();
    } else {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              FeatherIcons.alertCircle,
              size: 60,
              color: Colors.orange,
            ),
            const Gap(16),
            Text(
              'Type de document non pris en charge',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: ColorManager.SoftBlack,
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildPdfViewer() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.red.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                FeatherIcons.fileText,
                size: 80,
                color: Colors.red,
              ),
              const Gap(24),
              Text(
                'Document PDF',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: ColorManager.SoftBlack,
                ),
              ),
              const Gap(8),
              Text(
                'Ce document PDF doit être ouvert avec une application externe',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const Gap(24),
              ElevatedButton.icon(
                onPressed: () => _openUrl(widget.document.url),
                icon: const Icon(FeatherIcons.externalLink),
                label: const Text('Ouvrir le PDF'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImageViewer() {
    return Column(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                widget.document.url,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  }
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                      color: ColorManager.primaryColor,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          FeatherIcons.alertCircle,
                          size: 60,
                          color: Colors.orange,
                        ),
                        const Gap(16),
                        Text(
                          'Impossible de charger l\'image',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: ColorManager.SoftBlack,
                          ),
                        ),
                        const Gap(8),
                        ElevatedButton.icon(
                          onPressed: () => _openUrl(widget.document.url),
                          icon: const Icon(FeatherIcons.externalLink),
                          label: const Text('Ouvrir dans le Navigateur'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        const Gap(16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            OutlinedButton.icon(
              onPressed: () => _openUrl(widget.document.url),
              icon: const Icon(FeatherIcons.externalLink),
              label: const Text('Ouvrir dans le Navigateur'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.blue,
                side: const BorderSide(color: Colors.blue),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _openUrl(String url) async {
    setState(() => _isLoading = true);
    try {
      final Uri uri = Uri.parse(url);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        Get.snackbar(
          'Erreur',
          'Impossible d\'ouvrir le document',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.7),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Échec de l\'ouverture du document: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
