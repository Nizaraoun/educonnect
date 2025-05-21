import 'package:educonnect/core/themes/color_mangers.dart';
import 'package:educonnect/routes/app_routing.dart';
import 'package:educonnect/widgets/text/custom_text.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

import '../../../widgets/customText.dart';

Widget teacherCustomDrawer({required BuildContext context}) {
  return Drawer(
    backgroundColor: ColorManager.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topRight: Radius.circular(20),
        bottomRight: Radius.circular(20),
      ),
    ),
    child: Column(
      children: [
        Container(
          width: double.infinity,
          height: Get.height * 0.25,
          decoration: const BoxDecoration(
            color: ColorManager.primaryColor,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 40,
                backgroundColor: ColorManager.white,
                child: Icon(
                  Icons.person,
                  size: 50,
                  color: ColorManager.primaryColor,
                ),
              ),
              const Gap(10),
              customText(
                text: 'Prof',
                textStyle: const TextStyle(
                  color: ColorManager.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              customText(
                text: 'prof@educonnect.com',
                textStyle: const TextStyle(
                  color: ColorManager.white,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        const Gap(10),
        _buildDrawerItem(
          icon: FeatherIcons.home,
          title: 'Tableau de bord',
          onTap: () {
            Navigator.pop(context);
            // Navigate to Dashboard
            AppRoutes().goTo(AppRoutes.teacherHome);
          },
        ),
        _buildDrawerItem(
          icon: FeatherIcons.bookOpen,
          title: 'Gestion des cours',
          onTap: () {
            Navigator.pop(context);
            // Navigate to Course Management
            AppRoutes().goTo(AppRoutes.teacherCourseManagement);
          },
        ),
        _buildDrawerItem(
          icon: FeatherIcons.clipboard,
          title: 'Planification des examens',
          onTap: () {
            Navigator.pop(context);
            // Navigate to Exam Planning
            AppRoutes().goTo(AppRoutes.teacherExamPlanning);
          },
        ),
       
        _buildDrawerItem(
          icon: FeatherIcons.messageCircle,
          title: 'Messagerie',
          onTap: () {
            Navigator.pop(context);
            // Navigate to Messaging
            AppRoutes().goTo(AppRoutes.messaging);
          },
        ),
       
        const Spacer(),
        _buildDrawerItem(
          icon: FeatherIcons.settings,
          title: 'Paramètres',
          onTap: () {
            Navigator.pop(context);
            // Navigate to Settings
            AppRoutes().goTo(AppRoutes.settings);
          },
        ),
        _buildDrawerItem(
          icon: FeatherIcons.logOut,
          title: 'Déconnexion',
          onTap: () {
            Navigator.pop(context);
            // Handle logout
            // For now, just navigate to login
            AppRoutes().goToEnd(AppRoutes.login);
          },
        ),
        const Gap(20),
      ],
    ),
  );
}

Widget _buildDrawerItem({
  required IconData icon,
  required String title,
  required VoidCallback onTap,
}) {
  return ListTile(
    leading: Icon(
      icon,
      color: ColorManager.primaryColor,
    ),
    title: customText(
      text: title,
      textStyle: TextStyle(
        color: ColorManager.SoftBlack,
        fontSize: 16,
      ),
    ),
    onTap: onTap,
  );
}
