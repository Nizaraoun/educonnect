import 'package:educonnect/feature-teacher/course_management/view/course_management_screen_updated.dart';
import 'package:educonnect/feature-teacher/exam_details/view/exam_details_screen.dart';
import 'package:educonnect/features/authentification/forgetpassword/forget_password_screen.dart';
import 'package:educonnect/features/authentification/forgetpassword/new_password_screen.dart';
import 'package:educonnect/features/authentification/signup/signup.dart';
import 'package:educonnect/features/events/view/events_screen.dart';
import 'package:educonnect/features/groupe/controller/group_controller.dart';
import 'package:educonnect/features/settings/view/profileDetails.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../feature-teacher/exam_planning/view/exam_planning_screen.dart';
import '../feature-teacher/home/view/teacher_home_page.dart';
import '../features/authentification/login/login.dart';
import '../features/chat/view/listchat.dart';
import '../features/document/view/DocumentScreen.dart';
import '../features/groupe/view/create_group_screen.dart';
import '../features/groupe/view/groupeScreen.dart';
import '../features/groupe/view/major_group_screen.dart';
import '../features/revision/view/revision_screen.dart';
import '../features/settings/view/profileScreen.dart';
import '/../features/onboarding/splashScreen.dart';
import '../features/home/view/homePage.dart';

class AppRoutes {
  static const home = '/';
  static const splash = '/splash';
  static const login = '/login';
  static const register = '/register';
  static const forgetPassword = '/forgetPassword';
  static const newPassword = '/newPassword';
  static const onboardingScreen = '/onboardingScreen';
  static const dashboard = '/dashboard'; // Page d'accueil après connexion
  static const profile = '/profile';
  static const profileDetails = '/profileDetails'; // Page de détails du profil
  static const personalInformation = '/personalInformation';
  static const privacyPolicy = '/privacyPolicy';
  static const studyGroups = '/studyGroups'; // Gestion des groupes de travail
  static const revisionSessions =
      '/revisionSessions'; // Planification des sessions de révision
  static const events = '/events'; // Organisation des sorties et événements
  static const documentSharing = '/documentSharing'; // Partage de documents
  static const messaging = '/messaging'; // Messagerie et notifications
  static const groupe = '/Groupe'; // Gestion des groupes de travail
  static const forum = '/forum'; // Forum de discussion
  static const qa = '/qa'; // Système de questions-réponses
  static const liveChat = '/liveChat'; // Chat en direct
  static const examDetails =
      '/exam-details'; // Page pour les détails d'un examen

  static const settings = '/settings';
  static const notifications = '/notifications';

  // Define the app routes mta3 el prof
  static const teacherHome = '/teacherHome';
  static const teacherCourseManagement = '/teacherCourseManagement';
  static const teacherExamPlanning = '/teacherExamPlanning';
  static const teacherTeachingStrategies = '/teacherTeachingStrategies';
  static const teacherAnalyticsDashboard = '/teacherAnalyticsDashboard';
  static const teacherMessaging = '/teacherMessaging';
  static const majorGroups = '/majorGroups'; // Groupes par majeur

