import 'package:educonnect/core/themes/color_mangers.dart';
import 'package:educonnect/features/groupe/controller/group_controller.dart';
import 'package:educonnect/widgets/customText.dart';
import 'package:educonnect/widgets/input/custom_input.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class CreateRevisionGroupScreen extends StatefulWidget {
  final String parentGroupId;

  const CreateRevisionGroupScreen({
    Key? key,
    required this.parentGroupId,
  }) : super(key: key);

  @override
  _CreateRevisionGroupScreenState createState() =>
      _CreateRevisionGroupScreenState();
}

class _CreateRevisionGroupScreenState extends State<CreateRevisionGroupScreen> {
  final GroupController controller = Get.find<GroupController>();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _startTime = const TimeOfDay(hour: 14, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 16, minute: 0);
  String _selectedSubject = 'Mathématiques';

  final List<String> _subjects = [
    'Mathématiques',
    'Physique',
    'Informatique',
    'Histoire',
    'Anglais',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.lightGrey3,
      appBar: AppBar(
        backgroundColor: ColorManager.primaryColor,
        title: Text('Créer un groupe de révision',
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
              // Header
              customText(
                text: 'Informations du groupe de révision',
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Gap(5),
              Text(
                'Créez un groupe de révision pour étudier ensemble',
                style: TextStyle(
                  color: ColorManager.grey,
                  fontSize: 14,
                ),
              ),
              const Gap(25),

              // Group name
              customText(
                text: 'Titre de la session',
                textStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Gap(10),
              CustomTextFormField(
                 formcontroller: _nameController,
                inputType: TextInputType.text,
                texthint: 'Ex: Révision Calcul Différentiel',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un titre pour la session';
                  }
                  return null;
                },
                icon: Icon(FeatherIcons.edit, color: ColorManager.primaryColor),height: 50,
              ),
              const Gap(20),

              // Subject
              customText(
                text: 'Matière',
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
                    value: _selectedSubject,
                    isExpanded: true,
                    icon: const Icon(FeatherIcons.chevronDown),
                    items: _subjects.map((String subject) {
                      return DropdownMenuItem<String>(
                        value: subject,
                        child: Text(subject),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedSubject = newValue;
                        });
                      }
                    },
                  ),
                ),
              ),
              const Gap(20),

              // Description
              customText(
                text: 'Description',
                textStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Gap(10),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  hintText: 'Décrivez ce que vous allez réviser',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(15),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer une description';
                  }
                  return null;
                },
              ),
              const Gap(20),

              // Date
              customText(
                text: 'Date',
                textStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Gap(10),
              InkWell(
                onTap: () => _selectDate(context),
                child: Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(FeatherIcons.calendar, color: ColorManager.grey),
                      const Gap(10),
                      Text(
                        DateFormat('dd MMMM yyyy', 'fr_FR')
                            .format(_selectedDate),
                        style: const TextStyle(fontSize: 16),
                      ),
                      const Spacer(),
                      Icon(FeatherIcons.chevronDown, color: ColorManager.grey),
                    ],
                  ),
                ),
              ),
              const Gap(20),

              // Time
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        customText(
                          text: 'Heure début',
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Gap(10),
                        InkWell(
                          onTap: () => _selectStartTime(context),
                          child: Container(
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Icon(FeatherIcons.clock,
                                    color: ColorManager.grey),
                                const Gap(10),
                                Text(
                                  '${_startTime.hour}:${_startTime.minute.toString().padLeft(2, '0')}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Gap(15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        customText(
                          text: 'Heure fin',
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Gap(10),
                        InkWell(
                          onTap: () => _selectEndTime(context),
                          child: Container(
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Icon(FeatherIcons.clock,
                                    color: ColorManager.grey),
                                const Gap(10),
                                Text(
                                  '${_endTime.hour}:${_endTime.minute.toString().padLeft(2, '0')}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Gap(20),

              // Location
              customText(
                text: 'Lieu',
                textStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Gap(10),
              CustomTextFormField(

                formcontroller: _locationController,
                inputType: TextInputType.text,
                texthint: 'Ex: Bibliothèque, Salle 102, etc.',
                icon: Icon(FeatherIcons.mapPin, color: ColorManager.grey),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un lieu pour la session';
                  }
                  return null;
                },
                height: 50,

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
                    'Créer le groupe de révision',
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('fr', 'FR'),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectStartTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );
    if (picked != null && picked != _startTime) {
      setState(() {
        _startTime = picked;
        // Ensure end time is after start time
        if (_endTime.hour < _startTime.hour ||
            (_endTime.hour == _startTime.hour &&
                _endTime.minute < _startTime.minute)) {
          _endTime = TimeOfDay(
            hour: _startTime.hour + 2,
            minute: _startTime.minute,
          );
        }
      });
    }
  }

  Future<void> _selectEndTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _endTime,
    );
    if (picked != null && picked != _endTime) {
      if (picked.hour < _startTime.hour ||
          (picked.hour == _startTime.hour &&
              picked.minute <= _startTime.minute)) {
        Get.snackbar(
          'Erreur',
          'L\'heure de fin doit être après l\'heure de début',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      } else {
        setState(() {
          _endTime = picked;
        });
      }
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Format time for display
      final String meetingTime =
          '${_startTime.hour}:${_startTime.minute.toString().padLeft(2, '0')} - '
          '${_endTime.hour}:${_endTime.minute.toString().padLeft(2, '0')}';

      controller.createRevisionGroup(
        parentGroupId: widget.parentGroupId,
        name: _nameController.text,
        description: _descriptionController.text,
        subject: _selectedSubject,
        meetingDate: _selectedDate,
        meetingTime: meetingTime,
        meetingLocation: _locationController.text,
      );
    }
  }
}
