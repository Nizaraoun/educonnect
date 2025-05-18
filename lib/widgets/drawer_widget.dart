import 'package:flutter/material.dart';

import '../core/themes/color_mangers.dart';
import 'text/custom_text.dart';


Widget customContainerWithListTile(
    {required String title,
    required VoidCallback onTap,
    required Widget icon}) {
  return Container(
    margin: const EdgeInsets.only(right: 10, bottom: 20, left: 10),
    decoration: const BoxDecoration(
      color: ColorManager.white,
      borderRadius: BorderRadius.all(Radius.circular(15)),
    ),
    child: ListTile(
        title: CustomText(
          txt: title,
          color: ColorManager.black,
          size: 17,
          fontweight: FontWeight.w400,
          spacing: 0.4,
          fontfamily: 'Tajawal',
        ),
        onTap: onTap,
        leading: icon),
  );
}
