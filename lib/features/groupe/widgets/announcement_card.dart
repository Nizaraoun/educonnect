import 'package:educonnect/core/themes/color_mangers.dart';
import 'package:educonnect/features/groupe/model/group_model.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

class AnnouncementCard extends StatelessWidget {
  final GroupAnnouncementModel announcement;

  const AnnouncementCard({
    Key? key,
    required this.announcement,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Format date for display
    final dateFormat = DateFormat('dd MMM yyyy', 'fr_FR');
    final formattedDate = dateFormat.format(announcement.createdAt);
    final timeAgo = timeago.format(announcement.createdAt, locale: 'fr');

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
          // Header with author and time
          Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: ColorManager.lightGrey3,
                  child: Icon(
                    FeatherIcons.user,
                    color: ColorManager.darkGrey,
                    size: 18,
                  ),
                ),
                const Gap(10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        announcement.authorName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        timeAgo,
                        style: TextStyle(
                          color: ColorManager.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  FeatherIcons.moreVertical,
                  color: ColorManager.grey,
                  size: 20,
                ),
              ],
            ),
          ),

          // Divider
          Divider(
            color: ColorManager.lightGrey,
            height: 1,
          ),

          // Main content
          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  announcement.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Gap(10),
                Text(
                  announcement.content,
                  style: TextStyle(
                    color: ColorManager.darkGrey,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                if (announcement.attachments.isNotEmpty) ...[
                  const Gap(15),
                  ...announcement.attachments
                      .map((attachment) => _buildAttachment(attachment)),
                ],
              ],
            ),
          ),

          // Actions
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
            child: Row(
              children: [
                _buildActionButton(FeatherIcons.thumbsUp, 'J\'aime'),
                const Gap(15),
                _buildActionButton(FeatherIcons.messageSquare, 'Commenter'),
                const Gap(15),
                _buildActionButton(FeatherIcons.share2, 'Partager'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachment(String fileName) {
    IconData icon;
    Color color;

    if (fileName.endsWith('.pdf')) {
      icon = FeatherIcons.fileText;
      color = Colors.red;
    } else if (fileName.endsWith('.doc') || fileName.endsWith('.docx')) {
      icon = FeatherIcons.file;
      color = Colors.blue;
    } else if (fileName.endsWith('.xls') || fileName.endsWith('.xlsx')) {
      icon = FeatherIcons.fileText;
      color = Colors.green;
    } else if (fileName.endsWith('.jpg') ||
        fileName.endsWith('.png') ||
        fileName.endsWith('.jpeg')) {
      icon = FeatherIcons.image;
      color = Colors.purple;
    } else {
      icon = FeatherIcons.file;
      color = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: ColorManager.lightGrey3,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: 18,
          ),
          const Gap(10),
          Expanded(
            child: Text(
              fileName,
              style: const TextStyle(
                fontSize: 14,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Icon(
            FeatherIcons.download,
            color: ColorManager.primaryColor,
            size: 18,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label) {
    return Expanded(
      child: TextButton.icon(
        onPressed: () {},
        icon: Icon(
          icon,
          color: ColorManager.grey,
          size: 16,
        ),
        label: Text(
          label,
          style: TextStyle(
            color: ColorManager.grey,
            fontSize: 12,
          ),
        ),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 8),
        ),
      ),
    );
  }
}
