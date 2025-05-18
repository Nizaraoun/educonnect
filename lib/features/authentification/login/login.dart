import 'package:educonnect/routes/app_routing.dart';
import 'package:educonnect/widgets/button/custom_inkwell.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

import '../../../core/themes/color_mangers.dart';
import '../../../core/utils/input_validation.dart';
import '../../../widgets/CustomElevatedButton.dart';
import '../../../widgets/auth_social_logins.dart';
import '../../../widgets/custom_divider.dart';
import '../../../widgets/customtext.dart';
import '../../../widgets/input/custom_input.dart';
import '../../../widgets/text/custom_text.dart';
import '../auth_controller.dart';

// ignore: must_be_immutable
class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  AthControllerImp controller = Get.put(AthControllerImp());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: CustomScrollView(slivers: [
      SliverAppBar(
        centerTitle: true,
        title: customText(
          text: 'Connectez-vous',
          textStyle: TextStyle(
            color: ColorManager.black,
            fontSize: 20,
            fontWeight: FontWeight.w400,
            letterSpacing: 0,
          ),
        ),
        floating: true,
        pinned: true,
      ),
      SliverPadding(
          padding: EdgeInsets.only(
            left: Get.width * 0.03,
            right: Get.width * 0.03,
            top: Get.height * 0.08,
          ),
          sliver: SliverToBoxAdapter(
            child: Form(
              key: controller.formstatelogin,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // email
                  CustomTextFormField(
                    inputType: TextInputType.text,
                    icon: const Icon(Icons.email),
                    texthint: "Votre email",
                    validator: (p0) {
                      controller.inputlogin[0] = p0!;
                      return validInput(p0, "email");
                    },
                    height: Get.height / 10,
                    color: ColorManager.white,
                    enabled: true,
                  ),
                  //use to add space between widgets
                  Gap(Get.height * 0.02),
                  // password
                  CustomTextFormField(
                    height: Get.height / 10,
                    color: ColorManager.white,
                    obscureText: true,
                    inputType: TextInputType.text,
                    icon: const Icon(Icons.lock),
                    texthint: "Votre mot de passe",
                    validator: (p0) {
                      controller.inputlogin[1] = p0!;
                      return validInput(p0, "IsPassword");
                    },
                  ),
                  //use to add space between widgets
                  Gap(Get.height * 0.02),
                  CustomInkWell(
                    ontap: () {
                      AppRoutes().goTo(AppRoutes.forgetPassword);
                    },
                    widget: CustomText(
                      txt: 'Mot de passe oublié?',
                      color: ColorManager.primaryColor,
                      size: Get.width * 0.05,
                      fontweight: FontWeight.w500,
                      spacing: 0,
                    ),
                  ),
                  //use to add space between widgets
                  Gap(Get.height * 0.02),

                  // login button
                  Obx(
                    () => controller.isLoading.value
                        ? Center(child: CircularProgressIndicator())
                        : Center(
                            child: customElevatedButton(
                              text: "Se connecter",
                              onPressed: () {
                                controller.login();
                              },
                              textStyle: const TextStyle(
                                color: ColorManager.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w400,
                              ),
                              borderRadius: 20,
                              width: Get.width * 0.5,
                              height: Get.height * 0.07,
                              color: ColorManager.primaryColor,
                              // ... rest of your button properties
                            ),
                          ),
                  ),
                  //use to add space between widgets
                  Gap(Get.height * 0.04),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomInkWell(
                          ontap: () {
                            AppRoutes().goToEnd(AppRoutes.register);
                          },
                          widget: customText(
                            text: 'Créer un compte',
                            textStyle: TextStyle(
                                color: ColorManager.blueprimaryColor,
                                fontSize: Get.width * 0.045,
                                fontWeight: FontWeight.w400,
                                letterSpacing: 0),
                          )),
                      Gap(Get.width * 0.02),
                      Text(
                        'vous n\'avez pas de compte?',
                        style: TextStyle(
                          color: ColorManager.grey,
                          fontSize: Get.width * 0.04,
                        ),
                      ),
                    ],
                  ),
                  Gap(Get.width * 0.06),

                  Row(
                    children: [
                      const DividerWidget(),
                      Text(
                        'Ou connectez-vous avec',
                        style: TextStyle(
                          color: ColorManager.grey,
                          fontSize: Get.width * 0.035,
                        ),
                      ),
                      const DividerWidget(),
                    ],
                  ),
                  Gap(Get.width * 0.06),
                  // google button

                  const auth_social_logins(
                      logo: "assets/images/google.png",
                      text: "Login avec Google"),
                  const SizedBox(
                    height: 20,
                  ),
                  const auth_social_logins(
                      logo: "assets/images/apple.png",
                      text: "Login avec Apple"),
                  const SizedBox(
                    height: 20,
                  ),
                  const auth_social_logins(
                      logo: "assets/images/facebook.png",
                      text: "Login avec Facebook"),
                  Gap(Get.width * 0.06),
                ],
              ),
            ),
          ))
    ]));
  }
}
