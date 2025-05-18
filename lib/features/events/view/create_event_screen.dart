import 'package:educonnect/core/themes/color_mangers.dart';
import 'package:educonnect/features/events/controller/events_controller.dart';
import 'package:educonnect/widgets/customText.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class CreateEventScreen extends StatelessWidget {
  const CreateEventScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final EventsController controller = Get.find<EventsController>();

    return Scaffold(
      backgroundColor: ColorManager.lightGrey3,
      appBar: AppBar(
        backgroundColor: ColorManager.primaryColor,
        title: Text('Créer un événement',
            style: TextStyle(color: ColorManager.white)),
        iconTheme: IconThemeData(color: ColorManager.white),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Obx(() => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Form fields
                _buildSectionTitle('Informations générales'),
                _buildTextField(
                  controller: controller.titleController,
                  labelText: 'Titre',
                  icon: FeatherIcons.fileText,
                  hintText: 'Titre de l\'événement',
                ),

                _buildTextField(
                  controller: controller.descriptionController,
                  labelText: 'Description',
                  icon: FeatherIcons.alignLeft,
                  hintText: 'Description de l\'événement',
                  maxLines: 5,
                ),

                _buildSectionTitle('Catégorie'),
                _buildCategorySelector(controller),

                _buildSectionTitle('Date et horaires'),
                _buildDateTimePicker(controller, context),

                _buildSectionTitle('Lieu'),
                _buildTextField(
                  controller: controller.locationController,
                  labelText: 'Lieu',
                  icon: FeatherIcons.mapPin,
                  hintText: 'Lieu de l\'événement',
                ),

                _buildSectionTitle('Organisateur'),
                _buildTextField(
                  controller: controller.organizerNameController,
                  labelText: 'Nom de l\'organisateur',
                  icon: FeatherIcons.users,
                  hintText: 'Ex: Groupe X, Faculté de Médecine, BDE...',
                ),

                const Gap(30),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: controller.isSubmitting.value
                        ? null
                        : () => controller.submitEvent(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorManager.primaryColor,
                      foregroundColor: ColorManager.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: controller.isSubmitting.value
                        ? const CircularProgressIndicator(
                            color: ColorManager.white)
                        : const Text('Créer l\'événement',
                            style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            )),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: customText(
        text: title,
        textStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    required String hintText,
    int maxLines = 1,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: ColorManager.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          prefixIcon: Icon(icon, color: ColorManager.grey),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        ),
      ),
    );
  }

  Widget _buildCategorySelector(EventsController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          _buildCategoryChip(controller, 'Académique'),
          _buildCategoryChip(controller, 'Culturel'),
          _buildCategoryChip(controller, 'Sportif'),
          _buildCategoryChip(controller, 'Social'),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(EventsController controller, String category) {
    return Obx(() {
      final isSelected = controller.eventCategory.value == category;
      return ChoiceChip(
        label: Text(category),
        selected: isSelected,
        backgroundColor: ColorManager.white,
        selectedColor: ColorManager.blueprimaryColor,
        labelStyle: TextStyle(
          color: isSelected ? ColorManager.white : ColorManager.grey,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        onSelected: (selected) {
          if (selected) {
            controller.eventCategory.value = category;
          }
        },
      );
    });
  }

  Widget _buildDateTimePicker(
      EventsController controller, BuildContext context) {
    return Row(
      children: [
        // Date picker
        Expanded(
          flex: 3,
          child: GestureDetector(
            onTap: () => _selectDate(context, controller),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              decoration: BoxDecoration(
                color: ColorManager.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(FeatherIcons.calendar, color: ColorManager.grey),
                  const Gap(10),
                  Obx(() => Text(
                        DateFormat('dd/MM/yyyy')
                            .format(controller.eventDate.value),
                        style:
                            TextStyle(color: ColorManager.grey, fontSize: 10),
                      )),
                ],
              ),
            ),
          ),
        ),

        const Gap(10),

        // Start time picker
        Expanded(
          flex: 2,
          child: GestureDetector(
            onTap: () => _selectTime(context, controller, isStartTime: true),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              decoration: BoxDecoration(
                color: ColorManager.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    FeatherIcons.clock,
                    color: ColorManager.grey,
                    size: 15,
                  ),
                  const Gap(10),
                  Obx(() => Text(
                        controller.startTime.value,
                        style:
                            TextStyle(color: ColorManager.grey, fontSize: 10),
                      )),
                ],
              ),
            ),
          ),
        ),

        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 5),
          child: Text('-'),
        ),

        // End time picker
        Expanded(
          flex: 2,
          child: GestureDetector(
            onTap: () => _selectTime(context, controller, isStartTime: false),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              decoration: BoxDecoration(
                color: ColorManager.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(FeatherIcons.clock, color: ColorManager.grey, size: 15),
                  const Gap(10),
                  Obx(() => Text(
                        controller.endTime.value,
                        style:
                            TextStyle(color: ColorManager.grey, fontSize: 10),
                      )),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(
      BuildContext context, EventsController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: controller.eventDate.value,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: ColorManager.primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      controller.eventDate.value = picked;
    }
  }

  Future<void> _selectTime(BuildContext context, EventsController controller,
      {required bool isStartTime}) async {
    final TimeOfDay initialTime = isStartTime
        ? TimeOfDay.fromDateTime(DateTime.now().add(const Duration(hours: 1)))
        : TimeOfDay.fromDateTime(DateTime.now().add(const Duration(hours: 2)));

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: ColorManager.primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final String formattedTime =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      if (isStartTime) {
        controller.startTime.value = formattedTime;
      } else {
        controller.endTime.value = formattedTime;
      }
    }
  }
}
