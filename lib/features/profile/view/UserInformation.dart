import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:educonnect/core/themes/color_mangers.dart';
import 'package:educonnect/widgets/CustomElevatedButton.dart';
import 'package:educonnect/widgets/customIcon.dart';
import 'package:educonnect/widgets/input/custom_input.dart';
import 'package:educonnect/widgets/text/custom_text.dart';
import '../../../widgets/input/custom_drop_down.dart';
import '../controller/PersonalInformationController.dart';

class PersonalInformationView extends GetView<PersonalInformationController> {
  const PersonalInformationView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final PersonalInformationController controller =
        Get.put(PersonalInformationController());

    return Scaffold(
      backgroundColor: ColorManager.primaryColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            floating: true,
            pinned: true,
            backgroundColor: ColorManager.primaryColor,
            leading: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: CustomIconButton(
                icon: Icons.arrow_back,
                onPressed: () {
                  Get.back();
                },
                color: ColorManager.white,
                size: 30,
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: CustomText(
                txt: 'Informations Personnelles',
                color: ColorManager.white,
                fontweight: FontWeight.w500,
                size: 20,
                spacing: 0.0,
                fontfamily: 'Tajawal',
              ),
              background: Container(
                decoration: const BoxDecoration(
                  color: ColorManager.primaryColor,
                ),
                child: Center(
                  child: Image.asset(
                    'assets/images/document.png',
                    fit: BoxFit.contain,
                    height: 150,
                  ),
                ),
              ),
            ),
          ),
          // Rest of the code remains the same
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: ColorManager.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildPersonalSection(),
                    const SizedBox(height: 24),
                    _buildVehicleSection(),
                    const SizedBox(height: 24),
                    _buildProfessionalSection(),
                    const SizedBox(height: 24),
                    _buildFinancialSection(),
                    const SizedBox(height: 32),
                    // Replace your existing button with this updated version
                    Obx(() => ElevatedButton(
                          onPressed: controller.isLoading.value
                              ? null
                              : controller.submitForm,
                          child: CustomText(
                            txt: controller.isLoading.value
                                ? 'Chargement...'
                                : 'Soumettre',
                            color: ColorManager.white,
                            fontweight: FontWeight.w500,
                            size: 20,
                            spacing: 0.0,
                            fontfamily: 'Tajawal',
                          ),
                          style: ButtonStyle(
                            fixedSize: WidgetStateProperty.all(
                              Size(Get.width / 2, 55),
                            ),
                            backgroundColor: WidgetStateProperty.all(
                                ColorManager.primaryColor),
                            padding: WidgetStateProperty.all(
                              const EdgeInsets.symmetric(vertical: 16),
                            ),
                            shape: WidgetStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        )),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Rest of the widget methods (_buildPersonalSection(), etc.) remain the same
  Widget _buildPersonalSection() {
    return Card(
      elevation: 5,
      color: ColorManager.whitePrimary,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(
              txt: 'Information Personnelle',
              color: ColorManager.SoftBlack,
              fontweight: FontWeight.w500,
              size: 20,
              spacing: 0.0,
              fontfamily: 'Tajawal',
            ),
            const SizedBox(height: 16),
            CustomTextFormField(
              formOnChanged: (value) {
                controller.updatePersonalInfo(fullName: value);
              },
              height: 60,
              icon: Icon(Icons.person),
              inputType: TextInputType.text,
              texthint: 'Nom',
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Veuillez entrer votre nom';
                }
                return null;
              },
              color: ColorManager.white,
            ),
            Gap(20),
            Row(
              children: [
                Expanded(
                    child: CustomDropDown(
                        labes: 'genre',
                        items: ['Homme', 'Femme']
                            .map((e) =>
                                DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (value) {
                          controller.updatePersonalInfo(gender: value);
                        })),
                const SizedBox(width: 16),
                Expanded(
                    child: CustomDropDown(
                  labes: 'Statut marital',
                  items: ['Célibataire', 'Marié(e)', 'Divorcé(e)', 'Veuf/Veuve']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (value) =>
                      controller.updatePersonalInfo(maritalStatus: value),
                )),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Update your _buildVehicleSection() method to include the missing vehicle fields
  Widget _buildVehicleSection() {
    return Obx(() => Card(
          elevation: 5,
          color: ColorManager.whitePrimary,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  txt: 'Information Véhicule',
                  color: ColorManager.SoftBlack,
                  fontweight: FontWeight.w500,
                  size: 20,
                  spacing: 0.0,
                  fontfamily: 'Tajawal',
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Possédez-vous un véhicule?'),
                  value: controller.personalInfo.value.hasVehicle ?? false,
                  onChanged: (value) =>
                      controller.updatePersonalInfo(hasVehicle: value),
                ),
                if (controller.personalInfo.value.hasVehicle == true) ...[
                  const SizedBox(height: 16),
                  CustomTextFormField(
                    formOnChanged: (value) {
                      controller.updateVehicleInfo(brand: value);
                    },
                    height: 60,
                    icon: Icon(Icons.directions_car),
                    inputType: TextInputType.text,
                    texthint: 'Marque',
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Veuillez entrer la marque';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextFormField(
                    formOnChanged: (value) {
                      controller.updateVehicleInfo(model: value);
                    },
                    height: 60,
                    icon: Icon(Icons.directions_car_filled),
                    inputType: TextInputType.text,
                    texthint: 'Modèle',
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Veuillez entrer le modèle';
                      }
                      return null;
                    },
                  ),
                  // New acquisition year field
                  const SizedBox(height: 16),
                  CustomTextFormField(
                    formOnChanged: (value) {
                      controller.updateVehicleInfo(acquisitionYearStr: value);
                    },
                    height: 60,
                    icon: Icon(Icons.calendar_today),
                    inputType: TextInputType.number,
                    texthint: 'Année d\'acquisition',
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Veuillez entrer l\'année d\'acquisition';
                      }
                      return null;
                    },
                  ),
                  // New estimated value field
                  const SizedBox(height: 16),
                  CustomTextFormField(
                    formOnChanged: (value) {
                      controller.updateVehicleInfo(estimatedValueStr: value);
                    },
                    height: 60,
                    icon: Icon(Icons.monetization_on),
                    inputType: TextInputType.number,
                    texthint: 'Valeur estimée (TND)',
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Veuillez entrer la valeur estimée';
                      }
                      return null;
                    },
                  ),
                  // New isFinanced field
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Est-ce financé?'),
                    value: controller.personalInfo.value.vehicle?.isFinanced ??
                        false,
                    onChanged: (value) =>
                        controller.updateVehicleInfo(isFinanced: value),
                  ),
                ],
              ],
            ),
          ),
        ));
  }

