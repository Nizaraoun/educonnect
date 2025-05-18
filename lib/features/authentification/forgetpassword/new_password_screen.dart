import 'package:educonnect/widgets/CustomElevatedButton.dart';
import 'package:educonnect/widgets/text/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:educonnect/widgets/customtext.dart';

import '../../../core/themes/color_mangers.dart';
import '../../../core/utils/input_validation.dart';
import '../../../widgets/input/custom_input.dart';
import '../auth_controller.dart';


class NewPassword extends StatelessWidget {
  const NewPassword({super.key});

  @override
  Widget build(BuildContext context) {
    AthControllerImp controller = Get.put(AthControllerImp());

    return Scaffold(
      backgroundColor: ColorManager.white2,
      resizeToAvoidBottomInset: false,
      extendBody: true,
      appBar: AppBar(
          centerTitle: true,
          title: const CustomText(
            txt: "modifiez votre mot de passe",
            size: 20,
            fontweight: FontWeight.bold,
            color: Colors.black,
            spacing: 0,
          )),
      body: Column(
        children: [
          Image.asset(
            'assets/images/newpassword.png',
            height: 200,
          ),
          Gap(Get.height * 0.03),
          CustomText(
            txt: "Entrez votre nouveau mot de passe",
            size: 20,
            fontweight: FontWeight.w600,
            color: ColorManager.darkestBlue,
            spacing: 0,
          ),
          Gap(Get.height * 0.04),
          Form(
            key: controller.newpassword,
            child: Column(
              children: [
                CustomTextFormField(
                  height: Get.height / 15,
                  obscureText: true,
                  texthint: "كلمة المرور الجديدة",
                  inputType: TextInputType.text,
                  validator: (p0) {
                    controller.inputnewpassword[0] = p0!;
                    return validInput(p0, "IsPassword");
                  },
                  icon: const Icon(FontAwesomeIcons.lock),
                ),
                Gap(Get.height * 0.01),
                CustomTextFormField(
                  height: Get.height / 15,
                  obscureText: true,
                  texthint: "تأكيد كلمة المرور الجديدة",
                  inputType: TextInputType.text,
                  validator: (p0) {
                    controller.inputnewpassword[1] = p0!;
                    return validInput(p0, "IsPassword");
                  },
                  icon: const Icon(FontAwesomeIcons.lock),
                ),
                Gap(Get.height * 0.05),
                customElevatedButton(
                  text: "confirmer", 
                  onPressed: () {
                    // controller.newPasswordFN();
                  },
                  color: ColorManager.primaryColor,
                  width: Get.width * 0.5,
                  height: Get.height * 0.07,
                  textStyle: const TextStyle(
                    color: ColorManager.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                  ),
                  borderRadius: 20,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
