import 'package:educonnect/core/themes/color_mangers.dart';
import 'package:educonnect/features/groupe/model/group_model.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class RevisionGroupCard extends StatelessWidget {
  final RevisionGroupModel revisionGroup;
  final bool isMember;
  final VoidCallback onTap;
  final VoidCallback onJoin;

  const RevisionGroupCard({
    Key? key,
    required this.revisionGroup,
    this.isMember = false,
    required this.onTap,
    required this.onJoin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Format date for display
    final dateFormat = DateFormat('dd MMM yyyy', 'fr_FR');
    final formattedMeetingDate = dateFormat.format(revisionGroup.meetingDate);

    // Calculate saturation percentage
    final int saturationPercentage = revisionGroup.saturationPercentage;
    final bool isFull = revisionGroup.memberCount >= revisionGroup.maxMembers;

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
          // Top section with subject
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            decoration: BoxDecoration(
              color: _getSubjectColor(revisionGroup.subject).withOpacity(0.1),
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
                    color: _getSubjectColor(revisionGroup.subject),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    revisionGroup.subject,
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
                  '${revisionGroup.memberCount}/${revisionGroup.maxMembers} participants',
                  style: TextStyle(
                    color: ColorManager.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Main content
          InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Group name
                  Text(
                    revisionGroup.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Gap(8),

                  // Description
                  Text(
                    revisionGroup.description,
                    style: TextStyle(
                      color: ColorManager.darkGrey,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Gap(10),

                  // Meeting date and time
                  Row(
                    children: [
                      Icon(FeatherIcons.calendar,
                          size: 14, color: ColorManager.grey),
                      const Gap(5),
                      Text(
                        formattedMeetingDate,
                        style: TextStyle(
                          fontSize: 12,
                          color: ColorManager.grey,
                        ),
                      ),
                      const Gap(15),
                      Icon(FeatherIcons.clock,
                          size: 14, color: ColorManager.grey),
                      const Gap(5),
                      Text(
                        revisionGroup.meetingTime,
                        style: TextStyle(
                          fontSize: 12,
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
                          revisionGroup.meetingLocation,
                          style: TextStyle(
                            fontSize: 12,
                            color: ColorManager.grey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const Gap(10),

                  // Group capacity indicator
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Saturation',
                            style: TextStyle(
                              fontSize: 12,
                              color: ColorManager.grey,
                            ),
                          ),
                          Text(
                            '$saturationPercentage%',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: _getSaturationColor(saturationPercentage),
                            ),
                          ),
                        ],
                      ),
                      const Gap(5),
                      LinearPercentIndicator(
                        width: MediaQuery.of(context).size.width - 60,
                        lineHeight: 8.0,
                        percent: saturationPercentage / 100,
                        progressColor:
                            _getSaturationColor(saturationPercentage),
                        backgroundColor: ColorManager.lightGrey3,
                        barRadius: const Radius.circular(4),
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Action button
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isFull && !isMember ? null : onJoin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isMember
                      ? ColorManager.lightGrey
                      : isFull
                          ? Colors.grey
                          : ColorManager.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  isMember
                      ? 'Déjà inscrit'
                      : isFull
                          ? 'Complet'
                          : 'Participer',
                  style: TextStyle(
                    color: isMember || isFull
                        ? ColorManager.darkGrey
                        : Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getSubjectColor(String subject) {
    switch (subject) {
      case 'Mathématiques':
        return Colors.blue;
      case 'Physique':
        return Colors.teal;
      case 'Informatique':
        return Colors.purple;
      case 'Histoire':
        return Colors.orange;
      case 'Anglais':
        return Colors.red;
      default:
        return ColorManager.primaryColor;
    }
  }

  Color _getSaturationColor(int saturationPercentage) {
    if (saturationPercentage >= 90)
      return ColorManager.error; // Red when almost full
    if (saturationPercentage >= 75)
      return ColorManager.amber; // Amber/orange when getting full
    if (saturationPercentage >= 50)
      return ColorManager.primaryColor; // Primary blue when half full
    return ColorManager.greenbtn2; // Green when plenty of spots available
  }
}
