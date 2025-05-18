import 'dart:async';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/utils/check_internet.dart';

class Otpcontroller extends GetxController {
  var res;
  initiadata() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? Res = sharedPreferences.getString("Status");
    res = await checkInternet();
    Timer(const Duration(seconds: 3), () {
      if (res == true) {
        if (Res != null) {
        } else {}
      } else {
        Get.snackbar("Error", "Please Check Your Internet");
      }
    });

    update();
  }
}
