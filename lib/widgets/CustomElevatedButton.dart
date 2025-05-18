import 'package:flutter/material.dart';
import '/../core/themes/color_mangers.dart';

ElevatedButton customElevatedButton({
  required VoidCallback onPressed,
  required String text,
  required TextStyle textStyle,
  Color color = ColorManager.buttonColor,
  required double width,
  required double height,
  required double borderRadius,
}) {
  return ElevatedButton(
    onPressed: onPressed,
    child: Text(text, style: textStyle),
    style: ElevatedButton.styleFrom(
      foregroundColor: color,
      backgroundColor: color,
      minimumSize: Size(width, height),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    ),
  );
}
