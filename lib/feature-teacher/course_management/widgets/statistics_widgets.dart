import 'package:flutter/material.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:gap/gap.dart';
import '../../../../core/themes/color_mangers.dart';
import '../../../../widgets/custom_text.dart';

class StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const StatCard({
    Key? key,
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 28,
            color: color,
          ),
          Gap(8),
          customText(
            text: value,
            textStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: ColorManager.SoftBlack,
            ),
          ),
          Gap(4),
          customText(
            text: label,
            textStyle: TextStyle(
              fontSize: 14,
              color: ColorManager.grey,
            ),
          ),
        ],
      ),
    );
  }
}

class ActivityBar extends StatelessWidget {
  final String title;
  final String code;
  final double value;
  final Color color;
  final String count;
  final bool isLast;

  const ActivityBar({
    Key? key,
    required this.title,
    required this.code,
    required this.value,
    required this.color,
    required this.count,
    required this.isLast,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Gap(8),
                    Expanded(
                      child: customText(
                        text: '$code - $title',
                        textStyle: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: ColorManager.SoftBlack,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 4,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: value,
                    backgroundColor: ColorManager.lightGrey,
                    color: color,
                    minHeight: 8,
                  ),
                ),
              ),
              SizedBox(
                width: 60,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: customText(
                    text: '$count docs',
                    textStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: ColorManager.grey,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            color: ColorManager.lightGrey,
            height: 1,
          ),
      ],
    );
  }
}

class PopularDocumentItem extends StatelessWidget {
  final String title;
  final String type;
  final String course;
  final int downloads;
  final Color color;

  const PopularDocumentItem({
    Key? key,
    required this.title,
    required this.type,
    required this.course,
    required this.downloads,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determine icon based on file type
    IconData fileIcon;
    switch (type) {
      case 'pdf':
        fileIcon = FeatherIcons.fileText;
        break;
      case 'doc':
      case 'docx':
        fileIcon = FeatherIcons.file;
        break;
      case 'ppt':
      case 'pptx':
        fileIcon = FeatherIcons.monitor;
        break;
      default:
        fileIcon = FeatherIcons.file;
    }

    return Container(
      padding: EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: ColorManager.lightGrey,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              fileIcon,
              color: color,
              size: 20,
            ),
          ),
          Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                customText(
                  text: title,
                  textStyle: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: ColorManager.SoftBlack,
                  ),
                ),
                customText(
                  text: course,
                  textStyle: TextStyle(
                    fontSize: 12,
                    color: ColorManager.grey,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: ColorManager.blueprimaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  FeatherIcons.download,
                  size: 14,
                  color: ColorManager.blueprimaryColor,
                ),
                Gap(4),
                customText(
                  text: '$downloads',
                  textStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: ColorManager.blueprimaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
