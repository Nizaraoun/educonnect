import 'package:flutter/material.dart';

class CustomIconButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Icon icon;
  final Color? color;
  final double? iconSize;
  final Color? disabledColor;
  final double? splashRadius;
  final EdgeInsetsGeometry? padding;
  final AlignmentGeometry alignment;
  final VisualDensity visualDensity;
  final Color? focusColor;
  final Color? hoverColor;
  final Color? highlightColor;
  final Color? splashColor;
  final FocusNode? focusNode;
  final bool autofocus;
  final String? tooltip;
  final ButtonStyle? style;

  const CustomIconButton(
      {super.key,
      required this.onPressed,
      required this.icon,
      this.color,
      this.iconSize,
      this.disabledColor,
      this.splashRadius,
      this.padding,
      required this.alignment,
      required this.visualDensity,
      this.focusColor,
      this.hoverColor,
      this.highlightColor,
      this.splashColor,
      this.focusNode,
      required this.autofocus,
      this.tooltip,
      this.style});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: icon,
      color: color,
      iconSize: iconSize,
      disabledColor: disabledColor,
      splashRadius: splashRadius,
      padding: padding,
      alignment: alignment,
      visualDensity: visualDensity,
      focusColor: focusColor,
      hoverColor: hoverColor,
      highlightColor: highlightColor,
      splashColor: splashColor,
      focusNode: focusNode,
      autofocus: autofocus,
      tooltip: tooltip,
      style: style,
    );
  }
}
