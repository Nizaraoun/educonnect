
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';  
class CheckLanguage {


  static bool isArabic() {
    return Intl.getCurrentLocale() == 'ar';
  
  }

  static bool isEnglish() {
    return Intl.getCurrentLocale() == 'en';
  }

  static bool isFrench() {
    return Intl.getCurrentLocale() == 'fr';
  }
  
}