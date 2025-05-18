import 'package:get/get.dart';

validInput(String val, String type) {
  if (type == "username") {
    if (!GetUtils.isUsername(val)) {
      return "Le nom d'utilisateur est incorrect";
    }
  }
  if (type == "email") {
    if (!GetUtils.isEmail(val)) {
      return "Votre email est incorrect";
    }
  }

  // if (type == "phone") {
  //   if (!GetUtils.isTunisiaNumber(val)) {
  //     return "Le numéro de téléphone est incorrect";
  //   }
  // }
  if (type == "NumericOnly") {
    if (!GetUtils.isNumericOnly(val)) {
      return "Le mot de passe est faible";
    }
  }
  if (type == "DateTime") {
    if (!GetUtils.isDateTime(val)) {
      return "La date n'est pas valide";
    }
  }
  if (type == "password") {
    if (!GetUtils.isLengthBetween(val, 6, 20)) {
      return "Le mot de passe est faible";
    }
  }
  if (val.isEmpty) {
    return "Le champ est vide";
  }
}
