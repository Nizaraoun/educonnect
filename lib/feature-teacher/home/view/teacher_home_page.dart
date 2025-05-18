import 'package:card_swiper/card_swiper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:educonnect/core/themes/color_mangers.dart';
import 'package:educonnect/features/home/controller/homeController.dart';
import 'package:educonnect/routes/app_routing.dart';
import 'package:educonnect/widgets/text/custom_text.dart';
import 'package:educonnect/widgets/input/custom_input.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../../widgets/customText.dart';
import '../controller/teacher_home_controller.dart';
import '../widget/teacher_drawer.dart';

class TeacherHomePage extends StatelessWidget {
  const TeacherHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TeacherHomeController controller = Get.put(TeacherHomeController());

    return Scaffold(
      backgroundColor: ColorManager.lightGrey3,
      drawer: teacherCustomDrawer(context: context),
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
        title: Row(
          children: [
            customText(
              text: 'Tableau de bord',
              textStyle: TextStyle(
                color: ColorManager.white,
                fontSize: 18,
                fontWeight: FontWeight.w400,
              ),
            ),
            const Spacer(),
            CircleAvatar(
              radius: 20,
              backgroundColor: ColorManager.white,
              child: Image.asset(
                'assets/images/userimg.png',
                width: 25,
                height: 25,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(
              FeatherIcons.messageCircle,
              color: ColorManager.white,
              size: 26,
            ),
            onPressed: () {
              AppRoutes().goTo(AppRoutes.messaging);
            },
          ),
          const Gap(10),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            customText(
              text: 'Bienvenue, Professeur ! 👋',
              textStyle: TextStyle(
                color: ColorManager.SoftBlack,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            // Upcoming Exams
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                customText(
                  text: 'Examens à venir',
                  textStyle: TextStyle(
                    color: ColorManager.SoftBlack,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () => controller.navigateToExamPlanning(),
                  child: customText(
                    text: 'Voir tous',
                    textStyle: TextStyle(
                      color: ColorManager.primaryColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const Gap(15),
            Obx(() {
              if (controller.isLoadingExams.value) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: ColorManager.primaryColor,
                  ),
                );
              }

              if (controller.upcomingExams.isEmpty) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: ColorManager.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Icon(
                        FeatherIcons.calendar,
                        color: ColorManager.grey,
                        size: 40,
                      ),
                      const Gap(10),
                      customText(
                        text: 'Aucun examen planifié',
                        textStyle: TextStyle(
                          color: ColorManager.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.upcomingExams.length,
                itemBuilder: (context, index) {
                  final exam = controller.upcomingExams[index];
                  final examDate = exam['date'] as DateTime;
                  final isWithin3Days =
                      examDate.difference(DateTime.now()).inDays <= 3;
                  return GestureDetector(
                      onTap: () => controller.navigateToExamDetails(exam['id']),
                      child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: ColorManager.white,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: isWithin3Days
                                  ? ColorManager.amber.withOpacity(0.5)
                                  : Colors.transparent,
                              width: isWithin3Days ? 1 : 0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: isWithin3Days
                                      ? ColorManager.amber.withOpacity(0.1)
                                      : ColorManager.primaryColor
                                          .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  FeatherIcons.fileText,
                                  color: isWithin3Days
                                      ? ColorManager.amber
                                      : ColorManager.primaryColor,
                                  size: 24,
                                ),
                              ),
                              const Gap(15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    customText(
                                      text: exam['title'] ?? '',
                                      textStyle: TextStyle(
                                        color: ColorManager.SoftBlack,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    customText(
                                      text: exam['course'] ?? '',
                                      textStyle: TextStyle(
                                        color: ColorManager.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const Gap(5),
                                    Row(
                                      children: [
                                        Icon(
                                          FeatherIcons.calendar,
                                          size: 12,
                                          color: isWithin3Days
                                              ? ColorManager.amber
                                              : ColorManager.grey,
                                        ),
                                        const Gap(5),
                                        customText(
                                          text: DateFormat('dd/MM/yyyy')
                                              .format(examDate),
                                          textStyle: TextStyle(
                                            color: isWithin3Days
                                                ? ColorManager.amber
                                                : ColorManager.grey,
                                            fontSize: 12,
                                            fontWeight: isWithin3Days
                                                ? FontWeight.w600
                                                : FontWeight.normal,
                                          ),
                                        ),
                                        const Gap(10),
                                        Icon(
                                          FeatherIcons.clock,
                                          size: 12,
                                          color: ColorManager.grey,
                                        ),
                                        const Gap(5),
                                        customText(
                                          text: exam['duration'] ?? '',
                                          textStyle: TextStyle(
                                            color: ColorManager.grey,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Gap(5),
                                    Row(
                                      children: [
                                        Icon(
                                          FeatherIcons.mapPin,
                                          size: 12,
                                          color: ColorManager.grey,
                                        ),
                                        const Gap(5),
                                        customText(
                                          text: exam['location'] ?? '',
                                          textStyle: TextStyle(
                                            color: ColorManager.grey,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )));
                },
              );
            }),

            const Gap(20),

            // Announcements Section
            customText(
              text: 'Annonces',
              textStyle: TextStyle(
                color: ColorManager.SoftBlack,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Gap(15),

            // New Announcement Button
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 15),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: ColorManager.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 20,
                    backgroundColor: ColorManager.lightGrey,
                    child: Icon(
                      FeatherIcons.plus,
                      color: ColorManager.primaryColor,
                      size: 20,
                    ),
                  ),
                  const Gap(15),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        // Show dialog to create new announcement
                        _showCreateAnnouncementDialog(context, controller);
                      },
                      child: customText(
                        text: 'Créer une nouvelle annonce...',
                        textStyle: TextStyle(
                          color: ColorManager.grey,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      // Show dialog to create new announcement
                      _showCreateAnnouncementDialog(context, controller);
                    },
                    icon: const Icon(
                      FeatherIcons.edit,
                      color: ColorManager.primaryColor,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),

            // Announcements List
            Obx(() {
              if (controller.isLoadingAnnouncements.value) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: ColorManager.primaryColor,
                  ),
                );
              }

              if (controller.announcements.isEmpty) {
                return Container(
                  width: Get.width * 0.8,
                  height: Get.height * 0.2,
                  decoration: BoxDecoration(
                    color: ColorManager.lightGrey3,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.withOpacity(0.2)),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          FeatherIcons.bell,
                          color: Colors.grey,
                          size: 40,
                        ),
                        Gap(10),
                        Text(
                          'Aucune annonce pour le moment',
                          style: TextStyle(
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
                itemCount: controller.announcements.length,
                itemWidth: Get.width * 0.8,
                itemHeight: Get.height * 0.2,
                layout: SwiperLayout.STACK,
                itemBuilder: (context, index) {
                  final announcement = controller.announcements[index].data()
                      as Map<String, dynamic>;
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
                    onTap: () {},
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
                                        text:
                                            announcement['title'] ?? 'Annonce',
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
              );
            }),

            const Gap(30),

            // Features Section
            customText(
              text: 'Fonctionnalités enseignants',
              textStyle: TextStyle(
                color: ColorManager.SoftBlack,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Gap(20),
            Wrap(
              spacing: 15,
              runSpacing: 15,
              children: [
                _buildFeatureCard(
                  title: 'Gestion des cours',
                  icon: FeatherIcons.bookOpen,
                  color: const Color(0xFF4CAF50),
                  onTap: () {
                    AppRoutes().goTo(AppRoutes.teacherCourseManagement);
                  },
                ),
                _buildFeatureCard(
                  title: 'Planification des examens',
                  icon: FeatherIcons.clipboard,
                  color: const Color(0xFF2196F3),
                  onTap: () {
                    AppRoutes().goTo(AppRoutes.teacherExamPlanning);
                  },
                ),
                // _buildFeatureCard(
                //   title: 'Stratégies pédagogiques',
                //   icon: FeatherIcons.target,
                //   color: const Color(0xFFF44336),
                //   onTap: () {
                //     AppRoutes().goTo(AppRoutes.teacherTeachingStrategies);
                //   },
                // ),
                // _buildFeatureCard(
                //   title: 'Tableau analytique',
                //   icon: FeatherIcons.pieChart,
                //   color: const Color(0xFF9C27B0),
                //   onTap: () {
                //     AppRoutes().goTo(AppRoutes.teacherAnalyticsDashboard);
                //   },
                // ),
                _buildFeatureCard(
                  title: 'Messagerie',
                  icon: FeatherIcons.messageCircle,
                  color: const Color(0xFFFF9800),
                  onTap: () {
                    AppRoutes().goTo(AppRoutes.messaging);
                  },
                ),
                // _buildFeatureCard(
                //   title: 'Forum',
                //   icon: FeatherIcons.users,
                //   color: const Color(0xFF795548),
                //   onTap: () {
                //     AppRoutes().goTo(AppRoutes.forum);
                //   },
                // ),
              ],
            ),

            const Gap(30),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 28,
          ),
          const Gap(8),
          customText(
            text: value,
            textStyle: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          customText(
            text: label,
            textStyle: TextStyle(
              color: color.withOpacity(0.8),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        width: Get.width * 0.27,
        height: 150,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(50),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const Gap(10),
            customText(
              text: title,
              textStyle: TextStyle(
                color: color.withOpacity(0.8),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateAnnouncementDialog(
      BuildContext context, TeacherHomeController controller) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              customText(
                text: 'Créer une annonce',
                textStyle: TextStyle(
                  color: ColorManager.SoftBlack,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Gap(20),
              CustomTextFormField(
                height: 50,
                formcontroller: titleController,
                icon: Icon(
                  FeatherIcons.edit3,
                  color: ColorManager.SoftBlack,
                  size: 20,
                ),
                inputType: TextInputType.text,
                texthint: 'Titre de l\'annonce',
                obscureText: false,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Veuillez entrer un titre';
                  }
                  return null;
                },
              ),
              const Gap(15),
              CustomTextFormField(
                height: 100,
                formcontroller: descriptionController,
                icon: Icon(
                  FeatherIcons.alignLeft,
                  color: ColorManager.SoftBlack,
                  size: 20,
                ),
                inputType: TextInputType.multiline,
                texthint: 'Description de l\'annonce',
                obscureText: false,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Veuillez entrer une description';
                  }
                  return null;
                },
              ),
              const Gap(20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: customText(
                      text: 'Annuler',
                      textStyle: TextStyle(
                        color: ColorManager.SoftBlack,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const Gap(10),
                  ElevatedButton(
                    onPressed: () {
                      if (titleController.text.isNotEmpty &&
                          descriptionController.text.isNotEmpty) {
                        controller.createAnnouncement(
                          titleController.text,
                          descriptionController.text,
                        );
                        Get.back();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorManager.primaryColor,
                      foregroundColor: ColorManager.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: customText(
                      text: 'Publier',
                      textStyle: TextStyle(
                        color: ColorManager.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Helper function to format Firebase Timestamp (copied from student home page)
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
