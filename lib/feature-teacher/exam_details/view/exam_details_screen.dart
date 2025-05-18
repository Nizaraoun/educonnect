import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:educonnect/core/themes/color_mangers.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../widgets/customText.dart';

class ExamDetailsScreen extends StatefulWidget {
  const ExamDetailsScreen({Key? key}) : super(key: key);

  @override
  State<ExamDetailsScreen> createState() => _ExamDetailsScreenState();
}

class _ExamDetailsScreenState extends State<ExamDetailsScreen> {
  late Map<String, dynamic> exam;
  bool _isLoading = true;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadExamDetails();
  }

  Future<void> _loadExamDetails() async {
    try {
      // Get exam data from arguments
      final dynamic args = Get.arguments;

      if (args is Map<String, dynamic>) {
        // If we already have the full exam data
        exam = args;
        setState(() {
          _isLoading = false;
        });
      } else if (args is String) {
        // If we only have the exam ID, fetch the data
        final String examId = args;
        final DocumentSnapshot examDoc =
            await _firestore.collection('exams').doc(examId).get();

        if (examDoc.exists) {
          exam =
              Map<String, dynamic>.from(examDoc.data() as Map<String, dynamic>);
          exam['id'] = examDoc.id;

          // Convert Timestamp to DateTime
          if (exam['date'] is Timestamp) {
            exam['date'] = (exam['date'] as Timestamp).toDate();
          }

          // Ensure location field exists
          if (exam.containsKey('salle') && !exam.containsKey('location')) {
            exam['location'] = exam['salle'];
          } else if (!exam.containsKey('location') &&
              !exam.containsKey('salle')) {
            exam['location'] = 'Non spécifiée';
          }

          setState(() {
            _isLoading = false;
          });
        } else {
          Get.snackbar(
            'Erreur',
            'Examen non trouvé',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: ColorManager.red.withOpacity(0.1),
            colorText: ColorManager.red,
          );
          Get.back();
        }
      } else {
        Get.snackbar(
          'Erreur',
          'Données invalides',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: ColorManager.red.withOpacity(0.1),
          colorText: ColorManager.red,
        );
        Get.back();
      }
    } catch (e) {
      print('Error loading exam details: $e');
      Get.snackbar(
        'Erreur',
        'Une erreur est survenue lors du chargement des détails de l\'examen',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: ColorManager.red.withOpacity(0.1),
        colorText: ColorManager.red,
      );
      Get.back();
    }
  }

  Color _getExamColor(Map<String, dynamic> exam) {
    try {
      if (exam['color'] != null) {
        if (exam['color'] is String &&
            exam['color'].toString().startsWith('#')) {
          // Handle hex color strings
          String colorStr = exam['color'].toString().substring(1);
          if (colorStr.length == 6) {
            return Color(int.parse('0xFF$colorStr'));
          }
        } else if (exam['color'] is int) {
          // Handle color as integer
          return Color(exam['color']);
        } else if (exam['examType'] != null) {
          // Assign colors based on exam type
          switch (exam['examType']) {
            case 'Quiz':
              return ColorManager.amber;
            case 'TP Noté':
              return ColorManager.green;
            case 'Partiel':
              return ColorManager.blueprimaryColor;
            case 'Final':
              return ColorManager.red;
            default:
              return ColorManager.primaryColor;
          }
        }
      }

      // Default color if none is specified or if parsing fails
      return ColorManager.primaryColor;
    } catch (e) {
      print('Error parsing color: $e');
      return ColorManager.primaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Détails de l\'examen'),
          backgroundColor: ColorManager.primaryColor,
          foregroundColor: ColorManager.white,
        ),
        body: Center(
          child: CircularProgressIndicator(
            color: ColorManager.primaryColor,
          ),
        ),
      );
    }

    final examDate = exam['date'] as DateTime;
    final isToday = examDate.day == DateTime.now().day &&
        examDate.month == DateTime.now().month &&
        examDate.year == DateTime.now().year;
    final isPastDate = examDate.isBefore(DateTime.now());
    final isWithin3Days = examDate.difference(DateTime.now()).inDays <= 3 &&
        examDate.isAfter(DateTime.now());

    // Get exam color
    final Color examColor = _getExamColor(exam);

    return Scaffold(
      backgroundColor: ColorManager.lightGrey3,
      appBar: AppBar(
        title: Text('Détails de l\'examen'),
        backgroundColor: ColorManager.primaryColor,
        foregroundColor: ColorManager.white,
        actions: [
          IconButton(
            icon: Icon(FeatherIcons.edit),
            onPressed: () {
              // Navigate to edit exam screen
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Exam Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: examColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: examColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          exam['examType'] == 'Quiz'
                              ? FeatherIcons.clipboard
                              : (exam['examType'] == 'TP Noté'
                                  ? FeatherIcons.code
                                  : FeatherIcons.fileText),
                          color: examColor,
                          size: 24,
                        ),
                      ),
                      const Gap(16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            customText(
                              text: exam['title'] ?? 'Examen sans titre',
                              textStyle: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: ColorManager.SoftBlack,
                              ),
                            ),
                            customText(
                              text: exam['course'] ?? 'Cours non spécifié',
                              textStyle: TextStyle(
                                fontSize: 16,
                                color: examColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Gap(20),
                  // Status badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isWithin3Days
                          ? ColorManager.amber.withOpacity(0.1)
                          : (isPastDate
                              ? ColorManager.green.withOpacity(0.1)
                              : ColorManager.blueprimaryColor.withOpacity(0.1)),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: customText(
                      text: isWithin3Days
                          ? 'Bientôt'
                          : (isPastDate ? 'Terminé' : 'Planifié'),
                      textStyle: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isWithin3Days
                            ? ColorManager.amber
                            : (isPastDate
                                ? ColorManager.green
                                : ColorManager.blueprimaryColor),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Gap(16),

            // Exam Details
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  customText(
                    text: 'Détails de l\'examen',
                    textStyle: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: ColorManager.SoftBlack,
                    ),
                  ),
                  const Gap(16),
                  _buildDetailRow(
                    icon: FeatherIcons.calendar,
                    label: 'Date',
                    value: isToday
                        ? 'Aujourd\'hui'
                        : DateFormat('EEEE d MMMM yyyy', 'fr_FR')
                            .format(examDate),
                    color: isWithin3Days ? ColorManager.amber : null,
                  ),
                  const Gap(12),
                  _buildDetailRow(
                    icon: FeatherIcons.clock,
                    label: 'Horaire',
                    value:
                        '${exam['startTime'] ?? '09:00'} - ${exam['endTime'] ?? '10:30'} (${exam['duration'] ?? '90 min'})',
                  ),
                  const Gap(12),
                  _buildDetailRow(
                    icon: FeatherIcons.mapPin,
                    label: 'Lieu',
                    value: exam['salle'] ?? exam['location'] ?? 'Non spécifié',
                  ),
                  const Gap(12),
                  _buildDetailRow(
                    icon: FeatherIcons.tag,
                    label: 'Type',
                    value: exam['examType'] ?? 'Examen',
                  ),
                  if (exam['totalPoints'] != null) ...[
                    const Gap(12),
                    _buildDetailRow(
                      icon: FeatherIcons.star,
                      label: 'Points',
                      value: '${exam['totalPoints']} points',
                    ),
                  ],
                ],
              ),
            ),

            const Gap(16),

            // Additional Information
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  customText(
                    text: 'Informations supplémentaires',
                    textStyle: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: ColorManager.SoftBlack,
                    ),
                  ),
                  const Gap(16),
                  if (exam['description'] != null)
                    customText(
                      text: exam['description'],
                      textStyle: TextStyle(
                        fontSize: 14,
                        color: ColorManager.grey,
                      ),
                    )
                  else
                    customText(
                      text: 'Aucune information supplémentaire disponible.',
                      textStyle: TextStyle(
                        fontSize: 14,
                        color: ColorManager.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                ],
              ),
            ),

            // Statistics for completed exams
            if (isPastDate && exam['status'] == 'completed') ...[
              const Gap(16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    customText(
                      text: 'Statistiques',
                      textStyle: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: ColorManager.SoftBlack,
                      ),
                    ),
                    const Gap(16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          label: 'Moyenne',
                          value:
                              '${exam['averageScore'] ?? 12}/${exam['totalPoints'] ?? 20}',
                          color: ColorManager.primaryColor,
                        ),
                        _buildStatItem(
                          label: 'Note Max',
                          value:
                              '${exam['highestScore'] ?? 18}/${exam['totalPoints'] ?? 20}',
                          color: ColorManager.green,
                        ),
                      ],
                    ),
                    const Gap(16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          label: 'Note Min',
                          value:
                              '${exam['lowestScore'] ?? 7}/${exam['totalPoints'] ?? 20}',
                          color: ColorManager.amber,
                        ),
                        _buildStatItem(
                          label: 'Taux réussite',
                          value: '${exam['passRate'] ?? 75}%',
                          color: ColorManager.blueprimaryColor,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],

            const Gap(20),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    Color? color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: color ?? ColorManager.grey,
        ),
        const Gap(12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              customText(
                text: label,
                textStyle: TextStyle(
                  fontSize: 12,
                  color: ColorManager.grey,
                ),
              ),
              customText(
                text: value,
                textStyle: TextStyle(
                  fontSize: 16,
                  color: color ?? ColorManager.SoftBlack,
                  fontWeight:
                      color != null ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      width: Get.width * 0.4,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          customText(
            text: value,
            textStyle: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const Gap(4),
          customText(
            text: label,
            textStyle: TextStyle(
              fontSize: 14,
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}
