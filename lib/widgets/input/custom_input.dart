import 'package:flutter/material.dart';
import '../../core/themes/color_mangers.dart';

class CustomTextFormField extends StatelessWidget {
  final bool obscureText;
  final TextInputType inputType;
  final TextEditingController? formcontroller;
  final String? Function(String?) validator;
  final ValueChanged<String>? formOnChanged;
  final double height;
  final Icon icon;
  final String texthint;
  final VoidCallback? onTap;
  final Color color;
  final String? initialValue;
  final bool enabled;
  const CustomTextFormField({
    this.initialValue,
    this.enabled = true,
    super.key,
    required this.icon,
    required this.texthint,
    required this.inputType,
    required this.validator,
    this.obscureText = false,
    this.onTap,
    this.formcontroller,
    this.formOnChanged,
    required this.height,
    this.color = const Color.fromARGB(225, 255, 255, 255),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 5, right: 5, top: 10),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          boxShadow: [
            BoxShadow(
              color: ColorManager.grayColor.withOpacity(0.2),
              spreadRadius: 0,
              blurStyle: BlurStyle.normal,
              blurRadius: 10,
              offset: Offset(2, 1), // changes position of shadow
            ),
          ],
        ),
        child: TextFormField(
          initialValue: initialValue,
          enabled: enabled,
          onChanged: formOnChanged,
          controller: formcontroller,
          obscureText: obscureText,
          textAlign: TextAlign.left,
          keyboardType: inputType,
          keyboardAppearance: Brightness.dark,
          onTap: onTap,
          validator: validator,
          decoration: InputDecoration(
            iconColor: ColorManager.black,
            fillColor: color,
            filled: true,
            constraints: BoxConstraints(maxHeight: height),
            counterStyle: const TextStyle(
              height: double.minPositive,
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: ColorManager.white, width: 2.0),
              borderRadius: BorderRadius.circular(15),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                  color: ColorManager.blueprimaryColor, width: 2.0),
              borderRadius: BorderRadius.circular(10),
            ),
            hintText: texthint,
            hintStyle: TextStyle(
              color: ColorManager.blackLight,
              fontSize: 15,
            ),
            prefixIcon: icon,
          ),
        ),
      ),
    );
  }
}
