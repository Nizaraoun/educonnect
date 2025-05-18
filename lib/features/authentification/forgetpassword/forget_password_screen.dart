import 'package:educonnect/widgets/customAppBar.dart';
import 'package:educonnect/widgets/input/custom_input.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:educonnect/widgets/customtext.dart';

import '../../../core/themes/color_mangers.dart';
import '../../../core/utils/input_validation.dart';
import '../../../widgets/CustomElevatedButton.dart';
import '../auth_controller.dart';

class ForgetPassword extends StatelessWidget {
  const ForgetPassword({super.key});

  @override
  Widget build(BuildContext context) {
    AthControllerImp controller = Get.put(AthControllerImp());

    return Scaffold(
        extendBodyBehindAppBar: false,
        appBar: customAppBar(title: 'Mot de passe oublié'),
        body: SingleChildScrollView(
          clipBehavior: Clip.antiAliasWithSaveLayer,
          padding: EdgeInsets.only(
              top: Get.height * 0.05,
              left: Get.width * 0.05,
              right: Get.width * 0.05),
          child: Form(
            key: controller.newpassword,
            child: Column(
              textDirection: TextDirection.rtl,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset('assets/images/using-phone.png',
                    width: Get.width * 0.4, height: Get.height * 0.3),
                Gap(Get.height * 0.05),
                CustomTextFormField(
                  inputType: TextInputType.emailAddress,
                  icon: const Icon(FontAwesomeIcons.envelopeOpen),
                  texthint: '  Saissisez votre email',
                  validator: (p0) {
                    controller.inputlogin[0] = p0!;
                    return validInput(p0, "email");
                  },
                  height: Get.height * 0.07,
                ),
                Gap(Get.height * 0.05),
                customElevatedButton(
                  text: "Recuperer le mot de passe",
                  onPressed: () {
                    if (controller.newpassword.currentState!.validate()) {
                      controller.resetPassword(controller.inputlogin[0]);
                    }
                  },
                  color: ColorManager.primaryColor,
                  width: Get.width * 0.5,
                  height: Get.height * 0.06,
                  textStyle: const TextStyle(
                    color: ColorManager.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                  ),
                  borderRadius: 20,
                ),
              ],
            ),
          ),
        ));
  }
}
