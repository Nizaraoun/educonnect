import 'package:educonnect/core/themes/color_mangers.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import '../../../feature-teacher/home/widget/teacher_drawer.dart';
import '../../../widgets/customText.dart';

class ExamPlanningScreen extends StatefulWidget {
  const ExamPlanningScreen({Key? key}) : super(key: key);

  @override
  State<ExamPlanningScreen> createState() => _ExamPlanningScreenState();
}

class _ExamPlanningScreenState extends State<ExamPlanningScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  bool _isLoading = true;
  String? _teacherId;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // List to store exams
  List<Map<String, dynamic>> _exams = [];

  // Mock data for courses

// Filtered exams list
  List<Map<String, dynamic>> _filteredExams = [];
  String _selectedFilter = 'upcoming';
  @override
  void initState() {
    super.initState();
    _getUserId();
  }

  Future<void> _getUserId() async {
    // Get shared preferences
    final User? currentUser = _auth.currentUser;

    setState(() {
      _teacherId = currentUser?.uid;
    });

    if (_teacherId != null) {
      await _fetchExams();
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchExams() async {
    print('Fetching exams for teacher ID: $_teacherId');
    try {
      final querySnapshot = await _firestore
          .collection('exams')
          .where('teacherId', isEqualTo: _teacherId)
          .get();

      List<Map<String, dynamic>> fetchedExams = [];

      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> exam = Map<String, dynamic>.from(doc.data());
        exam['id'] = doc.id;

        // Convert Firestore Timestamp to DateTime
        if (exam['date'] is Timestamp) {
          exam['date'] = (exam['date'] as Timestamp).toDate();
        }

        // Ensure location field is properly mapped (handle 'salle' field)
        if (exam.containsKey('salle') && !exam.containsKey('location')) {
          exam['location'] = exam['salle'];
        } else if (!exam.containsKey('location') &&
            !exam.containsKey('salle')) {
          exam['location'] = 'Non spécifiée';
          exam['salle'] = 'Non spécifiée';
        }

        // Handle missing fields with defaults
        if (!exam.containsKey('status')) {
          // Set status based on date
          DateTime examDate = exam['date'] as DateTime;
          exam['status'] =
              examDate.isAfter(DateTime.now()) ? 'upcoming' : 'completed';
        }

        // Ensure title field exists
        if (!exam.containsKey('title')) {
          exam['title'] = 'Examen sans titre';
        }

        // Ensure course field exists
        if (!exam.containsKey('course')) {
          exam['course'] = exam['courseName'] ?? 'Cours';
        }

        // Ensure courseCode field exists
        if (!exam.containsKey('courseCode') && exam.containsKey('course')) {
          String courseStr = exam['course'].toString();
          int maxLength = min(courseStr.length, 4);
          exam['courseCode'] = courseStr.substring(0, maxLength).toUpperCase();
        }

        // Ensure examType field exists
        if (!exam.containsKey('examType')) {
          exam['examType'] = 'Examen';
        }

        // Ensure time fields exist
        if (!exam.containsKey('startTime')) {
          exam['startTime'] = '09:00';
        }

        if (!exam.containsKey('endTime')) {
          // If duration exists, calculate endTime based on startTime and duration
          if (exam.containsKey('duration') && exam['duration'] is String) {
            try {
              String durationStr = exam['duration'];
              RegExp regex = RegExp(r'(\d+)');
              Match? match = regex.firstMatch(durationStr);
              if (match != null) {
                int minutes = int.parse(match.group(1)!);
                // Parse startTime
                List<String> startTimeParts =
                    exam['startTime'].toString().split(':');
                int startHour = int.parse(startTimeParts[0]);
                int startMinute = int.parse(startTimeParts[1]);

                // Calculate endTime
                DateTime startDateTime =
                    DateTime(2023, 1, 1, startHour, startMinute);
                DateTime endDateTime =
                    startDateTime.add(Duration(minutes: minutes));

                exam['endTime'] =
                    '${endDateTime.hour.toString().padLeft(2, '0')}:${endDateTime.minute.toString().padLeft(2, '0')}';
              } else {
                exam['endTime'] = '10:30';
              }
            } catch (e) {
              print('Error calculating endTime: $e');
              exam['endTime'] = '10:30';
            }
          } else {
            exam['endTime'] = '10:30';
          }
        }

        if (!exam.containsKey('duration')) {
          // Calculate duration if startTime and endTime exist
          if (exam.containsKey('startTime') && exam.containsKey('endTime')) {
            try {
              List<String> startTimeParts =
                  exam['startTime'].toString().split(':');
              List<String> endTimeParts = exam['endTime'].toString().split(':');

              int startHour = int.parse(startTimeParts[0]);
              int startMinute = int.parse(startTimeParts[1]);
              int endHour = int.parse(endTimeParts[0]);
              int endMinute = int.parse(endTimeParts[1]);

              DateTime startDateTime =
                  DateTime(2023, 1, 1, startHour, startMinute);
              DateTime endDateTime = DateTime(2023, 1, 1, endHour, endMinute);

              if (endDateTime.isBefore(startDateTime)) {
                endDateTime = endDateTime.add(Duration(days: 1));
              }

              int durationMinutes =
                  endDateTime.difference(startDateTime).inMinutes;
              exam['duration'] = '$durationMinutes min';
            } catch (e) {
              print('Error calculating duration: $e');
              exam['duration'] = '90 min';
            }
          } else {
            exam['duration'] = '90 min';
          }
        }

        // Set default stats for completed exams
        if (exam['status'] == 'completed') {
          if (!exam.containsKey('totalPoints')) {
            exam['totalPoints'] = 20;
          }
          if (!exam.containsKey('averageScore')) {
            exam['averageScore'] = 12;
          }
          if (!exam.containsKey('highestScore')) {
            exam['highestScore'] = 18;
          }
          if (!exam.containsKey('lowestScore')) {
            exam['lowestScore'] = 7;
          }
          if (!exam.containsKey('passRate')) {
            exam['passRate'] = 75;
          }
        }

        fetchedExams.add(exam);
      }

      setState(() {
        _exams = fetchedExams;
        _isLoading = false;
      });

      _filterExams();
    } catch (e) {
      print('Error fetching exams: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterExams() {
    if (_selectedFilter == 'all') {
      _filteredExams = List.from(_exams);
    } else {
      _filteredExams =
          _exams.where((exam) => exam['status'] == _selectedFilter).toList();
    }

    // Sort by date
    _filteredExams.sort((a, b) {
      DateTime dateA = a['date'] as DateTime;
      DateTime dateB = b['date'] as DateTime;
      return dateA.compareTo(dateB);
    });

    setState(() {});
  }

  List<Map<String, dynamic>> _getExamsForDay(DateTime day) {
    return _exams.where((exam) {
      DateTime examDate = exam['date'] as DateTime;
      return isSameDay(examDate, day);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.lightGrey3,
      drawer: teacherCustomDrawer(context: context),
      appBar: AppBar(
        actionsIconTheme: IconThemeData(
          color: ColorManager.white,
        ),
        iconTheme: IconThemeData(color: ColorManager.white, size: 30),
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
              text: 'Planification des Examens',
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
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: ColorManager.primaryColor,
              ),
            )
          : Column(
              children: [
                // Calendar Section
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TableCalendar(
                    firstDay: DateTime.utc(2023, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: _focusedDay,
                    calendarFormat: _calendarFormat,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                    },
                    onFormatChanged: (format) {
                      setState(() {
                        _calendarFormat = format;
                      });
                    },
                    onPageChanged: (focusedDay) {
                      _focusedDay = focusedDay;
                    },
                    eventLoader: _getExamsForDay,
                    calendarStyle: CalendarStyle(
                      outsideDaysVisible: false,
                      markersMaxCount: 3,
                      markerDecoration: const BoxDecoration(
                        color: ColorManager.primaryColor,
                        shape: BoxShape.circle,
                      ),
                      todayDecoration: BoxDecoration(
                        color: ColorManager.primaryColor.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      selectedDecoration: const BoxDecoration(
                        color: ColorManager.primaryColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    headerStyle: HeaderStyle(
                      formatButtonVisible: true,
                      titleCentered: true,
                      formatButtonDecoration: BoxDecoration(
                        color: ColorManager.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      formatButtonTextStyle: TextStyle(
                        color: ColorManager.primaryColor,
                      ),
                      titleTextStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                // Filter Buttons
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildFilterButton('À venir', 'upcoming'),
                      _buildFilterButton('Terminé', 'completed'),
                      _buildFilterButton('Tous', 'all'),
                    ],
                  ),
                ),

                // Title for the exams section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      customText(
                        text:
                            'Examens ${_selectedFilter == 'upcoming' ? 'à venir' : (_selectedFilter == 'completed' ? 'terminés' : '')}',
                        textStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: ColorManager.SoftBlack,
                        ),
                      ),
                      const Spacer(),
                      if (_getExamsForDay(_selectedDay).isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color:
                                ColorManager.blueprimaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: customText(
                            text:
                                '${DateFormat('dd MMMM', 'fr_FR').format(_selectedDay)} - ${_getExamsForDay(_selectedDay).length} examen(s)',
                            textStyle: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: ColorManager.blueprimaryColor,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Exams List
                Expanded(
                  child: _filteredExams.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                FeatherIcons.calendar,
                                size: 48,
                                color: ColorManager.grey,
                              ),
                              const Gap(12),
                              customText(
                                text:
                                    'Aucun examen ${_selectedFilter == 'upcoming' ? 'à venir' : (_selectedFilter == 'completed' ? 'terminé' : '')}',
                                textStyle: TextStyle(
                                  fontSize: 14,
                                  color: ColorManager.grey,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredExams.length,
                          itemBuilder: (context, index) {
                            final exam = _filteredExams[index];
                            final examDate = exam['date'] as DateTime;
                            final isToday = isSameDay(examDate, DateTime.now());
                            final isPastDate =
                                examDate.isBefore(DateTime.now());
                            final isSelectedDay =
                                isSameDay(examDate, _selectedDay);
                            final isWithin3Days =
                                examDate.difference(DateTime.now()).inDays <=
                                        3 &&
                                    examDate.isAfter(DateTime.now());

                            // Determine exam color
                            Color examColor = _getExamColor(exam);

                            return GestureDetector(
                              onTap: () {
                                _showExamDetails(exam);
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: isSelectedDay
                                      ? Border.all(
                                          color: ColorManager.primaryColor,
                                          width: 2)
                                      : null,
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
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: examColor.withOpacity(0.1),
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(12),
                                          topRight: Radius.circular(12),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: examColor.withOpacity(0.2),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Icon(
                                              exam['examType'] == 'Quiz'
                                                  ? FeatherIcons.clipboard
                                                  : (exam['examType'] ==
                                                          'TP Noté'
                                                      ? FeatherIcons.code
                                                      : FeatherIcons.fileText),
                                              color: examColor,
                                              size: 20,
                                            ),
                                          ),
                                          const Gap(12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                customText(
                                                  text: exam['title'] ?? '',
                                                  textStyle: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    color:
                                                        ColorManager.SoftBlack,
                                                  ),
                                                ),
                                                customText(
                                                  text: exam['course'] ?? '',
                                                  textStyle: TextStyle(
                                                    fontSize: 12,
                                                    color: examColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: examColor.withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: customText(
                                              text:
                                                  exam['examType'] ?? 'Examen',
                                              textStyle: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: examColor,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                FeatherIcons.calendar,
                                                size: 14,
                                                color: ColorManager.grey,
                                              ),
                                              const Gap(8),
                                              customText(
                                                text: isToday
                                                    ? 'Aujourd\'hui'
                                                    : DateFormat(
                                                            'EEEE d MMMM yyyy',
                                                            'fr_FR')
                                                        .format(examDate),
                                                textStyle: TextStyle(
                                                  fontSize: 12,
                                                  color: isWithin3Days
                                                      ? ColorManager.amber
                                                      : ColorManager.grey,
                                                  fontWeight: isWithin3Days
                                                      ? FontWeight.w600
                                                      : FontWeight.normal,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const Gap(8),
                                          Row(
                                            children: [
                                              Icon(
                                                FeatherIcons.clock,
                                                size: 14,
                                                color: ColorManager.grey,
                                              ),
                                              const Gap(8),
                                              customText(
                                                text:
                                                    '${exam['startTime']} - ${exam['endTime']} (${exam['duration']})',
                                                textStyle: TextStyle(
                                                  fontSize: 12,
                                                  color: ColorManager.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const Gap(8),
                                          Row(
                                            children: [
                                              Icon(
                                                FeatherIcons.mapPin,
                                                size: 14,
                                                color: ColorManager.grey,
                                              ),
                                              const Gap(8),
                                              customText(
                                                text: exam['salle'] ??
                                                    exam['location'] ??
                                                    '',
                                                textStyle: TextStyle(
                                                  fontSize: 12,
                                                  color: ColorManager.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                          if (exam['status'] == 'completed')
                                            Column(
                                              children: [
                                                const Gap(8),
                                                const Divider(),
                                                const Gap(8),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceAround,
                                                  children: [
                                                    _buildStatColumn(
                                                      '${exam['averageScore']}/${exam['totalPoints']}',
                                                      'Moy.',
                                                      ColorManager.primaryColor,
                                                    ),
                                                    _buildStatColumn(
                                                      '${exam['highestScore']}/${exam['totalPoints']}',
                                                      'Max',
                                                      ColorManager.green,
                                                    ),
                                                    _buildStatColumn(
                                                      '${exam['lowestScore']}/${exam['totalPoints']}',
                                                      'Min',
                                                      ColorManager.amber,
                                                    ),
                                                    _buildStatColumn(
                                                      '${exam['passRate']}%',
                                                      'Réussite',
                                                      ColorManager
                                                          .blueprimaryColor,
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      decoration: const BoxDecoration(
                                        border: Border(
                                          top: BorderSide(
                                            color: ColorManager.lightGrey,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          if (isPastDate &&
                                              exam['status'] == 'upcoming')
                                            OutlinedButton.icon(
                                              onPressed: () {
                                                // Mark as completed
                                              },
                                              icon: Icon(
                                                FeatherIcons.checkCircle,
                                                size: 16,
                                              ),
                                              label: const Text('Terminer'),
                                              style: OutlinedButton.styleFrom(
                                                foregroundColor:
                                                    ColorManager.green,
                                                side: const BorderSide(
                                                    color: ColorManager.green),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 0,
                                                ),
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
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildFilterButton(String text, String value) {
    final isSelected = _selectedFilter == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = value;
          _filterExams();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? ColorManager.primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: customText(
          text: text,
          textStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : ColorManager.SoftBlack,
          ),
        ),
      ),
    );
  }

  Widget _buildStatColumn(String value, String label, Color color) {
    return Column(
      children: [
        customText(
          text: value,
          textStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        customText(
          text: label,
          textStyle: TextStyle(
            fontSize: 12,
            color: ColorManager.grey,
          ),
        ),
      ],
    );
  }

  void _showExamDetails(Map<String, dynamic> exam) {
    Color examColor = _getExamColor(exam);

    Get.dialog(
      Dialog(
        insetPadding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(
            maxHeight: Get.height * 0.7,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: examColor.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: examColor.withOpacity(0.2),
                        shape: BoxShape.circle,
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
                            text: exam['title'] ?? '',
                            textStyle: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: ColorManager.SoftBlack,
                            ),
                          ),
                          Row(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 4),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: examColor.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: customText(
                                  text: exam['courseCode'] ?? '',
                                  textStyle: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: examColor,
                                  ),
                                ),
                              ),
                              const Gap(8),
                              Container(
                                margin: const EdgeInsets.only(top: 4),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: examColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: customText(
                                  text: exam['examType'] ?? 'Examen',
                                  textStyle: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: examColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Get.back();
                      },
                      icon: Icon(
                        FeatherIcons.x,
                        color: ColorManager.SoftBlack,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Date and Time
                      Row(
                        children: [
                          Icon(
                            FeatherIcons.calendar,
                            size: 16,
                            color: ColorManager.grey,
                          ),
                          const Gap(8),
                          customText(
                            text: DateFormat('EEEE d MMMM yyyy', 'fr_FR')
                                .format(exam['date']),
                            textStyle: TextStyle(
                              fontSize: 14,
                              color: ColorManager.SoftBlack,
                            ),
                          ),
                        ],
                      ),
                      const Gap(12),
                      Row(
                        children: [
                          Icon(
                            FeatherIcons.clock,
                            size: 16,
                            color: ColorManager.grey,
                          ),
                          const Gap(8),
                          customText(
                            text:
                                '${exam['startTime']} - ${exam['endTime']} (${exam['duration']})',
                            textStyle: TextStyle(
                              fontSize: 14,
                              color: ColorManager.SoftBlack,
                            ),
                          ),
                        ],
                      ),
                      const Gap(12),
                      Row(
                        children: [
                          Icon(
                            FeatherIcons.mapPin,
                            size: 16,
                            color: ColorManager.grey,
                          ),
                          const Gap(8),
                          customText(
                            text: exam['salle'] ?? exam['location'] ?? '',
                            textStyle: TextStyle(
                              fontSize: 14,
                              color: ColorManager.SoftBlack,
                            ),
                          ),
                        ],
                      ),
                      const Gap(12),
                      Row(
                        children: [
                          Icon(
                            FeatherIcons.star,
                            size: 16,
                            color: ColorManager.grey,
                          ),
                          const Gap(8),
                          customText(
                            text: 'Points totaux: ${exam['totalPoints']}',
                            textStyle: TextStyle(
                              fontSize: 14,
                              color: ColorManager.SoftBlack,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: ColorManager.lightGrey,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailStatCard(String label, String value, Color color) {
    return Container(
      width: Get.width * 0.35,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          customText(
            text: label,
            textStyle: TextStyle(
              fontSize: 12,
              color: color.withOpacity(0.8),
            ),
          ),
          const Gap(4),
          customText(
            text: value,
            textStyle: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
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
}
