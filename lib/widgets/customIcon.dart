import 'package:flutter/material.dart';
import '/../core/themes/color_mangers.dart';

class CustomIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color color;
  final double size;

  const CustomIconButton(
      {Key? key,
      required this.icon,
      required this.onPressed,
      this.color = ColorManager.white,
      this.size = 35})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, color: color, size: size),
      onPressed: onPressed,
    );
  }
}
