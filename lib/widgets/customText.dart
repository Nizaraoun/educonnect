import 'package:flutter/material.dart';

Text customText({
  required String text,
  required TextStyle textStyle,
  TextAlign textAlign = TextAlign.start,
  TextDirection? textDirection, // Optional: Automatically detects if null
}) {
  return Text(
    text,
    style: textStyle,
    textAlign: textAlign,
    textDirection: textDirection ?? TextDirection.ltr,
  );
}
