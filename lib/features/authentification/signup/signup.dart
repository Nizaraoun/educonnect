import 'package:educonnect/routes/app_routing.dart';
import 'package:educonnect/widgets/button/custom_inkwell.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import '../../../core/themes/color_mangers.dart';
import '../../../core/utils/input_validation.dart';
import '../../../widgets/CustomElevatedButton.dart';
import '../../../widgets/auth_social_logins.dart';
import '../../../widgets/customIcon.dart';
import '../../../widgets/custom_divider.dart';
import '../../../widgets/customtext.dart';
import '../../../widgets/input/custom_input.dart';
import '../../../widgets/text/custom_text.dart';
import '../auth_controller.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    AthControllerImp controller = Get.put(AthControllerImp());

    return Scaffold(
      backgroundColor: ColorManager.primaryColor,
      body: CustomScrollView(slivers: [
        SliverAppBar(
          expandedHeight: 250,
          floating: true,
          pinned: true,
          backgroundColor: ColorManager.primaryColor,
          leading: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: CustomIconButton(
              icon: Icons.arrow_back,
              onPressed: () {
                AppRoutes().goToEnd(AppRoutes.login);
              },
              color: ColorManager.white,
              size: 30,
            ),
          ),
          flexibleSpace: FlexibleSpaceBar(
            centerTitle: true,
            title: CustomText(
              txt: 'Créer un compte',
              color: ColorManager.white,
              fontweight: FontWeight.w500,
              size: 20,
              spacing: 0.0,
              fontfamily: 'Tajawal',
            ),
            background: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                color: ColorManager.primaryColor,
              ),
              child: Center(
                child: Image.asset(
                  'assets/images/bug.png',
                  fit: BoxFit.contain,
                  height: 150,
                ),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Container(
            padding: EdgeInsets.only(
              left: Get.width * 0.03,
              right: Get.width * 0.03,
              top: Get.height * 0.04,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              color: ColorManager.white,
            ),
            child: Form(
              key: controller.formstatesingup,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  CustomTextFormField(
                    color: ColorManager.white,
                    inputType: TextInputType.name,
                    icon: const Icon(Icons.person_outline),
                    texthint: "votre prénom",
                    validator: (p0) {
                      if (p0!.isEmpty) {
                        return "ce champ est obligatoire";
                      }
                      controller.inputsignup[0] = p0;
                      return null;
                    },
                    height: Get.height / 15,
                  ),
                  CustomTextFormField(
                    color: ColorManager.white,
                    inputType: TextInputType.name,
                    icon: const Icon(Icons.person_outline),
                    texthint: "votre nom",
                    validator: (p0) {
                      if (p0!.isEmpty) {
                        return "ce champ est obligatoire";
                      }
                      controller.inputsignup[1] = p0;
                      return null;
                    },
                    height: Get.height / 15,
                  ),
                  CustomTextFormField(
                    color: ColorManager.white,
                    inputType: TextInputType.emailAddress,
                    icon: const Icon(Icons.email_outlined),
                    texthint: "votre email",
                    validator: (p0) {
                      controller.inputsignup[2] = p0!;
                      return validInput(p0, "email");
                    },
                    height: Get.height / 15,
                  ),
                  CustomTextFormField(
                    color: ColorManager.white,
                    inputType: TextInputType.phone,
                    icon: const Icon(Icons.phone),
                    texthint: "votre numéro de téléphone",
                    validator: (p0) {
                      controller.inputsignup[3] = p0!;
                      return validInput(p0, "phone");
                    },
                    height: Get.height / 15,
                  ),
                  DropdownButtonFormField<String>(
                    value: controller.userType.value,
                    items: ['student', 'teacher']
                        .map((label) => DropdownMenuItem(
                              value: label,
                              child: Text(label),
                            ))
                        .toList(),
                    hint: Text('Type d\'utilisateur'),
                    onChanged: (value) {
                      controller.userType.value = value;
                    },
                    validator: (value) {
                      if (value == null) {
                        return "ce champ est obligatoire";
                      }
                      return null;
                    },
                  ),
                  Obx(() {
                    if (controller.userType.value == 'student') {
                      return Column(
                        children: [
                          CustomTextFormField(
                            color: ColorManager.white,
                            inputType: TextInputType.text,
                            icon: const Icon(Icons.school),
                            texthint: "votre spécialité",
                            validator: (p0) {
                              controller.inputsignup[4] = p0!;
                              return null;
                            },
                            height: Get.height / 15,
                          ),
                          CustomTextFormField(
                            color: ColorManager.white,
                            inputType: TextInputType.number,
                            icon: const Icon(Icons.calendar_today),
                            texthint: "votre année d'étude",
                            validator: (p0) {
                              controller.inputsignup[5] = p0!;
                              return null;
                            },
                            height: Get.height / 15,
                          ),
                        ],
                      );
                    } else {
                      return SizedBox.shrink();
                    }
                  }),
                  Obx(() {
                    if (controller.userType == 'teacher') {
                      return Column(
                        children: [
                          CustomTextFormField(
                            color: ColorManager.white,
                            inputType: TextInputType.text,
                            icon: const Icon(Icons.business),
                            texthint: "votre département",
                            validator: (p0) {
                              controller.inputsignup[4] = p0!;
                              return null;
                            },
                            height: Get.height / 15,
                          ),
                          CustomTextFormField(
                            color: ColorManager.white,
                            inputType: TextInputType.text,
                            icon: const Icon(Icons.book),
                            texthint: "votre spécialisation",
                            validator: (p0) {
                              controller.inputsignup[5] = p0!;
                              return null;
                            },
                            height: Get.height / 15,
                          ),
                        ],
                      );
                    } else {
                      return SizedBox.shrink();
                    }
                  }),
                  Gap(Get.height * 0.02),
                  CustomTextFormField(
                    color: ColorManager.white,
                    obscureText: true,
                    inputType: TextInputType.visiblePassword,
                    icon: const Icon(Icons.lock),
                    texthint: "votre mot de passe",
                    validator: (p0) {
                      controller.inputsignup[6] = p0!;
                      return validInput(p0, "IsPassword");
                    },
                    height: Get.height / 15,
                  ),
                  Gap(Get.height * 0.02),
                  Obx(
                    () => controller.isLoading.value
                        ? CircularProgressIndicator()
                        : Center(
                            child: customElevatedButton(
                              text: "Créer un compte",
                              onPressed: () {
                                controller.signUp();
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
                  Gap(Get.height * 0.02),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomInkWell(
                          ontap: () {
                            AppRoutes().goTo(AppRoutes.login);
                          },
                          widget: customText(
                            text: 'se connecter',
                            textStyle: TextStyle(
                                color: ColorManager.blueprimaryColor,
                                fontSize: Get.width * 0.045,
                                fontWeight: FontWeight.w400,
                                letterSpacing: 0),
                          )),
                      Gap(Get.width * 0.02),
                      Text(
                        'vous avez déjà un compte?',
                        style: TextStyle(
                          color: ColorManager.grey,
                          fontSize: Get.width * 0.042,
                        ),
                      ),
                    ],
                  ),
                  Gap(Get.width * 0.06),
                  // Row(
                  //   children: [
                  //     const DividerWidget(),
                  //     Text(
                  //       'ou connectez-vous avec',
                  //       style: TextStyle(
                  //         color: ColorManager.grey,
                  //         fontSize: Get.width * 0.05,
                  //       ),
                  //     ),
                  //     const DividerWidget(),
                  //   ],
                  // ),
                  // Gap(Get.width * 0.06),
                  // const auth_social_logins(
                  //     logo: "assets/images/google.png",
                  //     text: "Register avec google"),
                  // const SizedBox(
                  //   height: 20,
                  // ),
                  // const auth_social_logins(
                  //     logo: "assets/images/apple.png",
                  //     text: "Register avec Apple"),
                  // const SizedBox(
                  //   height: 20,
                  // ),
                  // const auth_social_logins(
                  //     logo: "assets/images/facebook.png",
                  //     text: "Register avec Facebook"),
                  // Gap(Get.width * 0.06),
                ],
              ),
            ),
          ),
        ),
      ]),
    );
  }
}
