import 'package:flutter/material.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:gap/gap.dart';
import '../../../../core/themes/color_mangers.dart';

class EmptyCourseState extends StatelessWidget {
  final VoidCallback onAddPressed;

  const EmptyCourseState({
    Key? key,
    required this.onAddPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            FeatherIcons.bookOpen,
            size: 64,
            color: ColorManager.grey.withOpacity(0.5),
          ),
          Gap(24),
          Text(
            'Vous n\'avez pas encore créé de cours',
            style: TextStyle(
              color: ColorManager.grey,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          Gap(16),
          ElevatedButton.icon(
            onPressed: onAddPressed,
            icon: Icon(FeatherIcons.plus),
            label: Text('Créer un cours'),
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorManager.primaryColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}