// Update your _buildProfessionalSection() method to include the missing professional fields
  Widget _buildProfessionalSection() {
    return Card(
      elevation: 5,
      color: ColorManager.whitePrimary,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(
              txt: 'Informations Professionnelles',
              color: ColorManager.SoftBlack,
              fontweight: FontWeight.w500,
              size: 20,
              spacing: 0.0,
              fontfamily: 'Tajawal',
            ),
            const SizedBox(height: 16),
            CustomTextFormField(
              formOnChanged: (value) {
                controller.updateProfessionalInfo(profession: value);
              },
              height: 60,
              icon: Icon(Icons.work),
              inputType: TextInputType.text,
              texthint: 'Profession',
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Veuillez entrer votre profession';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            CustomTextFormField(
              formOnChanged: (value) {
                controller.updateProfessionalInfo(sector: value);
              },
              height: 60,
              icon: Icon(Icons.category),
              inputType: TextInputType.text,
              texthint: 'Secteur d\'activité',
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Veuillez entrer votre secteur d\'activité';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            CustomTextFormField(
              formOnChanged: (value) {
                controller.updateProfessionalInfo(employer: value);
              },
              height: 60,
              icon: Icon(Icons.business),
              inputType: TextInputType.text,
              texthint: 'Employeur',
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Veuillez entrer le nom de votre employeur';
                }
                return null;
              },
            ),
            // New contract type field
            const SizedBox(height: 16),
            CustomDropDown(
              labes: 'Type de contrat',
              items: ['CDI', 'CDD', 'Intérim', 'Stage', 'Freelance', 'Autre']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (value) =>
                  controller.updateProfessionalInfo(contractType: value),
            ),
            // New years of service field
            const SizedBox(height: 16),
            CustomTextFormField(
              formOnChanged: (value) {
                controller.updateProfessionalInfo(
                    yearsOfService: int.tryParse(value) ?? 0);
              },
              height: 60,
              icon: Icon(Icons.timer),
              inputType: TextInputType.number,
              texthint: 'Années d\'ancienneté',
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Veuillez entrer vos années d\'ancienneté';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

// Update your _buildFinancialSection() method to include the missing financial field
  Widget _buildFinancialSection() {
    return Card(
      elevation: 5,
      color: ColorManager.whitePrimary,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(
              txt: 'Informations Financières',
              color: ColorManager.SoftBlack,
              fontweight: FontWeight.w500,
              size: 20,
              spacing: 0.0,
              fontfamily: 'Tajawal',
            ),
            const SizedBox(height: 16),
            CustomTextFormField(
              formOnChanged: (value) {
                if (value.isNotEmpty) {
                  controller.updateFinancialInfo(monthlyNetSalaryStr: value);
                }
              },
              height: 60,
              icon: Icon(Icons.monetization_on),
              inputType: TextInputType.number,
              texthint: 'Salaire mensuel net (TND)',
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Veuillez entrer votre salaire mensuel';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            CustomTextFormField(
              formOnChanged: (value) {
                if (value.isNotEmpty) {
                  controller.updateFinancialInfo(additionalIncomeStr: value);
                }
              },
              height: 60,
              icon: Icon(Icons.add_card),
              inputType: TextInputType.number,
              texthint: 'Revenus additionnels (TND)',
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Veuillez entrer vos revenus additionnels';
                }
                return null;
              },
            ),
            // New fixed charges field
            const SizedBox(height: 16),
            CustomTextFormField(
              formOnChanged: (value) {
                if (value.isNotEmpty) {
                  controller.updateFinancialInfo(fixedChargesStr: value);
                }
              },
              height: 60,
              icon: Icon(Icons.account_balance),
              inputType: TextInputType.number,
              texthint: 'Charges fixes mensuelles (TND)',
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Veuillez entrer vos charges fixes mensuelles';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }
}
