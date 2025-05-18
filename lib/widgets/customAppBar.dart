import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/themes/color_mangers.dart';
import '../widgets/customText.dart';

class customAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  const customAppBar({
    super.key,
    required this.title,
  });

  @override
  Size get preferredSize => Size.fromHeight(Get.height * 0.07);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      actionsIconTheme: const IconThemeData(
        color: ColorManager.white,
      ),
      iconTheme: const IconThemeData(color: ColorManager.white, size: 30),
      backgroundColor: ColorManager.primaryColor,
      toolbarHeight: Get.height * 0.07,
      shadowColor: ColorManager.black,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(20),
        ),
      ),
      title: customText(
          text: title,
          textStyle: TextStyle(
              color: ColorManager.white,
              fontSize: 18,
              fontWeight: FontWeight.w400)),
      
    );
  }
}
