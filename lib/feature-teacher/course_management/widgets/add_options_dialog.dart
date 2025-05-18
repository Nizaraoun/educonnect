import 'package:flutter/material.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:gap/gap.dart';
import '../../../../core/themes/color_mangers.dart';
import 'add_dialog_button.dart';

class AddOptionsDialog extends StatelessWidget {
  final VoidCallback onAddCourse;
  final VoidCallback onAddDocument;

  const AddOptionsDialog({
    Key? key,
    required this.onAddCourse,
    required this.onAddDocument,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Que souhaitez-vous ajouter ?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: ColorManager.SoftBlack,
            ),
          ),
          Gap(24),
          Row(
            children: [
              Expanded(
                child: AddDialogButton(
                  icon: FeatherIcons.bookOpen,
                  label: 'Nouveau Cours',
                  color: ColorManager.primaryColor,
                  onTap: onAddCourse,
                ),
              ),
              Gap(16),
              Expanded(
                child: AddDialogButton(
                  icon: FeatherIcons.file,
                  label: 'Nouveau Document',
                  color: ColorManager.blueprimaryColor,
                  onTap: onAddDocument,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
