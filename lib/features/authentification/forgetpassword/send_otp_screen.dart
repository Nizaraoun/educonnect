import 'package:educonnect/widgets/CustomElevatedButton.dart';
import 'package:educonnect/widgets/button/custom_inkwell.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import '../../../core/themes/color_mangers.dart';
import '../../../core/utils/input_validation.dart';
import '../../../widgets/customtext.dart';
import '../auth_controller.dart';

class SendOtp extends StatelessWidget {
  final String from;
  const SendOtp({super.key, required this.from});

  @override
  Widget build(BuildContext context) {
    AthControllerImp controller = Get.put(AthControllerImp());

    List<FocusNode> focusNodes = List.generate(
      5,
      (index) => FocusNode(),
    );

    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        title: customText(
            text: 'إرسال رمز التحقق',
            textStyle: TextStyle(
                color: ColorManager.white,
                fontSize: 20,
                fontWeight: FontWeight.w400)
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        clipBehavior: Clip.antiAliasWithSaveLayer,
        padding: EdgeInsets.only(
            top: Get.height * 0.05,
            left: Get.width * 0.05,
            right: Get.width * 0.05),
        child: Column(
          textDirection: TextDirection.rtl,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset('assets/images/sms.png',
                width: Get.width * 0.4, height: Get.height * 0.3),
            customText(
              text: 'les 4 chiffres envoyés sur votre mail',
              textStyle: TextStyle(
                  color: ColorManager.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w600),
            ),
            Gap(Get.height * 0.02),
            Form(
              key: controller.formstateotp,
              child: Row(
                children: [
                  for (int i = 0; i < 5; i++)
                    OtpField(
                      validator: (p0) {
                        return validInput(p0!, "isNumericOnly");
                      },
                      onChanged: (p0) {
                        controller.inputotp[i] = p0;
                      },
                      focusNode: focusNodes[i],
                      nextFocusNode: i < 4 ? focusNodes[i + 1] : FocusNode(),
                    ),
                ],
              ),
            ),
            Gap(Get.height * 0.06),
             customElevatedButton(
                  text: "confirmer", 
                  onPressed: () {
                    // controller.newPasswordFN();
                  },
                  color: ColorManager.primaryColor,
                  width: Get.width * 0.5,
                  height: Get.height * 0.07,
                  textStyle: const TextStyle(
                    color: ColorManager.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                  ),
                  borderRadius: 20,
                ),
            Gap(Get.height * 0.03),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomInkWell(
                  ontap: () {},
                  widget: customText(
                    text: 'renvoyer le code',
                    textStyle: TextStyle(
                        color: ColorManager.black,
                        fontSize: 20,
                        fontWeight: FontWeight.w400),
                  ),
                ),
                customText(
                    text: ' vous n\'avez pas reçu le code?',
                    textStyle: TextStyle(
                        color: ColorManager.black,
                        fontSize: 20,
                        fontWeight: FontWeight.w400),
                  ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class OtpField extends StatelessWidget {
  final String? Function(String?) validator;
  final Function(String) onChanged;
  final FocusNode focusNode;
  final FocusNode nextFocusNode;

  const OtpField({
    super.key,
    required this.validator,
    required this.onChanged,
    required this.focusNode,
    required this.nextFocusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Flexible(
      flex: 1,
      child: Container(
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(255, 190, 189, 189).withOpacity(0.2),
              spreadRadius: 1,
              blurStyle: BlurStyle.normal,
              blurRadius: 9,
              offset: const Offset(2, 1), // changes position of shadow
            ),
          ],
        ),
        child: TextFormField(
          textAlign: TextAlign.right,
          keyboardType: TextInputType.number,
          maxLength: 1,
          strutStyle: const StrutStyle(height: 1.5),
          keyboardAppearance: Brightness.dark,
          onTap: () {
            focusNode.requestFocus();
          },
          focusNode: focusNode,
          onChanged: (value) {
            onChanged(value);
            if (value.length == 1) {
              nextFocusNode.requestFocus();
            }
          },
          autofillHints: const [AutofillHints.telephoneNumber],
          cursorHeight: 40,
          cursorColor: ColorManager.primaryColor,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          validator: validator,
          decoration: InputDecoration(
            iconColor: ColorManager.black,
            fillColor: ColorManager.white,
            filled: true,
            constraints: const BoxConstraints(maxHeight: 75),
            counterStyle: const TextStyle(
              height: double.minPositive,
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.white, width: 2.0),
              borderRadius: BorderRadius.circular(20),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                  color: ColorManager.primaryColor, width: 2.0),
              borderRadius: BorderRadius.circular(10),
            ),
            hintText: "****",
            hintStyle: TextStyle(
              color: ColorManager.grey,
              fontFamily: 'Tajawal',
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}
