import 'package:educonnect/core/themes/color_mangers.dart';
import 'package:educonnect/widgets/customIcon.dart';
import 'package:flutter/material.dart';

Widget customProfieImage({
  required double redius,
}) {
  return Stack(
    children: [
      CircleAvatar(
          radius: redius,
          backgroundImage: const AssetImage("assets/images/userimg.png")),
      Positioned(
        bottom: 0,
        right: 0,
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: ColorManager.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: IconButton(
                icon: Icon(
                  Icons.edit,
                  color: ColorManager.grey,
                ),
                color: ColorManager.grey,
                onPressed: () {}),
          ),
        ),
      ),
    ],
  );
}
