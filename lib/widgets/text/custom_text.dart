import 'package:flutter/widgets.dart';

class CustomText extends StatelessWidget {
  final String txt;
  final String fontfamily;
  final Color color;
  final double size;
  final FontWeight fontweight;
  final double spacing;
  const CustomText({
    super.key,
    required this.txt,
    required this.color,
    required this.size,
    required this.fontweight,
    required this.spacing,
    this.fontfamily = 'Cairo',
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      txt,
      style: TextStyle(
          fontFamily: fontfamily,
          color: color,
          fontSize: size,
          fontWeight: fontweight,
          letterSpacing: spacing),
    );
  }
}
