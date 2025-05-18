// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/themes/color_mangers.dart';
import '../text/custom_text.dart';

class CustomButton extends StatelessWidget {
  final void Function()? Onpress;
  final String text;
  const CustomButton({super.key, this.Onpress, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(     
      padding: EdgeInsets.only(
        bottom: Get.height * 0.02,
        left: Get.width * 0.1,
        right: Get.width * 0.1,
      ),
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: ColorManager.SoftBlack,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          onPressed: Onpress,
          child: CustomText(
            fontfamily: 'barlow',
            txt: text,
            color: const Color.fromARGB(255, 241, 241, 241),
            size: Get.width * 0.065,
            fontweight: FontWeight.w600,
            spacing: 1,
          )),
    );
  }
}
