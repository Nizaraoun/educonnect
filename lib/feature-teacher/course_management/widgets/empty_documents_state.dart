import 'package:flutter/material.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:gap/gap.dart';
import '../../../../core/themes/color_mangers.dart';

class EmptyDocumentsState extends StatelessWidget {
  final VoidCallback onAddPressed;

  const EmptyDocumentsState({
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
            FeatherIcons.fileText,
            size: 48,
            color: ColorManager.grey.withOpacity(0.5),
          ),
          Gap(16),
          Text(
            'Aucun document trouvé',
            style: TextStyle(
              color: ColorManager.grey,
              fontSize: 16,
            ),
          ),
          Gap(8),
          TextButton.icon(
            onPressed: onAddPressed,
            icon: Icon(FeatherIcons.upload),
            label: Text('Ajouter un document'),
          ),
        ],
      ),
    );
  }
}
