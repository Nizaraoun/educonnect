import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:educonnect/core/themes/color_mangers.dart';
import 'package:educonnect/core/services/auth_service.dart';
import 'core/utils/app-stat.dart';
import 'generated/l10n.dart';
import 'routes/app_routing.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  bool stat = await AppStatusService.App();

  if (stat) {
    AppStatusService.Apps();
  } else {
    String initialRoute = await AuthService.getInitialRoute();

    runApp(MyApp(initialRoute: initialRoute));
  }
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AuthService.setupAuthListener();
    });

    return GetMaterialApp(
      darkTheme: ThemeData.dark(),

      locale: const Locale('an'), // Set the locale to Arabic for RTL

      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      supportedLocales: S.delegate.supportedLocales,

      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        scaffoldBackgroundColor: ColorManager.scaffoldbg,
        useMaterial3: true,
      ),

      initialRoute: initialRoute,

      getPages: AppRoutes().appRoutes,

      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.ltr,
          child: child!,
        );
      },
    );
  }
}
