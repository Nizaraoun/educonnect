import 'dart:convert';

import 'package:educonnect/routes/app_routing.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

import '../../../core/themes/color_mangers.dart';
import '../../../widgets/icons/custom_button.dart';
import '../../../widgets/text/custom_text.dart';
import '../controller/ChatController.dart';

class Conversation extends StatelessWidget {
  const Conversation({super.key});

  @override
  Widget build(BuildContext context) {
    ChatController chatController = Get.put(ChatController());
    return Scaffold(
        backgroundColor: ColorManager.primaryColor,
        resizeToAvoidBottomInset: false,
        body: Column(children: [
          Expanded(
              flex: 2,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const Gap(20),
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: CustomIconButton(
                              icon: const Icon(Icons.arrow_back_ios_rounded),
                              onPressed: () {
                                // chatController.doctorList.clear();
                                // chatController.messages.clear();
                                // chatController.createAblyRealtimeInstance();
                                // chatController.getMessagesById(
                                //     chatController.chatList[0].doctorId!);
                                // AppRoutes().goTo(AppRoutes.chat);

                                AppRoutes().goToEnd(AppRoutes.dashboard);
                              },
                              color: ColorManager.primaryColor,
                              style: ButtonStyle(
                                backgroundColor: WidgetStateProperty.all(
                                  ColorManager.white,
                                ),
                                shape: WidgetStateProperty.all(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(42),
                                  ),
                                ),
                              ),
                              tooltip: "Retour",
                              padding: EdgeInsets.all(10),
                              iconSize: Get.width / 18,
                              alignment: Alignment.centerRight,
                              visualDensity:
                                  VisualDensity.adaptivePlatformDensity,
                              autofocus: true,
                              splashRadius: 4),
                        ),
                        const Spacer(),
                        CustomIconButton(
                          icon: const Icon(Icons.notifications),
                          onPressed: () {},
                          color: ColorManager.white,
                          tooltip: "Notification",
                          iconSize: Get.width / 14,
                          alignment: Alignment.centerRight,
                          visualDensity: VisualDensity.adaptivePlatformDensity,
                          autofocus: true,
                        ),
                      ],
                    ),
                  ],
                ),
              )),
          Expanded(
              flex: 9,
              child: Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: ColorManager.darkGrey,
                        blurRadius: 15,
                        spreadRadius: 1,
                        offset: const Offset(0, 0),
                      ),
                    ],
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color.fromARGB(255, 242, 248, 243), // #ebedee
                        Color.fromARGB(255, 255, 255, 255), // #fdfbfb
                      ],
                      stops: [0.0, 1.0],
                      transform:
                          GradientRotation(120 * (3.141592653589793 / 180)),
                    ),
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(50),
                    ),
                  ),
                  child: FutureBuilder(
                      future: Future.delayed(
                        const Duration(seconds: 3),
                      ),
                      builder: (context, snapshot) {
                        // if (snapshot.connectionState ==
                        //         ConnectionState.waiting &&
                        //     !controller.isLoading.value) {
                        //   return ListView.separated(
                        //     itemCount: 6,
                        //     itemBuilder: (context, index) =>
                        //         const NewsCardSkelton(),
                        //     separatorBuilder: (context, index) =>
                        //         const SizedBox(height: 15),
                        //   );
                        // } else {ù

                        // return Obx(() {
                        return ListView.builder(
                            itemCount: 5,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                  onTap: () {
                                    // chatController.doctorList.clear();
                                    // chatController.messages.clear();

                                    // chatController
                                    //     .createAblyRealtimeInstance();
                                    // chatController.getMessagesById(
                                    //     chatController
                                    //         .chatList[index].doctorId!);
                                    // chatController.doctorList.add(DoctorDto(
                                    //   image: chatController
                                    //       .chatList[index].image,
                                    //     id: chatController
                                    //         .chatList[index].doctorId,
                                    //     name: chatController
                                    //         .chatList[index].name,
                                    //     speciality: ""));

                                    // AppRoutes().goTo(AppRoutes.chat);
                                  },
                                  child: ListTile(
                                      leading: Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: ColorManager.primaryColor,
                                          ),
                                          shape: BoxShape.circle,
                                          image: DecorationImage(
                                            filterQuality: FilterQuality.high,
                                            alignment: Alignment.center,
                                            image: AssetImage(
                                              "assets/images/userimg.png",
                                            ),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        width: Get.width / 6.8,
                                        height: Get.width / 6,
                                      ),
                                      title: CustomText(
                                        txt: "Name Sender",
                                        color: ColorManager.black,
                                        size: Get.width / 19,
                                        fontweight: FontWeight.w600,
                                        spacing: 0,
                                      ), 
                                      subtitle: Text("subtitle message"),

                                      // Display the last message
                                      trailing: Text("12")));
                            });
                      })))
        ]));
  }
}
