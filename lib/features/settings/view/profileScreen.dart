import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

import '../../../../generated/l10n.dart';
import '../../../core/themes/color_mangers.dart';
import '../../../core/themes/string_manager.dart';
import '../../../routes/app_routing.dart';
import '../../../widgets/custom_profile_image.dart';
import '../../../widgets/customtext.dart';
import '../../../widgets/drawer_widget.dart';
import '../../../widgets/icons/custom_button.dart';
import '../../../widgets/text/custom_text.dart';
import '../../../core/utils/localData.dart';
import '../../home/controller/homeController.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController homeController = Get.put(HomeController());

    return Scaffold(
      backgroundColor: ColorManager.greybg,
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.only(top: Get.height * 0.005),
              margin: const EdgeInsets.only(bottom: 30),
              decoration: const BoxDecoration(
                color: ColorManager.primaryColor,
                borderRadius: BorderRadius.all(Radius.circular(30)),
                boxShadow: [
                  BoxShadow(
                    color: ColorManager.lightGrey2,
                    blurRadius: 5,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              width: Get.width,
              height: Get.height / 3,
              child: Column(
                children: [
                  Gap(Get.height * 0.05),
                  Row(
                    children: [
                      const Gap(10),
                      CustomIconButton(
                        padding: EdgeInsets.all(Get.width / 35),
                        icon: const Icon(FontAwesomeIcons.xmark),
                        onPressed: () {
                          Get.back();
                        },
                        color: ColorManager.black,
                        style: ButtonStyle(
                          elevation: WidgetStateProperty.all(7),
                          shadowColor:
                              WidgetStateProperty.all(ColorManager.black),
                          backgroundColor:
                              WidgetStateProperty.all(ColorManager.white),
                          shape: WidgetStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                        ),
                        tooltip: S.of(context).back,
                        iconSize: Get.width / 20,
                        alignment: Alignment.centerLeft,
                        visualDensity: VisualDensity.adaptivePlatformDensity,
                        autofocus: true,
                      ),
                    ],
                  ),
                  customProfieImage(
                    redius: 50,
                  ),
                  const Gap(10),
                  Obx(
                    () {
                      final firstName = homeController.userData['firstName'] +
                          homeController.userData['lastName'];
                      return customText(
                        text: firstName != null
                            ? '${firstName.toUpperCase()} '
                            : 'User',
                        textStyle: StylesManager.headlinewhite,
                      );
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: CustomText(
                txt: S.of(context).settings,
                color: ColorManager.black,
                size: Get.width / 17,
                fontweight: FontWeight.bold,
                spacing: 1,
                fontfamily: 'Cairo',
              ),
            ),
            customContainerWithListTile(
              title: "Détails du profil",
              onTap: () {
                AppRoutes().goTo(AppRoutes.profileDetails);
              },
              icon: const Icon(
                FeatherIcons.user,
              ),
            ),
            customContainerWithListTile(
              title: "Notifications",
              onTap: () {},
              icon: const Icon(
                FeatherIcons.bell,
              ),
            ),
            customContainerWithListTile(
              title: S.of(context).changePassword,
              onTap: () {},
              icon: const Icon(
                FeatherIcons.lock,
              ),
            ),
            customContainerWithListTile(
              title: S.of(context).changeLanguage,
              onTap: () {},
              icon: const Icon(
                FeatherIcons.globe,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: CustomText(
                txt: S.of(context).about,
                color: ColorManager.black,
                size: Get.width / 17,
                fontweight: FontWeight.bold,
                spacing: 1,
                fontfamily: 'Cairo',
              ),
            ),
            customContainerWithListTile(
              title: S.of(context).privacyPolicy,
              onTap: () {},
              icon: const Icon(
                FeatherIcons.lock,
              ),
            ),
            customContainerWithListTile(
              title: S.of(context).logout,
              onTap: () {
                AppRoutes().goToEnd(AppRoutes.login);
              },
              icon: const Icon(
                FeatherIcons.logOut,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
