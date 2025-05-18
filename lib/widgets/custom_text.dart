import 'package:flutter/material.dart';

// Simple implementation of customText to avoid errors
Widget customText({
  required String text,
  TextStyle? textStyle,
  TextAlign? textAlign,
  int? maxLines,
  TextOverflow? overflow,
}) {
  return Text(
    text,
    style: textStyle,
    textAlign: textAlign,
    maxLines: maxLines,
    overflow: overflow,
  );
}
