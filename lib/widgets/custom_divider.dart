import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/themes/color_mangers.dart';
class DividerWidget extends StatelessWidget {
  final Color color;
  const DividerWidget({
    this.color = ColorManager.grayColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Divider(
        height: Get.height * 0.03,
        thickness: Get.width * 0.002,
        indent: Get.width * 0.03,
        endIndent: Get.width * 0.03,
        color: color,
      ),
    );
  }
}
