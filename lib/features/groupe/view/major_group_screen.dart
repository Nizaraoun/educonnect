import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:educonnect/core/themes/color_mangers.dart';
import 'package:educonnect/features/groupe/service/major_group_service.dart';
import 'package:gap/gap.dart';

class MajorGroupScreen extends StatefulWidget {
  const MajorGroupScreen({Key? key}) : super(key: key);

  @override
  _MajorGroupScreenState createState() => _MajorGroupScreenState();
}

class _MajorGroupScreenState extends State<MajorGroupScreen> {
  final MajorGroupService _service = MajorGroupService();
  bool _isLoading = false;
  List<String> _createdGroupIds = [];
  String _statusMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.scaffoldbg,
      appBar: AppBar(
        backgroundColor: ColorManager.primaryColor,
        title: Text(
          'Groupes par filière',
          style: TextStyle(color: ColorManager.white),
        ),
        iconTheme: IconThemeData(color: ColorManager.white),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoSection(),
            const Gap(20),
            _buildActionSection(),
            const Gap(20),
            _buildResultSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Création automatique de groupes par filière',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: ColorManager.primaryColor,
              ),
            ),
            const Gap(10),
            Text(
              'Cette fonctionnalité permet de créer automatiquement des groupes de discussion pour chaque filière d\'études, en associant les étudiants avec leurs professeurs correspondants.',
              style: TextStyle(
                fontSize: 14,
                color: ColorManager.SoftBlack,
              ),
            ),
            const Gap(10),
            Text(
              'Fonctionnement:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: ColorManager.SoftBlack,
              ),
            ),
            const Gap(5),
            _buildInfoPoint('Regroupement des étudiants par filière'),
            _buildInfoPoint(
                'Association avec les professeurs du même département'),
            _buildInfoPoint(
                'Création d\'un groupe de discussion pour chaque filière'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(text),
          ),
        ],
      ),
    );
  }

  Widget _buildActionSection() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Création des groupes',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: ColorManager.primaryColor,
              ),
            ),
            const Gap(15),
            ElevatedButton(
              onPressed: _isLoading ? null : _createGroups,
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorManager.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isLoading
                  ? Center(
                      child: SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(ColorManager.white),
                          strokeWidth: 2,
                        ),
                      ),
                    )
                  : Text(
                      'Créer les groupes par filière',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: ColorManager.white,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultSection() {
    if (_statusMessage.isEmpty && _createdGroupIds.isEmpty) {
      return Container();
    }

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Résultat',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: ColorManager.primaryColor,
              ),
            ),
            const Gap(10),
            if (_statusMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  _statusMessage,
                  style: TextStyle(
                    color: _createdGroupIds.isNotEmpty
                        ? Colors.green
                        : Colors.orange,
                  ),
                ),
              ),
            if (_createdGroupIds.isNotEmpty) ...[
              Text(
                'Groupes créés:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Gap(5),
              Text(
                  '${_createdGroupIds.length} groupes ont été créés avec succès.'),
              const Gap(10),
              ElevatedButton(
                onPressed: _goToGroupsList,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorManager.blueprimaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Voir les groupes',
                  style: TextStyle(color: ColorManager.white),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _createGroups() async {
    setState(() {
      _isLoading = true;
      _statusMessage = '';
      _createdGroupIds = [];
    });

    try {
      final groupIds = await _service.createMajorBasedGroups();

      setState(() {
        _createdGroupIds = groupIds;
        _statusMessage = groupIds.isNotEmpty
            ? 'Les groupes ont été créés avec succès!'
            : 'Aucun groupe n\'a été créé. Vérifiez que vous avez des étudiants et des professeurs avec des filières/départements correspondants.';
        _isLoading = false;
      });

      if (groupIds.isNotEmpty) {
        Get.snackbar(
          'Succès',
          '${groupIds.length} groupes ont été créés avec succès',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.7),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Erreur lors de la création des groupes: $e';
        _isLoading = false;
      });

      Get.snackbar(
        'Erreur',
        'Une erreur est survenue lors de la création des groupes',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
      );
    }
  }

  void _goToGroupsList() {
    // Navigate to the groups list screen
    Get.toNamed('/groupes');
  }
}