  // the page routes
  List<GetPage> appRoutes = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const Splashscreen(),
      transition: Transition.rightToLeft,
      curve: Curves.easeIn,
      transitionDuration: Duration(milliseconds: 500),
    ),

    GetPage(
      name: AppRoutes.dashboard,
      page: () => HomePage(), // Page d'accueil après connexion
      transition: Transition.fadeIn,
      curve: Curves.easeIn,
      transitionDuration: Duration(milliseconds: 500),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => LoginScreen(), // Page de connexion
      transition: Transition.fadeIn,
      curve: Curves.easeIn,
      transitionDuration: Duration(milliseconds: 500),
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => const SignUpScreen(), // Page d'inscription
      transition: Transition.fadeIn,
      curve: Curves.easeIn,
      transitionDuration: Duration(milliseconds: 500),
    ),
    GetPage(
      name: AppRoutes.forgetPassword,
      page: () =>
          const ForgetPassword(), // Page de réinitialisation du mot de passe
      transition: Transition.fadeIn,
      curve: Curves.easeIn,
      transitionDuration: Duration(milliseconds: 500),
    ),
    GetPage(
      name: AppRoutes.newPassword,
      page: () => const NewPassword(), // Page de nouveau mot de passe
      transition: Transition.fadeIn,
      curve: Curves.easeIn,
      transitionDuration: Duration(milliseconds: 500),
    ),
    // GetPage(
    //   name: AppRoutes.onboardingScreen,
    //   page: () => const OnboardingScreen(), // Page d'introduction
    //   transition: Transition.fadeIn,
    //   curve: Curves.easeIn,
    //   transitionDuration: Duration(milliseconds: 500),
    // ),
    GetPage(
      name: AppRoutes.groupe,
      page: () => const GroupeScreen(), // Page d'accueil après connexion
      transition: Transition.fadeIn,
      curve: Curves.easeIn,
      transitionDuration: Duration(milliseconds: 500),
      // binding: BindingsBuilder(() {
      //   Get.put(GroupController());
      // }),
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => ProfileScreen(), // Page de profil
      transition: Transition.fadeIn,
      curve: Curves.easeIn,
      transitionDuration: Duration(milliseconds: 500),
    ),
    GetPage(
      name: AppRoutes.profileDetails,
      page: () => ProfileDetails(), // Page de détails du profil
      transition: Transition.fadeIn,
      curve: Curves.easeIn,
      transitionDuration: Duration(milliseconds: 500),
    ),
    // GetPage(
    //   name: AppRoutes.personalInformation,
    //   page: () => PersonalInformationView(), // Page d'informations personnelles
    //   transition: Transition.fadeIn,
    //   curve: Curves.easeIn,
    //   transitionDuration: Duration(milliseconds: 500),
    // ),
    // GetPage(
    //   name: AppRoutes.privacyPolicy,
    //   page: () =>
    //       const PrivacyPolicyScreen(), // Page de politique de confidentialité
    //   transition: Transition.fadeIn,
    //   curve: Curves.easeIn,
    //   transitionDuration: Duration(milliseconds: 500),
    // ),
    // GetPage(
    //   name: AppRoutes.studyGroups,
    //   page: () =>
    //       const StudyGroupsScreen(), // Page de gestion des groupes de travail
    //   transition: Transition.fadeIn,
    //   curve: Curves.easeIn,
    //   transitionDuration: Duration(milliseconds: 500),
    // ),
    GetPage(
      name: AppRoutes.revisionSessions,
      page: () =>
          const RevisionScreen(), // Page de planification des sessions de révision
      transition: Transition.fadeIn,
      curve: Curves.easeIn,
      transitionDuration: Duration(milliseconds: 500),
    ),
    GetPage(
      name: AppRoutes.events,
      page: () => const EventsScreen(), // Events screen
      transition: Transition.fadeIn,
      curve: Curves.easeIn,
      transitionDuration: Duration(milliseconds: 500),
    ),
    GetPage(
      name: AppRoutes.documentSharing,
      page: () => const DocumentScreen(), // Page de partage de documents
      transition: Transition.fadeIn,
      curve: Curves.easeIn,
      transitionDuration: Duration(milliseconds: 500),
    ),
    GetPage(
      name: AppRoutes.messaging,
      page: () => const Conversation(), // Page de messagerie
      transition: Transition.fadeIn,
      curve: Curves.easeIn,
      transitionDuration: Duration(milliseconds: 500),
    ),
    GetPage(
      name: AppRoutes.examDetails,
      page: () => const ExamDetailsScreen(),
      transition: Transition.fadeIn,
      curve: Curves.easeIn,
      transitionDuration: Duration(milliseconds: 500),
    ),
    GetPage(
      name: AppRoutes.majorGroups,
      page: () => const MajorGroupScreen(),
      transition: Transition.fadeIn,
      curve: Curves.easeIn,
      transitionDuration: Duration(milliseconds: 500),
    ),

    //  // Define the app routes for teachers
    GetPage(
      name: AppRoutes.teacherHome,
      page: () => const TeacherHomePage(), // Page d'accueil des enseignants
      transition: Transition.fadeIn,
      curve: Curves.easeIn,
      transitionDuration: Duration(milliseconds: 500),
    ),
    GetPage(
      name: AppRoutes.teacherCourseManagement,
      page: () => CourseManagementScreen(), // Page de gestion des cours
      transition: Transition.fadeIn,
      curve: Curves.easeIn,
      transitionDuration: Duration(milliseconds: 500),
    ),
    GetPage(
      name: AppRoutes.teacherExamPlanning,
      page: () =>
          const ExamPlanningScreen(), // Page de planification des examens
      transition: Transition.fadeIn,
      curve: Curves.easeIn,
      transitionDuration: Duration(milliseconds: 500),
    ),
    GetPage(
      name: AppRoutes.examDetails,
      page: () => const ExamDetailsScreen(), // Page de détails d'un examen
      transition: Transition.fadeIn,
      curve: Curves.easeIn,
      transitionDuration: Duration(milliseconds: 500),
    ),
    // GetPage(
    //   name: AppRoutes.teacherTeachingStrategies,
    //   page: () => const TeachingStrategiesScreen(),
    //   transition: Transition.fadeIn,
    //   curve: Curves.easeIn,
    //   transitionDuration: Duration(milliseconds: 500),
    // ),
  ];

// Routing method to navigate
  void goTo(String pagename, {dynamic requiredVariable}) {
    Get.toNamed(pagename,
        arguments: requiredVariable); // Pass the required variable as arguments
  }

// Routing method and remove all previous pages
  void goToEnd(String pagename) {
    Get.offAllNamed(pagename);
  }

// Routing method with variable
  void goTowithvarbiable(String pagename, dynamic requiredVariable) {
    Get.toNamed(pagename,
        arguments: requiredVariable); // Pass the required variable as arguments
  }
}
