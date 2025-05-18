import 'package:educonnect/core/themes/color_mangers.dart';
import 'package:educonnect/features/groupe/controller/group_controller.dart';
import 'package:educonnect/widgets/customText.dart';
import 'package:educonnect/widgets/input/custom_input.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({Key? key}) : super(key: key);

  @override
  _CreateGroupScreenState createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final GroupController controller = Get.find<GroupController>();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String _selectedCategory = 'Académique';
  bool _isPublic = true;
  bool _hasChat = true;

  final List<String> _categories = [
    'Académique',
    'Technique',
    'Culturel',
    'Social',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.lightGrey3,
      appBar: AppBar(
        backgroundColor: ColorManager.primaryColor,
        title: Text('Créer un groupe',
            style: TextStyle(color: ColorManager.white)),
        iconTheme: IconThemeData(color: ColorManager.white),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner for major-based groups
              InkWell(
                onTap: () => Get.toNamed('/majorGroups'),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12),
                  margin: EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: ColorManager.blueprimaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: ColorManager.blueprimaryColor,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        FeatherIcons.users,
                        color: ColorManager.blueprimaryColor,
                        size: 22,
                      ),
                      Gap(12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Groupes par filière',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: ColorManager.blueprimaryColor,
                                fontSize: 16,
                              ),
                            ),
                            Gap(4),
                            Text(
                              'Créez automatiquement des groupes par filière avec les professeurs correspondants',
                              style: TextStyle(
                                color: ColorManager.SoftBlack,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        FeatherIcons.chevronRight,
                        color: ColorManager.blueprimaryColor,
                      ),
                    ],
                  ),
                ),
              ),

              // Header
              customText(
                text: 'Informations du groupe',
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Gap(5),
              Text(
                'Remplissez les informations suivantes pour créer votre groupe',
                style: TextStyle(
                  color: ColorManager.grey,
                  fontSize: 14,
                ),
              ),
              const Gap(25),

              // Group name
              customText(
                text: 'Nom du groupe',
                textStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Gap(10),
              CustomTextFormField(
                height: 50,
                icon:
                    Icon(FeatherIcons.users, color: ColorManager.primaryColor),
                formcontroller: _nameController,
                inputType: TextInputType.text,
                texthint: 'Entrez le nom du groupe',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un nom pour le groupe';
                  }
                  return null;
                },
              ),
              const Gap(20),

              // Group description
              customText(
                text: 'Description du groupe',
                textStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Gap(10),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  hintText: 'Entrez une description pour le groupe',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(15),
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer une description pour le groupe';
                  }
                  return null;
                },
              ),
              const Gap(20),

              // Group category
              customText(
                text: 'Catégorie',
                textStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Gap(10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCategory,
                    isExpanded: true,
                    icon: const Icon(FeatherIcons.chevronDown),
                    items: _categories.map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedCategory = newValue;
                        });
                      }
                    },
                  ),
                ),
              ),
              const Gap(20),

              // Group privacy
              customText(
                text: 'Confidentialité',
                textStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Gap(10),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<bool>(
                      title: const Text('Public'),
                      value: true,
                      groupValue: _isPublic,
                      activeColor: ColorManager.primaryColor,
                      onChanged: (bool? value) {
                        if (value != null) {
                          setState(() {
                            _isPublic = value;
                          });
                        }
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<bool>(
                      title: const Text('Privé'),
                      value: false,
                      groupValue: _isPublic,
                      activeColor: ColorManager.primaryColor,
                      onChanged: (bool? value) {
                        if (value != null) {
                          setState(() {
                            _isPublic = value;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              const Gap(10),
              Text(
                _isPublic
                    ? 'Tout le monde peut trouver et rejoindre ce groupe'
                    : 'Le groupe est visible uniquement sur invitation',
                style: TextStyle(
                  color: ColorManager.grey,
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const Gap(20),

              // Chat option
              customText(
                text: 'Activer le chat de groupe',
                textStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Gap(10),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Activer le chat pour ce groupe',
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                    Switch(
                      value: _hasChat,
                      activeColor: ColorManager.primaryColor,
                      onChanged: (value) {
                        setState(() {
                          _hasChat = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const Gap(10),
              Text(
                _hasChat
                    ? 'Les membres pourront communiquer via le chat du groupe'
                    : 'Le groupe n\'aura pas de fonctionnalité de chat',
                style: TextStyle(
                  color: ColorManager.grey,
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const Gap(30),

              // Create button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorManager.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Créer le groupe',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitForm() {
    print('Submitting form...');
    if (_formKey.currentState!.validate()) {
      print('Creating group...');
      controller.createGroup(
        name: _nameController.text,
        description: _descriptionController.text,
        category: _selectedCategory,
        isPublic: _isPublic,
        hasChat: _hasChat,
      );
    }
  }
}
