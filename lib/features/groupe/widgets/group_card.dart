import 'package:educonnect/core/themes/color_mangers.dart';
import 'package:educonnect/features/groupe/model/group_model.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

class GroupCard extends StatelessWidget {
  final GroupModel group;
  final bool isMember;
  final VoidCallback onTap;
  final VoidCallback onJoin;

  const GroupCard({
    Key? key,
    required this.group,
    this.isMember = false,
    required this.onTap,
    required this.onJoin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Format date for display
    final dateFormat = DateFormat('dd MMM yyyy', 'fr_FR');
    final formattedDate = dateFormat.format(group.createdAt);

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
          // Top section with category and members
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            decoration: BoxDecoration(
              color: _getCategoryColor(group.category).withOpacity(0.1),
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
                    color: _getCategoryColor(group.category),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    group.category,
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
                  '${group.memberCount} membres',
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
                  // Group name and visibility
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          group.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (!group.isPublic)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: ColorManager.lightGrey,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                FeatherIcons.lock,
                                size: 12,
                                color: ColorManager.grey,
                              ),
                              const Gap(5),
                              Text(
                                'Privé',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: ColorManager.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const Gap(8),

                  // Description
                  Text(
                    group.description,
                    style: TextStyle(
                      color: ColorManager.darkGrey,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Gap(10),

                  // Creator and date
                  Row(
                    children: [
                      Icon(FeatherIcons.user,
                          size: 14, color: ColorManager.grey),
                      const Gap(5),
                      Text(
                        'Créé par ${group.creatorName}',
                        style: TextStyle(
                          fontSize: 12,
                          color: ColorManager.grey,
                        ),
                      ),
                      const Spacer(),
                      Icon(FeatherIcons.clock,
                          size: 14, color: ColorManager.grey),
                      const Gap(5),
                      Text(
                        formattedDate,
                        style: TextStyle(
                          fontSize: 12,
                          color: ColorManager.grey,
                        ),
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
                onPressed: onJoin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isMember ? ColorManager.lightGrey : ColorManager.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  isMember ? 'Déjà membre' : 'Rejoindre le groupe',
                  style: TextStyle(
                    color: isMember ? ColorManager.darkGrey : Colors.white,
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

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Académique':
        return Colors.blue;
      case 'Technique':
        return Colors.teal;
      case 'Culturel':
        return Colors.purple;
      case 'Social':
        return Colors.orange;
      default:
        return ColorManager.primaryColor;
    }
  }
}