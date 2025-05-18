import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import '../../core/themes/assets_manager.dart';
import '../../core/themes/color_mangers.dart';
import '../../core/themes/string_manager.dart';
import '../../routes/app_routing.dart';
import '../../widgets/CustomElevatedButton.dart';
import '../../widgets/customText.dart';
import '../../core/services/auth_service.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  @override
  void initState() {
    super.initState();
    // Check if user is already logged in
    AuthService.getInitialRoute();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.primaryColor,
      body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Image.asset(
          AssetsManager.splashLogo,
          fit: BoxFit.cover,
          width: 500,
          height: 250,
        ),
        Text(
          textAlign: TextAlign.left,
          "Bienvenue sur EduConnect",
          style: StylesManager.headlinewhite,
        ),
        Gap(20),
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: customText(
            text:
                'Planifiez vos révisions, organisez vos groupes de travail, échangez avec vos enseignants et accédez à tous vos supports de cours en toute simplicité. Sécurisé, intuitif et pratique !',
            textStyle: StylesManager.subtitle2,
            textAlign: TextAlign.center,
          ),
        ),
        Gap(Get.height * 0.15),
        customElevatedButton(
            onPressed: () {
              AppRoutes().goToEnd(
                AppRoutes.login,
              );
            },
            text: "Commencer",
            textStyle: StylesManager.buttonText,
            width: Get.width * 0.8,
            height: 50,
            borderRadius: 10,
            color: ColorManager.white)
      ]),
    );
  }
}
