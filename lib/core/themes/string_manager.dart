import 'package:flutter/material.dart';
import '../../core/themes/color_mangers.dart';

class StylesManager {
  // Headline Styles
  static TextStyle headline1 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w800,
    color: ColorManager.black,
    fontFamily: 'Montserrat',
  );
  static TextStyle headlinewhite = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w800,
    color: ColorManager.white,
    fontFamily: 'Montserrat',
  );
  static TextStyle headline2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w500,
    color: ColorManager.black,
  );

  // Subtitle Styles
  static const TextStyle subtitle1 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: Colors.grey,
  );

  static const TextStyle subtitle2 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: Colors.grey,
  );

  // Body Text Styles
  static TextStyle bodyText1 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: ColorManager.SoftBlack,
  );

  static const TextStyle bodyText2 = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: Colors.black54,
  );

  // Button Text Style
  static const TextStyle buttonText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Color.fromARGB(255, 0, 0, 0),
  );

  // Caption Style
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w300,
    color: Colors.grey,
  );
}
