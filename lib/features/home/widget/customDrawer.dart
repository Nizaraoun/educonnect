import 'package:educonnect/features/home/controller/homeController.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../generated/l10n.dart';
import '../../../core/themes/color_mangers.dart';
import '../../../core/themes/string_manager.dart';
import '../../../routes/app_routing.dart';
import '../../../widgets/custom_profile_image.dart';
import '../../../widgets/customtext.dart';
import '../../../widgets/drawer_widget.dart';
import '../../../widgets/text/custom_text.dart';

Widget customDrawer({
  required BuildContext context,
}) {
  final HomeController homeController = Get.put(HomeController());

  return Drawer(
    surfaceTintColor: const Color.fromARGB(104, 255, 255, 255),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(20),
      ),
    ),
    clipBehavior: Clip.antiAlias,
    backgroundColor: Colors.transparent,
    child: Container(
      decoration: BoxDecoration(
        color: ColorManager.greybg.withOpacity(0.8),
        borderRadius: const BorderRadius.all(Radius.circular(20)),
      ),
      child: SizedBox(
        height: Get.height,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.only(top: Get.height * 0.005),
                margin: const EdgeInsets.only(bottom: 30),
                decoration: const BoxDecoration(
                  color: ColorManager.white,
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                width: Get.width,
                height: Get.height / 4.5,
                child: Column(
                  children: [
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
                          textStyle: StylesManager.headline1,
                        );
                      },
                    ),
                  ],
                ),
              ),
              Gap(Get.height * 0.05),
              customContainerWithListTile(
                title: S.of(context).profile,
                onTap: () {
                  AppRoutes().goTo(AppRoutes.profile);
                },
                icon: const Icon(
                  FeatherIcons.user,
                ),
              ),
              customContainerWithListTile(
                title: "groupes de travail",
                onTap: () {},
                icon: const Icon(
                  FeatherIcons.users,
                ),
              ),
              customContainerWithListTile(
                title: "Messages",
                onTap: () {
                  AppRoutes().goTo(AppRoutes.messaging);
                },
                icon: const Icon(
                  FeatherIcons.calendar,
                ),
              ),
              customContainerWithListTile(
                title: "Notification ",
                onTap: () {},
                icon: const Icon(
                  FeatherIcons.bell,
                ),
              ),
              customContainerWithListTile(
                title: "Sessions de révision ",
                onTap: () {},
                icon: const Icon(
                  FeatherIcons.bookOpen,
                ),
              ),
              customContainerWithListTile(
                title: "Sorties et événements",
                onTap: () {},
                icon: const Icon(
                  FeatherIcons.calendar,
                ),
              ),
              customContainerWithListTile(
                title: "Partage de documents",
                onTap: () {
                  AppRoutes().goTo(AppRoutes.documentSharing);
                },
                icon: const Icon(
                  FeatherIcons.fileText,
                ),
              ),
              Gap(10),
              customContainerWithListTile(
                title: "Déconnexion",
                onTap: () {
                  AppRoutes().goToEnd(AppRoutes.login);
                },
                icon: const Icon(
                  FeatherIcons.logOut,
                ),
              ),
              CustomText(
                txt: 'Version 1.0.0',
                color: ColorManager.blackLight,
                size: 15,
                fontweight: FontWeight.bold,
                spacing: 1,
                fontfamily: 'Cairo',
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
