import 'package:flutter/material.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:gap/gap.dart';
import '../../../../core/themes/color_mangers.dart';
import '../../../../widgets/custom_text.dart';
import '../model/course_model.dart';

class CourseListItem extends StatelessWidget {
  final Course course;
  final VoidCallback onEdit;
  final VoidCallback onViewDetails;

  const CourseListItem({
    Key? key,
    required this.course,
    required this.onEdit,
    required this.onViewDetails,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color courseColor;
    try {
      courseColor = Color(int.parse('0xFF${course.color.substring(1)}'));
    } catch (e) {
      courseColor = ColorManager.primaryColor;
    }

    return GestureDetector(
      onTap: onViewDetails,
      child: Container(
        margin: EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: courseColor.withOpacity(0.1),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                border: Border(
                  left: BorderSide(
                    color: courseColor,
                    width: 4,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: courseColor.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      FeatherIcons.bookOpen,
                      color: courseColor,
                      size: 24,
                    ),
                  ),
                  Gap(16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: customText(
                                text: course.title,
                                textStyle: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: ColorManager.SoftBlack,
                                ),
                              ),
                            ),
                            customText(
                              text: course.code,
                              textStyle: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: courseColor,
                              ),
                            ),
                          ],
                        ),
                        Gap(4),
                        customText(
                          text:
                              '${course.students} étudiants • ${course.schedule}',
                          textStyle: TextStyle(
                            fontSize: 12,
                            color: ColorManager.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Gap(8),
                  Container(
                    width: 90,
                    child: Wrap(
                      children: [
                        IconButton(
                          constraints: BoxConstraints(),
                          padding: EdgeInsets.all(8),
                          onPressed: onEdit,
                          icon: Icon(
                            FeatherIcons.edit,
                            size: 18,
                            color: ColorManager.grey,
                          ),
                        ),
                        IconButton(
                          constraints: BoxConstraints(),
                          padding: EdgeInsets.all(8),
                          onPressed: onViewDetails,
                          icon: Icon(
                            FeatherIcons.externalLink,
                            size: 18,
                            color: courseColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
