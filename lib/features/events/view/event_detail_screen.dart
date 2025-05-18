import 'package:educonnect/core/themes/color_mangers.dart';
import 'package:educonnect/features/events/controller/events_controller.dart';
import 'package:educonnect/features/events/model/event_model.dart';
import 'package:educonnect/widgets/customText.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class EventDetailScreen extends StatelessWidget {
  final EventModel event;

  const EventDetailScreen({Key? key, required this.event}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Format date for display
    final dateFormat = DateFormat('dd MMMM yyyy', 'fr_FR');
    final formattedDate = dateFormat.format(event.date);
    final EventsController controller = Get.find<EventsController>();

    return Scaffold(
      backgroundColor: ColorManager.lightGrey3,
      appBar: AppBar(
        backgroundColor: ColorManager.primaryColor,
        title: Text('Détails de l\'événement',
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _getCategoryColor(event.category),
                    _getCategoryColor(event.category).withOpacity(0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          event.category,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${event.participants} participants',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const Gap(15),
                  Text(
                    event.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Gap(10),
                  Row(
                    children: [
                      const Icon(FeatherIcons.calendar,
                          color: Colors.white, size: 16),
                      const Gap(10),
                      Text(
                        formattedDate,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const Gap(5),
                  Row(
                    children: [
                      const Icon(FeatherIcons.clock,
                          color: Colors.white, size: 16),
                      const Gap(10),
                      Text(
                        '${event.startTime} - ${event.endTime}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const Gap(5),
                  Row(
                    children: [
                      const Icon(FeatherIcons.mapPin,
                          color: Colors.white, size: 16),
                      const Gap(10),
                      Text(
                        event.location,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Gap(25),

            // Description
            customText(
              text: 'Description',
              textStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Gap(10),
            Text(
              event.description,
              style: TextStyle(
                fontSize: 16,
                color: ColorManager.darkGrey,
                height: 1.5,
              ),
            ),

            const Gap(25),

            // Organizer
            customText(
              text: 'Organisé par',
              textStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Gap(10),
            Container(
              padding: const EdgeInsets.all(15),
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
                  CircleAvatar(
                    backgroundColor: ColorManager.lightGrey,
                    child: const Icon(FeatherIcons.user),
                  ),
                  const Gap(15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.organizerName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Organisateur',
                        style: TextStyle(
                          color: ColorManager.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(FeatherIcons.messageCircle,
                        color: ColorManager.blueprimaryColor),
                    onPressed: () {
                      // Contact organizer
                      Get.snackbar(
                        'Contacter l\'organisateur',
                        'Cette fonctionnalité sera bientôt disponible',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
                  ),
                ],
              ),
            ),

            const Gap(30),

            // Participation button
            SizedBox(
              width: double.infinity,
              child: Obx(() {
                final isLoading = controller.isSubmitting.value;

                return ElevatedButton(
                  onPressed:
                      isLoading ? null : () => controller.joinEvent(event.id),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorManager.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Participer à cet événement',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                );
              }),
            ),

            const Gap(10),

            // Share button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  // Share event logic
                  Get.snackbar(
                    'Partager l\'événement',
                    'Cette fonctionnalité sera bientôt disponible',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: ColorManager.primaryColor,
                  side: BorderSide(color: ColorManager.primaryColor),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(FeatherIcons.share2, size: 18),
                    const Gap(10),
                    const Text(
                      'Partager cet événement',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Académique':
        return Colors.blue;
      case 'Culturel':
        return Colors.purple;
      case 'Sportif':
        return Colors.green;
      case 'Social':
        return Colors.orange;
      default:
        return ColorManager.primaryColor;
    }
  }
}
