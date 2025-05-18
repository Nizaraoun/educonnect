import 'package:flutter/material.dart';

import '../../core/themes/color_mangers.dart';

class CustomDropDown extends StatelessWidget {
  final List<DropdownMenuItem<String>>?  items;
  final String labes;
  final void Function(String?)? onChanged;
  const CustomDropDown(
      {super.key, required this.items, required this.labes, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      borderRadius: BorderRadius.circular(20),
      decoration: InputDecoration(
        counterStyle: TextStyle(color: ColorManager.black),
        labelText: labes,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      items: items,
          
      onChanged: onChanged,
    );
  }
}
