import 'package:educonnect/core/themes/color_mangers.dart';
import 'package:educonnect/features/events/controller/events_controller.dart';
import 'package:educonnect/features/events/model/event_model.dart';
import 'package:educonnect/features/events/services/events_firestore_service.dart';
import 'package:educonnect/features/events/view/event_detail_screen.dart';
import 'package:educonnect/features/events/widgets/event_card.dart';
import 'package:educonnect/widgets/customText.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

class EventsScreen extends StatelessWidget {
  const EventsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final EventsController controller = Get.put(EventsController());
    final EventsFirestoreService eventsService = EventsFirestoreService();

    return Scaffold(
      backgroundColor: ColorManager.lightGrey3,
      appBar: AppBar(
        backgroundColor: ColorManager.primaryColor,
        title: Text('Événements', style: TextStyle(color: ColorManager.white)),
        iconTheme: IconThemeData(color: ColorManager.white),
        actions: [
          IconButton(
            icon: Icon(FeatherIcons.filter),
            onPressed: controller.showFilterOptions,
          ),
        ],
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: ColorManager.primaryColor,
        onPressed: controller.navigateToCreateEvent,
        child: const Icon(Icons.add, color: ColorManager.white),
      ),
      body: Column(
        children: [
          // Category filter
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              children: [
                _buildCategoryChip(controller, 'Tous'),
                _buildCategoryChip(controller, 'Académique'),
                _buildCategoryChip(controller, 'Culturel'),
                _buildCategoryChip(controller, 'Sportif'),
                _buildCategoryChip(controller, 'Social'),
              ],
            ),
          ),

          // Events list
          Expanded(
            child: Obx(() {
              final selectedCategory = controller.selectedCategory.value;

              // Use the appropriate stream based on the selected category
              final eventsStream = selectedCategory == 'Tous'
                  ? eventsService.getEventsStream()
                  : eventsService.getEventsByCategoryStream(selectedCategory);

              return StreamBuilder<List<EventModel>>(
                stream: eventsStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    print('Error: ${snapshot.error}');
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(FeatherIcons.alertCircle,
                              size: 50, color: Colors.red),
                          const Gap(10),
                          Text('Une erreur s\'est produite:'),
                        ],
                      ),
                    );
                  }

                  final events = snapshot.data ?? [];

                  if (events.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(FeatherIcons.calendar,
                              size: 50, color: ColorManager.grey),
                          const Gap(10),
                          customText(
                            text: 'Aucun événement trouvé',
                            textStyle: TextStyle(
                              fontSize: 16,
                              color: ColorManager.grey,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(15),
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      final event = events[index];
                      return GestureDetector(
                        onTap: () =>
                            Get.to(() => EventDetailScreen(event: event)),
                        child: EventCard(event: event),
                      );
                    },
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(EventsController controller, String category) {
    return Obx(() {
      final isSelected = controller.selectedCategory.value == category;
      return Padding(
        padding: const EdgeInsets.only(right: 10),
        child: ChoiceChip(
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
              controller.selectCategory(category);
            }
          },
        ),
      );
    });
  }
}
