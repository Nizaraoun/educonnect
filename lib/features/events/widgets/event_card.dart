import 'package:educonnect/core/themes/color_mangers.dart';
import 'package:educonnect/features/events/model/event_model.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

class EventCard extends StatelessWidget {
  final EventModel event;

  const EventCard({Key? key, required this.event}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Format date for display
    final dateFormat = DateFormat('dd MMM', 'fr_FR');
    final dayFormat = DateFormat('E', 'fr_FR');
    final formattedDate = dateFormat.format(event.date);
    final dayName = dayFormat.format(event.date);

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top section with category and participants
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            decoration: BoxDecoration(
              color: _getCategoryColor(event.category).withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(event.category),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    event.category,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const Spacer(),
                Icon(FeatherIcons.users, size: 14, color: ColorManager.grey),
                const Gap(5),
                Text(
                  '${event.participants} participants',
                  style: TextStyle(
                    color: ColorManager.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Main content
          Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date column
                Container(
                  width: 60,
                  decoration: BoxDecoration(
                    color: ColorManager.lightGrey3,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      Text(
                        dayName.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: ColorManager.grey,
                        ),
                      ),
                      const Gap(5),
                      Text(
                        formattedDate,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: ColorManager.primaryColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const Gap(15),

                // Event details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        event.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Gap(10),

                      // Time
                      Row(
                        children: [
                          Icon(FeatherIcons.clock,
                              size: 14, color: ColorManager.grey),
                          const Gap(5),
                          Text(
                            '${event.startTime} - ${event.endTime}',
                            style: TextStyle(
                              fontSize: 14,
                              color: ColorManager.grey,
                            ),
                          ),
                        ],
                      ),
                      const Gap(5),

                      // Location
                      Row(
                        children: [
                          Icon(FeatherIcons.mapPin,
                              size: 14, color: ColorManager.grey),
                          const Gap(5),
                          Expanded(
                            child: Text(
                              event.location,
                              style: TextStyle(
                                fontSize: 14,
                                color: ColorManager.grey,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const Gap(5),

                      // Organizer
                      Row(
                        children: [
                          Icon(FeatherIcons.user,
                              size: 14, color: ColorManager.grey),
                          const Gap(5),
                          Text(
                            event.organizerName,
                            style: TextStyle(
                              fontSize: 14,
                              color: ColorManager.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
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
