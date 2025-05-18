import 'package:card_swiper/card_swiper.dart';
import 'package:educonnect/routes/app_routing.dart';
import 'package:educonnect/widgets/input/custom_input.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:gap/gap.dart';
import 'package:educonnect/features/home/controller/homeController.dart';
import 'package:educonnect/widgets/customText.dart';
import 'dart:math';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:educonnect/widgets/text/custom_text.dart';
import '../../../core/themes/string_manager.dart';
import '/../core/themes/color_mangers.dart';
import '../../../widgets/customIcon.dart';
import '../widget/customDrawer.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController homeController = Get.put(HomeController());

    return Scaffold(
        backgroundColor: ColorManager.lightGrey3,
        drawer: customDrawer(context: context),
        appBar: AppBar(
            actionsIconTheme: const IconThemeData(
              color: ColorManager.white,
            ),
            iconTheme: const IconThemeData(color: ColorManager.white, size: 30),
            backgroundColor: ColorManager.primaryColor,
            toolbarHeight: Get.height * 0.07,
            shadowColor: ColorManager.black,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(20),
              ),
            ),
            title: Column(
              children: [
                Row(
                  children: [
                    Gap(
                      Get.width / 4,
                    ),
                    customText(
                        text: 'home',
                        textStyle: TextStyle(
                            color: ColorManager.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w400)),
                    Spacer(),
                    // Row(
                    //   children: [
                    //     Icon(
                    //       FeatherIcons.messageCircle,
                    //       color: ColorManager.white,
                    //       size: 23,
                    //     ),
                    //     Gap(20),
                    CircleAvatar(
                        radius: 20,
                        backgroundColor: ColorManager.white,
                        child: Image.asset(
                          'assets/images/userimg.png',
                          width: 25,
                          height: 25,
                        )),
                    //   ],
                    // )
                  ],
                ),
              ],
            )),
        body: SingleChildScrollView(
          padding: const EdgeInsets.only(left: 15, top: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Gap(5),
              Obx(
                () {
                  final firstName = homeController.userData['firstName'];
                  return customText(
                    text: firstName != null
                        ? 'Bienvenue , ${firstName.toUpperCase()} ! 👋 '
                        : 'Bienvenue, monsieur 👋',
                    textStyle: StylesManager.headline2,
                  );
                },
              ),
              customText(
                text: 'Voici ce qui se passe avec vos cours',
                textStyle: StylesManager.subtitle2,
              ),
              const Gap(10),
              CustomTextFormField(
                height: Get.height * 0.055,
                icon: Icon(
                  FeatherIcons.search,
                  color: ColorManager.SoftBlack,
                  size: 20,
                ),
                inputType: TextInputType.text,
                texthint: 'Search for a class',
                obscureText: true,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a class name';
                  }
                  return null;
                },
              ),
              Gap(10),
              customText(text: 'Nouvelles', textStyle: StylesManager.headline2),
              Gap(10),
              Obx(() {
                if (homeController.isLoadingAnnouncements.value) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: ColorManager.primaryColor,
                    ),
                  );
                }

                if (homeController.announcements.isEmpty) {
                  return Container(
                    width: Get.width * 0.8,
                    height: Get.height * 0.2,
                    decoration: BoxDecoration(
                        color: ColorManager.lightGrey3,
                        borderRadius: BorderRadius.circular(20),
                        border:
                            Border.all(color: Colors.grey.withOpacity(0.2))),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            FeatherIcons.bell,
                            color: Colors.grey,
                            size: 40,
                          ),
                          Gap(10),
                          customText(
                            text: 'Aucune annonce pour le moment',
                            textStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return Swiper(
                  itemCount: homeController.announcements.length,
                  itemWidth: Get.width * 0.8,
                  itemHeight: Get.height * 0.2,
                  layout: SwiperLayout.STACK,
                  itemBuilder: (context, index) {
                    final announcement = homeController.announcements[index];
                    Color cardColor;
                    IconData notificationIcon;

                    // Extract color from hex string if available, or use default colors
                    try {
                      if (announcement['colorHex'] != null) {
                        cardColor = Color(int.parse(
                            '0xFF${announcement['colorHex'].substring(1)}'));
                      } else {
                        cardColor = ColorManager.blueprimaryColor;
                      }
                    } catch (e) {
                      cardColor = ColorManager.blueprimaryColor;
                    }

                    // Determine icon based on keywords in title or description
                    final title = announcement['title'] ?? '';
                    final description = announcement['description'] ?? '';
                    final lowerTitle = title.toLowerCase();
                    final lowerDesc = description.toLowerCase();

                    if (lowerTitle.contains('cours') ||
                        lowerDesc.contains('cours') ||
                        lowerTitle.contains('session') ||
                        lowerDesc.contains('session') ||
                        lowerTitle.contains('révision') ||
                        lowerDesc.contains('révision')) {
                      notificationIcon = FeatherIcons.bookOpen;
                    } else if (lowerTitle.contains('document') ||
                        lowerDesc.contains('document') ||
                        lowerTitle.contains('fichier') ||
                        lowerDesc.contains('fichier')) {
                      notificationIcon = FeatherIcons.file;
                    } else if (lowerTitle.contains('événement') ||
                        lowerDesc.contains('événement') ||
                        lowerTitle.contains('seminaire') ||
                        lowerDesc.contains('seminaire') ||
                        lowerTitle.contains('conference') ||
                        lowerDesc.contains('conference')) {
                      notificationIcon = FeatherIcons.calendar;
                    } else {
                      notificationIcon = FeatherIcons.bell;
                    }

                    return GestureDetector(
                      onTap: () {
                        homeController.markAnnouncementAsRead(announcement.id);
                        // You could navigate to a details page here
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Stack(
                          children: [
                            // Background design
                            Positioned.fill(
                              child: Image.asset(
                                'assets/images/card_bg.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                            // Notification content
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        notificationIcon,
                                        color: ColorManager.white,
                                        size: 24,
                                      ),
                                      const Gap(10),
                                      Expanded(
                                        child: customText(
                                          text: announcement['title'] ??
                                              'Annonce',
                                          textStyle: TextStyle(
                                            color: ColorManager.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Gap(10),
                                  Expanded(
                                    child: customText(
                                      text: announcement['description'] ?? '',
                                      textStyle: TextStyle(
                                        color: ColorManager.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  const Gap(5),
                                  customText(
                                    text: _formatTimestamp(
                                        announcement['createdAt']),
                                    textStyle: TextStyle(
                                      color: ColorManager.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  onTap: (index) {
                    // Handle tap on notification
                    homeController.markAnnouncementAsRead(
                        homeController.announcements[index].id);
                    // You could add navigation here
                  },
                );
              }),
              SingleChildScrollView(
                padding: EdgeInsets.only(top: 20, left: 10),
                child: Wrap(
                  children: [
                    // Stats Row

                    // Fonctionnalités pour les étudiants
                    customText(
                      text: 'Fonctionnalités principales',
                      textStyle: StylesManager.headline2,
                    ),
                    const Gap(35),

                    // Gestion des groupes
                    _buildFeatureCard(
                      title: 'groupes',
                      icon: FeatherIcons.users,
                      onTap: () {
                        AppRoutes().goTo(AppRoutes.groupe);
                      },
                    ),

                    // Planification des sessions
                    _buildFeatureCard(
                      title: 'révision',
                      icon: FeatherIcons.bookOpen,
                      onTap: () {
                        AppRoutes().goTo(AppRoutes.revisionSessions);
                      },
                    ),

                    // Organisation des sorties
                    _buildFeatureCard(
                      title: 'événements',
                      icon: FeatherIcons.calendar,
                      onTap: () {
                        AppRoutes().goTo(AppRoutes.events);
                      },
                    ),

                    // Partage de documents
                    _buildFeatureCard(
                      title: 'documents',
                      icon: FeatherIcons.file,
                      onTap: () {
                        AppRoutes().goTo(AppRoutes.documentSharing);
                      },
                    ),

                    // Messagerie et notifications
                    _buildFeatureCard(
                      title: 'messagerie',
                      icon: FeatherIcons.messageCircle,
                      onTap: () {
                        AppRoutes().goTo(AppRoutes.groupe);
                      },
                    ),

                    const Gap(24),

                    // Espace d'échange
                    customText(
                      text: 'Espace d\'échange educatif',
                      textStyle: StylesManager.headline2,
                    ),
                    const Gap(35), // Forum de discussion
                    _buildFeatureCard(
                      title: 'Forum',
                      icon: FeatherIcons.users,
                      onTap: () {
                        // Navigate to forum screen
                      },
                    ),

                    // Groupes par filière
                    _buildFeatureCard(
                      title: 'Filières',
                      icon: FeatherIcons.briefcase,
                      onTap: () {
                        AppRoutes().goTo(AppRoutes.majorGroups);
                      },
                    ),

                    // Système Q&A
                    _buildFeatureCard(
                      title: '(Q&A)',
                      icon: FeatherIcons.helpCircle,
                      onTap: () {
                        // Navigate to Q&A screen
                      },
                    ),

                    // Chat en direct
                    _buildFeatureCard(
                      title: 'Chat',
                      icon: FeatherIcons.messageSquare,
                      onTap: () {
                        // Navigate to live chat screen
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }

  Widget _buildFeatureCard({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final random = Random();
    final randomColor = Color.fromRGBO(
      random.nextInt(255),
      random.nextInt(255),
      random.nextInt(255),
      0.2,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: Get.width * 0.28,
          margin: EdgeInsets.only(right: 10),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: randomColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Icon(
                  icon,
                  color: Colors.black54,
                  size: 23,
                ),
              ),
              const Gap(16),
              customText(
                text: title,
                textStyle: StylesManager.bodyText2,
              ),
              // Icon(
              //   Icons.arrow_forward_ios,
              //   color: ColorManager.grey,
              //   size: 18,
              // ),
            ],
          ),
        ),
      ),
    );
  }
}

// Helper function to format Firebase Timestamp
String _formatTimestamp(dynamic timestamp) {
  if (timestamp == null) return 'Date inconnue';

  try {
    DateTime date;

    // Handle direct Firestore Timestamp object
    if (timestamp is Timestamp) {
      return '${timestamp.toDate().day}/${timestamp.toDate().month}/${timestamp.toDate().year}';
    }
    // Handle Firestore Timestamp that was converted to Map
    else if (timestamp is Map) {
      if (timestamp.containsKey('seconds') &&
          timestamp.containsKey('nanoseconds')) {
        final seconds = timestamp['seconds'];
        final nanoseconds = timestamp['nanoseconds'] ?? 0;

        if (seconds != null) {
          final milliseconds = seconds * 1000 + (nanoseconds ~/ 1000000);
          date = DateTime.fromMillisecondsSinceEpoch(milliseconds);
          return '${date.day}/${date.month}/${date.year}';
        }
      } else if (timestamp.containsKey('_seconds') &&
          timestamp.containsKey('_nanoseconds')) {
        final seconds = timestamp['_seconds'];
        final nanoseconds = timestamp['_nanoseconds'] ?? 0;

        if (seconds != null) {
          final milliseconds = seconds * 1000 + (nanoseconds ~/ 1000000);
          date = DateTime.fromMillisecondsSinceEpoch(milliseconds);
          return '${date.day}/${date.month}/${date.year}';
        }
      }
    }
    // Handle DateTime object
    else if (timestamp is DateTime) {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
    // Handle String representation
    else if (timestamp is String) {
      try {
        // Try to parse Firebase Console format
        if (timestamp.contains('at')) {
          final parts = timestamp.split(' at ');
          final datePart = parts[0];
          final timePart = parts[1].split(' ')[0];
          final dateTimeStr = '$datePart $timePart';

          // Try various date formats
          final formats = [
            'MMMM d, yyyy h:mm:ss',
            'MMMM dd, yyyy h:mm:ss',
            'MMM d, yyyy h:mm:ss',
            'MMM dd, yyyy h:mm:ss'
          ];

          DateTime? parsedDate;
          for (final format in formats) {
            try {
              parsedDate = DateFormat(format, 'en_US').parse(dateTimeStr);
              break;
            } catch (e) {
              // Continue trying other formats
            }
          }

          if (parsedDate != null) {
            return '${parsedDate.day}/${parsedDate.month}/${parsedDate.year}';
          }
        }

        // Try standard ISO format
        date = DateTime.parse(timestamp);
        return '${date.day}/${date.month}/${date.year}';
      } catch (e) {
        // If all parsing fails, just return the original string
        return timestamp;
      }
    }

    // If we got here, we couldn't parse the timestamp
    print(
        'Could not parse timestamp: $timestamp (Type: ${timestamp.runtimeType})');
    return 'Date inconnue';
  } catch (e) {
    print('Error formatting timestamp: $e');
    return 'Date inconnue';
  }
}
