import 'package:educonnect/features/document/controller/document_controller.dart';
import 'package:educonnect/features/document/model/document_file_model.dart';
import 'package:educonnect/features/document/model/folder_model.dart';
import 'package:educonnect/features/document/view/DocumentViewerScreen.dart';
import 'package:educonnect/widgets/customAppBar.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:educonnect/core/themes/color_mangers.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter_animator/flutter_animator.dart';
import 'package:timeago/timeago.dart' as timeago;

class DocumentScreen extends StatefulWidget {
  const DocumentScreen({super.key});

  @override
  State<DocumentScreen> createState() => _DocumentScreenState();
}

class _DocumentScreenState extends State<DocumentScreen>
    with SingleTickerProviderStateMixin {
  final DocumentController _controller = Get.put(DocumentController());
  final TextEditingController _folderNameController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _folderNameController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.lightGrey3,
      appBar: _buildModernAppBar(),
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

        // Show error state if there's an issue with Firestore indexes
        if (_controller.hasError.value) {
          return _buildErrorState();
        }

        // If a folder is selected, show its documents
        if (_controller.selectedFolderId.isNotEmpty) {
          return _buildFolderDocuments();
        }

        // Otherwise show the list of folders
        return _buildFolderGrid();
      }),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  PreferredSizeWidget _buildModernAppBar() {
    return AppBar(
      backgroundColor: ColorManager.primaryColor,
      elevation: 0,
      title: Text(
        _controller.selectedFolderId.isEmpty
            ? 'Mes Documents'
            : _controller.isShowingSharedDocs.value
                ? 'Documents Partagés'
                : 'Contenu du Dossier',
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 18,
          color: Colors.white,
        ),
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(20),
        ),
      ),
      centerTitle: true,
      iconTheme: const IconThemeData(
        color: Colors.white,
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    if (_controller.hasError.value) {
      return FloatingActionButton(
        onPressed: () => _controller.showIndexHelp(),
        backgroundColor: Colors.orange,
        child: const Icon(FeatherIcons.helpCircle, color: Colors.white),
      );
    }

    return FloatingActionButton.extended(
      onPressed: _controller.isUploading.value
          ? null
          : () => _controller.selectedFolderId.isEmpty
              ? _showCreateFolderDialog()
              : _controller.uploadFile(),
      backgroundColor: ColorManager.primaryColor,
      icon: Obx(
        () => _controller.isUploading.value
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Icon(
                _controller.selectedFolderId.isEmpty
                    ? FeatherIcons.folderPlus
                    : FeatherIcons.filePlus,
                color: Colors.white,
              ),
      ),
      label: Obx(() => Text(
            _controller.isUploading.value
                ? 'Téléchargement...'
                : _controller.selectedFolderId.isEmpty
                    ? 'Ajouter un Dossier'
                    : 'Ajouter un Fichier',
            style: const TextStyle(color: Colors.white),
          )),
    );
  }

  Widget _buildErrorState() {
    return FadeIn(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            padding: const EdgeInsets.all(20),
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  FeatherIcons.alertTriangle,
                  size: 60,
                  color: Colors.orange,
                ),
                const Gap(20),
                Text(
                  'Index Requis',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: ColorManager.primaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const Gap(16),
                Text(
                  'Cette fonctionnalité nécessite un index de base de données pour fonctionner correctement. Veuillez vérifier la console pour les messages d\'erreur.',
                  style: TextStyle(
                    fontSize: 16,
                    color: ColorManager.SoftBlack,
                  ),
                  textAlign: TextAlign.center,
                ),
                const Gap(24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(FeatherIcons.refreshCw),
                      label: const Text('Réessayer'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorManager.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        _controller.onInit(); // Reload data
                      },
                    ),
                    const Gap(12),
                    OutlinedButton.icon(
                      icon: const Icon(FeatherIcons.helpCircle),
                      label: const Text('Aide'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: ColorManager.primaryColor,
                        side: BorderSide(color: ColorManager.primaryColor),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () => _controller.showIndexHelp(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFolderGrid() {
    if (_controller.folders.isEmpty) {
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
                  Image.asset(
                    'assets/images/folder.png',
                    color: ColorManager.darkOrange,
                    width: 120,
                    height: 120,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      FeatherIcons.folder,
                      size: 80,
                      color: ColorManager.primaryColor.withOpacity(0.7),
                    ),
                  ),
                  const Gap(20),
                  Text(
                    'Aucun dossier pour le moment',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: ColorManager.SoftBlack,
                    ),
                  ),
                  const Gap(8),
                  Text(
                    'Créez votre premier dossier pour commencer à organiser vos documents',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const Gap(24),
                  ElevatedButton.icon(
                    onPressed: () => _showCreateFolderDialog(),
                    icon: const Icon(FeatherIcons.folderPlus),
                    label: const Text('Créer Votre Premier Dossier'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorManager.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
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
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
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
                  Icon(
                    FeatherIcons.folder,
                    color: ColorManager.primaryColor,
                  ),
                  const Gap(8),
                  Text(
                    'Mes Dossiers',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: ColorManager.SoftBlack,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: ColorManager.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_controller.folders.length} ${_controller.folders.length == 1 ? 'dossier' : 'dossiers'}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: ColorManager.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Gap(16),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.85,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                // Add +1 to show the special shared documents folder
                itemCount: _controller.folders.length + 1,
                itemBuilder: (context, index) {
                  // If it's the last item, it's our shared documents folder
                  if (index == _controller.folders.length) {
                    return FadeInUp(
                      preferences: const AnimationPreferences(
                        offset: Duration(milliseconds: 50),
                      ),
                      child: _buildSharedDocumentsFolder(),
                    );
                  }

                  final folder = _controller.folders[index];
                  return FadeInUp(
                    preferences: const AnimationPreferences(
                      offset: Duration(milliseconds: 50),
                    ),
                    child: _buildModernFolderItem(folder, index),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernFolderItem(FolderModel folder, int index) {
    final colors = [
      Color(0xFF4A6572),
      Color(0xFF478DE0),
      Color(0xFFF9A826),
      Color(0xFF6C63FF),
      Color(0xFF00A0A0),
      Color(0xFFF05454),
    ];

    final color = colors[index % colors.length];

    return GestureDetector(
      onTap: () => _controller.selectFolder(folder.id),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    FeatherIcons.folder,
                    size: 40,
                    color: color,
                  ),
                ],
              ),
            ),
            const Gap(12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                folder.name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: ColorManager.SoftBlack,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Gap(4),
            Text(
              _formatTimeAgo(folder.createdAt),
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
              ),
            ),
            const Gap(8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildFolderActionButton(
                  icon: FeatherIcons.edit2,
                  color: Colors.blue,
                  onTap: () => _showRenameFolderDialog(folder),
                ),
                const Gap(8),
                _buildFolderActionButton(
                  icon: FeatherIcons.trash2,
                  color: Colors.red,
                  onTap: () => _showDeleteFolderDialog(folder),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    // Configuration en français pour timeago
    timeago.setLocaleMessages('fr', timeago.FrMessages());
    return timeago.format(dateTime, locale: 'fr');
  }

  Widget _buildFolderActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 16,
          color: color,
        ),
      ),
    );
  }

  Widget _buildFolderDocuments() {
    // Check if we're showing the special shared documents folder
    if (_controller.selectedFolderId.value == 'partagedoc') {
      return _buildSharedDocumentsView();
    }

    // Header with back button and folder name
    final selectedFolder = _controller.folders.firstWhere(
      (folder) => folder.id == _controller.selectedFolderId.value,
      orElse: () => FolderModel(
        id: '',
        name: 'Dossier Inconnu',
        userId: '',
        createdAt: DateTime.now(),
      ),
    );

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          margin: const EdgeInsets.all(16),
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
          child: Row(
            children: [
              InkWell(
                onTap: () {
                  _controller.selectedFolderId.value = '';
                },
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: ColorManager.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    FeatherIcons.arrowLeft,
                    size: 18,
                    color: ColorManager.primaryColor,
                  ),
                ),
              ),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selectedFolder.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: ColorManager.SoftBlack,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Créé ${_formatTimeAgo(selectedFolder.createdAt)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: ColorManager.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Obx(() => Text(
                      '${_controller.currentFolderDocuments.length} ${_controller.currentFolderDocuments.length == 1 ? 'fichier' : 'fichiers'}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: ColorManager.primaryColor,
                      ),
                    )),
              ),
            ],
          ),
        ),
        Expanded(
          child: _controller.currentFolderDocuments.isEmpty
              ? FadeIn(
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(horizontal: 32),
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
                          Image.asset(
                            'assets/images/document.png',
                            width: 80,
                            height: 80,
                            errorBuilder: (context, error, stackTrace) => Icon(
                              FeatherIcons.fileText,
                              size: 60,
                              color: ColorManager.primaryColor.withOpacity(0.7),
                            ),
                          ),
                          const Gap(16),
                          Text(
                            'Aucun document pour le moment',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: ColorManager.SoftBlack,
                            ),
                          ),
                          const Gap(8),
                          Text(
                            'Téléchargez un fichier pour commencer',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const Gap(20),
                          ElevatedButton.icon(
                            onPressed: () => _controller.uploadFile(),
                            icon: const Icon(FeatherIcons.upload),
                            label: const Text('Télécharger un Document'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ColorManager.primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _controller.currentFolderDocuments.length,
                  itemBuilder: (context, index) {
                    return FadeInUp(
                      preferences: AnimationPreferences(
                        offset: Duration(milliseconds: 50 * index),
                        duration: const Duration(milliseconds: 400),
                      ),
                      child: _buildModernDocumentItem(
                        _controller.currentFolderDocuments[index],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildModernDocumentItem(DocumentFileModel document) {
    final bool isPdf = document.type == 'pdf';
    final iconColor = isPdf ? Colors.red : Colors.blue;
    final bgColor =
        isPdf ? Colors.red.withOpacity(0.1) : Colors.blue.withOpacity(0.1);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: InkWell(
        onTap: () {
          Get.to(() => DocumentViewerScreen(document: document));
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Icon(
                    isPdf ? FeatherIcons.fileText : FeatherIcons.image,
                    color: iconColor,
                    size: 24,
                  ),
                ),
              ),
              const Gap(16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      document.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: ColorManager.SoftBlack,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Gap(4),
                    Text(
                      'Ajouté ${_formatTimeAgo(document.createdAt)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildDocumentActionButton(
                    icon: FeatherIcons.eye,
                    color: Colors.teal,
                    onTap: () {
                      Get.to(() => DocumentViewerScreen(document: document));
                    },
                  ),
                  const Gap(8),
                  _buildDocumentActionButton(
                    icon: FeatherIcons.share2,
                    color: Colors.blue,
                    onTap: () => _showShareDocumentDialog(document),
                  ),
                  const Gap(8),
                  _buildDocumentActionButton(
                    icon: FeatherIcons.trash2,
                    color: Colors.red,
                    onTap: () => _showDeleteDocumentDialog(document),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 16,
          color: color,
        ),
      ),
    );
  }

  void _showCreateFolderDialog() {
    _folderNameController.clear();
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                FeatherIcons.folderPlus,
                size: 40,
                color: ColorManager.primaryColor,
              ),
              const Gap(16),
              Text(
                'Créer un Nouveau Dossier',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: ColorManager.SoftBlack,
                ),
              ),
              const Gap(20),
              TextField(
                controller: _folderNameController,
                decoration: InputDecoration(
                  hintText: 'Nom du Dossier',
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: Icon(
                    FeatherIcons.folder,
                    color: ColorManager.primaryColor,
                  ),
                ),
                autofocus: true,
              ),
              const Gap(24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey[600],
                    ),
                    child: const Text('Annuler'),
                  ),
                  const Gap(8),
                  ElevatedButton(
                    onPressed: () {
                      final folderName = _folderNameController.text.trim();
                      if (folderName.isNotEmpty) {
                        _controller.createFolder(folderName);
                        Get.back();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorManager.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Créer'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRenameFolderDialog(FolderModel folder) {
    _folderNameController.text = folder.name;
    Get.dialog(Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              FeatherIcons.edit2,
              size: 40,
              color: Colors.blue,
            ),
            const Gap(16),
            Text(
              'Renommer le Dossier',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: ColorManager.SoftBlack,
              ),
            ),
            const Gap(20),
            TextField(
              controller: _folderNameController,
              decoration: InputDecoration(
                hintText: 'Nouveau Nom du Dossier',
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: Icon(
                  FeatherIcons.folder,
                  color: Colors.blue,
                ),
              ),
              autofocus: true,
            ),
            const Gap(24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Get.back(),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey[600],
                  ),
                  child: const Text('Annuler'),
                ),
                const Gap(8),
                ElevatedButton(
                  onPressed: () {
                    // Implement rename functionality
                    Get.back();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Renommer'),
                ),
              ],
            ),
          ],
        ),
      ),
    ));
  }

  void _showDeleteFolderDialog(FolderModel folder) {
    Get.dialog(Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              FeatherIcons.alertTriangle,
              size: 40,
              color: Colors.orange,
            ),
            const Gap(16),
            Text(
              'Supprimer le Dossier',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: ColorManager.SoftBlack,
              ),
            ),
            const Gap(12),
            Text(
              'Êtes-vous sûr de vouloir supprimer "${folder.name}" ?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const Gap(8),
            Text(
              'Cela supprimera également tous les fichiers qu\'il contient.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.red,
              ),
            ),
            const Gap(24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey[600],
                      side: BorderSide(color: Colors.grey[300]!),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Annuler'),
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _controller.deleteFolder(folder);
                      Get.back();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Supprimer'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ));
  }

  void _showDeleteDocumentDialog(DocumentFileModel document) {
    Get.dialog(Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              FeatherIcons.alertTriangle,
              size: 40,
              color: Colors.orange,
            ),
            const Gap(16),
            Text(
              'Supprimer le Document',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: ColorManager.SoftBlack,
              ),
            ),
            const Gap(12),
            Text(
              'Êtes-vous sûr de vouloir supprimer "${document.name}" ?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const Gap(8),
            Text(
              'Cette action ne peut pas être annulée.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.red,
              ),
            ),
            const Gap(24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey[600],
                      side: BorderSide(color: Colors.grey[300]!),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Annuler'),
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _controller.deleteDocument(document);
                      Get.back();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Supprimer'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ));
  }

  void _showShareDocumentDialog(DocumentFileModel document) {
    // Clear previous code if any
    _controller.invitationCodeController.clear();

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                FeatherIcons.share2,
                size: 40,
                color: Colors.blue,
              ),
              const Gap(16),
              Text(
                'Partager le Document',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: ColorManager.SoftBlack,
                ),
              ),
              const Gap(12),
              Text(
                'Partagez "${document.name}" en utilisant un code d\'invitation',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const Gap(20),
              TextField(
                controller: _controller.invitationCodeController,
                decoration: InputDecoration(
                  hintText: 'Code d\'invitation',
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: Icon(
                    FeatherIcons.key,
                    color: ColorManager.primaryColor,
                  ),
                ),
                autofocus: true,
              ),
              const Gap(8),
              Text(
                'Entrez le code d\'invitation de l\'utilisateur avec qui vous souhaitez partager ce document',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                  fontStyle: FontStyle.italic,
                ),
              ),
              const Gap(24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey[600],
                        side: BorderSide(color: Colors.grey[300]!),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Annuler'),
                    ),
                  ),
                  const Gap(12),
                  Expanded(
                    child: Obx(() => ElevatedButton(
                          onPressed: _controller.isSharing.value
                              ? null
                              : () => _controller.shareDocument(
                                    document,
                                    _controller.invitationCodeController.text,
                                  ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorManager.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: _controller.isSharing.value
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Partager'),
                        )),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    String _formatDate(DateTime date) {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Widget _buildSharedDocumentsFolder() {
    return GestureDetector(
      onTap: () => _controller.showSharedDocuments(),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: ColorManager.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    FeatherIcons.share2,
                    size: 40,
                    color: ColorManager.primaryColor,
                  ),
                ],
              ),
            ),
            const Gap(12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'Documents Partagés',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: ColorManager.SoftBlack,
                ),
              ),
            ),
            const Gap(4),
            Obx(() {
              final count = _controller.sharedDocuments.length;
              return Text(
                '$count ${count == 1 ? 'document' : 'documents'}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSharedDocumentsView() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          margin: const EdgeInsets.all(16),
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
          child: Row(
            children: [
              InkWell(
                onTap: () {
                  _controller.goBackFromSharedDocuments();
                },
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: ColorManager.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    FeatherIcons.arrowLeft,
                    size: 18,
                    color: ColorManager.primaryColor,
                  ),
                ),
              ),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Documents Partagés',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: ColorManager.SoftBlack,
                      ),
                    ),
                    Text(
                      'Documents partagés avec vous',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: ColorManager.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Obx(() => Text(
                      '${_controller.sharedDocuments.length} ${_controller.sharedDocuments.length == 1 ? 'document' : 'documents'}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: ColorManager.primaryColor,
                      ),
                    )),
              ),
            ],
          ),
        ),

        // Documents list
        Expanded(
          child: Obx(() {
            if (_controller.sharedDocuments.isEmpty) {
              return Center(
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
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _controller.sharedDocuments.length,
              itemBuilder: (context, index) {
                final document = _controller.sharedDocuments[index];
                return _buildDocumentListItem(document);
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildDocumentListItem(DocumentFileModel document) {
    final bool isPdf = document.type == 'pdf';
    final iconColor = isPdf ? Colors.red : Colors.blue;
    final bgColor =
        isPdf ? Colors.red.withOpacity(0.1) : Colors.blue.withOpacity(0.1);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: InkWell(
        onTap: () {
          Get.to(() => DocumentViewerScreen(document: document));
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Icon(
                    isPdf ? FeatherIcons.fileText : FeatherIcons.image,
                    color: iconColor,
                    size: 24,
                  ),
                ),
              ),
              const Gap(16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      document.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: ColorManager.SoftBlack,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Gap(4),
                    Text(
                      'Ajouté ${_formatTimeAgo(document.createdAt)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildDocumentActionButton(
                    icon: FeatherIcons.eye,
                    color: Colors.teal,
                    onTap: () {
                      Get.to(() => DocumentViewerScreen(document: document));
                    },
                  ),
                  const Gap(8),
                  _buildDocumentActionButton(
                    icon: FeatherIcons.share2,
                    color: Colors.blue,
                    onTap: () => _showShareDocumentDialog(document),
                  ),
                  const Gap(8),
                  _buildDocumentActionButton(
                    icon: FeatherIcons.trash2,
                    color: Colors.red,
                    onTap: () => _showDeleteDocumentDialog(document),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
