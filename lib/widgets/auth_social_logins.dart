import 'package:flutter/material.dart';
import 'package:get/get.dart';

class auth_social_logins extends StatelessWidget {
  final String text;
  final String logo;

  const auth_social_logins({super.key, required this.logo, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Get.height * 0.06,
      width: Get.size.width * 02,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 255, 255, 255),
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: SizedBox(
            height: Get.height * 0.07,
            width: Get.width * 0.07,
            child: Image.asset(
              logo,
              filterQuality: FilterQuality.high,
            ),
          ),
        ),
        Expanded(
          child: Align(
            alignment: Alignment.center,
            child: Text(
              text,
              style: TextStyle(
                color: const Color.fromARGB(255, 0, 0, 0),
                fontSize: Get.width * 0.05,
              ),
            ),
          ),
        ),
        Container(
          height: 10,
          width: 10,
          color: const Color.fromARGB(255, 255, 255, 255),
        )
      ]),
    );
  }
}
