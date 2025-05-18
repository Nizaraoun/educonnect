import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

import '../../../core/themes/color_mangers.dart';
import '../../../widgets/custom_profile_image.dart';
import '../../../widgets/icons/custom_button.dart';
import '../../../widgets/text/custom_text.dart';
import '../controller/profileDetailsController.dart';

class ProfileDetails extends StatelessWidget {
  ProfileDetails({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileDetailsController controller =
        Get.put(ProfileDetailsController());

    return Scaffold(
      backgroundColor: ColorManager.greybg,
      body: Obx(() => controller.isLoading.value
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, controller),
                  _buildPersonalInfoSection(context, controller),
                  _buildInvitationCodeSection(context, controller),
                ],
              ),
            )),
    );
  }

  Widget _buildHeader(
      BuildContext context, ProfileDetailsController controller) {
    return Container(
      padding: EdgeInsets.only(top: Get.height * 0.005),
      margin: EdgeInsets.only(bottom: 30),
      decoration: BoxDecoration(
        color: ColorManager.primaryColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
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
              Gap(10),
              CustomIconButton(
                padding: EdgeInsets.all(Get.width / 35),
                icon: Icon(FeatherIcons.arrowLeft),
                onPressed: () {
                  Get.back();
                },
                color: ColorManager.black,
                style: ButtonStyle(
                  elevation: WidgetStateProperty.all(7),
                  shadowColor: WidgetStateProperty.all(ColorManager.black),
                  backgroundColor: WidgetStateProperty.all(ColorManager.white),
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                ),
                tooltip: 'Retour',
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
          Gap(10),
          Obx(
            () {
              final firstName = controller.userData['firstName'] ?? '';
              final lastName = controller.userData['lastName'] ?? '';
              return CustomText(
                txt: '$firstName $lastName'.toUpperCase(),
                color: ColorManager.white,
                size: Get.width / 17,
                fontweight: FontWeight.bold,
                spacing: 1,
                fontfamily: 'Cairo',
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoSection(
      BuildContext context, ProfileDetailsController controller) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ColorManager.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: ColorManager.lightGrey2,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            txt: 'Informations Personnelles',
            color: ColorManager.primaryColor,
            size: Get.width / 20,
            fontweight: FontWeight.bold,
            spacing: 0.5,
            fontfamily: 'Cairo',
          ),
          Divider(thickness: 1),
          Gap(10),
          _buildInfoItem(
            context,
            'ID',
            controller.userData['id'] ?? '',
            Icon(FeatherIcons.hash, color: ColorManager.grey),
          ),
          _buildInfoItem(
            context,
            'Email',
            controller.userData['email'] ?? '',
            Icon(FeatherIcons.mail, color: ColorManager.grey),
          ),
          _buildInfoItem(
            context,
            'Téléphone',
            controller.userData['phone'] ?? '',
            Icon(FeatherIcons.phone, color: ColorManager.grey),
          ),
          _buildInfoItem(
            context,
            'Type de compte',
            controller.userData['userType'] == 'student'
                ? 'Étudiant'
                : 'Enseignant',
            Icon(FeatherIcons.user, color: ColorManager.grey),
          ),
          if (controller.userData['userType'] == 'student') ...[
            _buildInfoItem(
              context,
              'Filière',
              controller.userData['major'] ?? '',
              Icon(FeatherIcons.book, color: ColorManager.grey),
            ),
            _buildInfoItem(
              context,
              'Année d\'étude',
              controller.userData['yearOfStudy']?.toString() ?? '',
              Icon(FeatherIcons.calendar, color: ColorManager.grey),
            ),
          ] else if (controller.userData['userType'] == 'teacher') ...[
            _buildInfoItem(
              context,
              'Département',
              controller.userData['department'] ?? '',
              Icon(FeatherIcons.briefcase, color: ColorManager.grey),
            ),
            _buildInfoItem(
              context,
              'Spécialisation',
              controller.userData['specialization'] ?? '',
              Icon(FeatherIcons.award, color: ColorManager.grey),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoItem(
      BuildContext context, String label, String value, Icon icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          icon,
          Gap(15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  txt: label,
                  color: ColorManager.grey,
                  size: 14,
                  fontweight: FontWeight.w400,
                  spacing: 0.5,
                  fontfamily: 'Tajawal',
                ),
                Gap(2),
                CustomText(
                  txt: value,
                  color: ColorManager.black,
                  size: 16,
                  fontweight: FontWeight.w500,
                  spacing: 0.5,
                  fontfamily: 'Tajawal',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvitationCodeSection(
      BuildContext context, ProfileDetailsController controller) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ColorManager.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: ColorManager.lightGrey2,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            txt: 'Code d\'invitation',
            color: ColorManager.primaryColor,
            size: Get.width / 20,
            fontweight: FontWeight.bold,
            spacing: 0.5,
            fontfamily: 'Cairo',
          ),
          Divider(thickness: 1),
          Gap(20),
          Obx(() {
            final hasCode = controller.invitationCode.isNotEmpty;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (hasCode) ...[
                  Center(
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      decoration: BoxDecoration(
                        color: ColorManager.greybg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: ColorManager.primaryColor,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CustomText(
                            txt: controller.invitationCode.value,
                            color: ColorManager.primaryColor,
                            size: 20,
                            fontweight: FontWeight.bold,
                            spacing: 2,
                            fontfamily: 'Roboto',
                          ),
                          Gap(15),
                          IconButton(
                            icon: Icon(
                              Icons.copy,
                              color: ColorManager.grey,
                            ),
                            onPressed: () {
                              Clipboard.setData(ClipboardData(
                                  text: controller.invitationCode.value));
                              Get.snackbar(
                                'Copié',
                                'Code d\'invitation copié dans le presse-papier',
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor:
                                    ColorManager.green.withOpacity(0.7),
                                colorText: ColorManager.white,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  Gap(20),
                  Center(
                    child: CustomText(
                      txt:
                          "Partagez ce code avec vos amis pour leur permettre de rejoindre un canal (révision, groupe privé ou chat) sur la plateforme.",
                      color: ColorManager.grey,
                      size: 14,
                      fontweight: FontWeight.w400,
                      spacing: 0.5,
                      fontfamily: 'Tajawal',
                    ),
                  ),
                  Gap(20),
                ] else ...[
                  Center(
                    child: CustomText(
                      txt:
                          'Vous n\'avez pas encore de code d\'invitation. Générez-en un pour inviter vos amis à rejoindre la plateforme.',
                      color: ColorManager.grey,
                      size: 14,
                      fontweight: FontWeight.w400,
                      spacing: 0.5,
                      fontfamily: 'Tajawal',
                    ),
                  ),
                  Gap(20),
                ],
                ElevatedButton(
                  onPressed: controller.isGeneratingCode.value
                      ? null
                      : controller.generateInvitationCode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorManager.primaryColor,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Obx(() => controller.isGeneratingCode.value
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: ColorManager.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              hasCode
                                  ? FeatherIcons.refreshCw
                                  : FeatherIcons.plusCircle,
                              color: ColorManager.white,
                              size: 18,
                            ),
                            Gap(8),
                            CustomText(
                              txt: hasCode
                                  ? 'Générer un nouveau code'
                                  : 'Générer un code d\'invitation',
                              color: ColorManager.white,
                              size: 14,
                              fontweight: FontWeight.w500,
                              spacing: 0.5,
                              fontfamily: 'Tajawal',
                            ),
                          ],
                        )),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}
