import 'package:intl/intl.dart';

import 'package:educonnect/routes/app_routing.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

import '../../../core/themes/color_mangers.dart';
import '../../../widgets/icons/custom_button.dart';
import '../../../widgets/text/custom_text.dart';
import '../controller/ChatController.dart';
import 'group_chat_screen.dart';

class Conversation extends StatefulWidget {
  const Conversation({super.key});

  @override
  State<Conversation> createState() => _ConversationState();
}

class _ConversationState extends State<Conversation> {
  late ChatController chatController;

  @override
  void initState() {
    super.initState();
    // Initialize controller
    chatController = Get.put(ChatController());

    // Reload data when this screen is mounted
    WidgetsBinding.instance.addPostFrameCallback((_) {
      chatController.refreshData();
    });
  }

  @override
  Widget build(BuildContext context) {
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
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      child: CustomText(
                        txt: "Conversations",
                        color: ColorManager.white,
                        size: Get.width / 16,
                        fontweight: FontWeight.bold,
                        spacing: 0,
                      ),
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
                  child: Obx(() {
                    if (chatController.isLoading.value) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (chatController.forums.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 64,
                              color: ColorManager.grey,
                            ),
                            const Gap(16),
                            CustomText(
                              txt: "Aucune conversation pour le moment",
                              color: ColorManager.grey,
                              size: Get.width / 22,
                              fontweight: FontWeight.w500,
                              spacing: 0,
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                        itemCount: chatController.forums.length,
                        itemBuilder: (context, index) {
                          final forum = chatController.forums[index];
                          final lastMessage =
                              chatController.lastMessages[forum.id] ??
                                  "Pas de messages";
                          final lastMessageTime =
                              chatController.lastMessageTimes[forum.id];

                          return GestureDetector(
                              onTap: () {
                                // Navigate to group chat screen when a chat is tapped
                                Get.to(() => GroupChatScreen(
                                      forumId: forum.id,
                                      groupName: forum.groupName,
                                    ));
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
                                  txt: forum.groupName,
                                  color: ColorManager.black,
                                  size: Get.width / 19,
                                  fontweight: FontWeight.w600,
                                  spacing: 0,
                                ),
                                subtitle: Text(lastMessage),
                                // Display the last message time or members count
                                trailing: lastMessageTime != null
                                    ? Text(_formatTime(lastMessageTime))
                                    : Text("${forum.memberIds.length} membres"),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                              ));
                        });
                  })))
        ]));
  }

  // Format the time for display
  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateToCheck = DateTime(time.year, time.month, time.day);

    if (dateToCheck == today) {
      return DateFormat('HH:mm').format(time);
    } else if (dateToCheck == yesterday) {
      return 'Hier';
    } else {
      return DateFormat('dd/MM').format(time);
    }
  }
}
