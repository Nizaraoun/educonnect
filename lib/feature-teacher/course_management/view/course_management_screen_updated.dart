import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:gap/gap.dart';
import 'package:uuid/uuid.dart';
import '../../../core/themes/color_mangers.dart';
import '../../../widgets/custom_text.dart';
import '../model/course_model.dart';
import '../service/course_service.dart';
import '../widgets/courses_tab.dart';
import '../widgets/documents_tab.dart';
import '../widgets/statistics_tab.dart';
import '../widgets/add_options_dialog.dart';

class CourseManagementScreen extends StatefulWidget {
  const CourseManagementScreen({Key? key}) : super(key: key);

  @override
  State<CourseManagementScreen> createState() => _CourseManagementScreenState();
}

class _CourseManagementScreenState extends State<CourseManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;
  // Firebase service
  final CourseService _courseService = CourseService();

  // Stream subscription for courses
  StreamSubscription? _coursesSubscription;

  // List to store fetched courses
  List<Course> _courses = [];
  // List to store all documents across courses for the documents tab
  List<Map<String, dynamic>> _allDocuments = [];
  // Stats data for the Statistics tab
  Map<String, dynamic> _statsData = {
    'totalCourses': 0,
    'totalDocuments': 0,
    'totalStudents': 0,
    'courseActivity': [],
    'popularDocuments': []
  };

  // Loading states
  bool _isLoading = true;
  bool _isSubmitting = false;
  bool _isLoadingStats = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedIndex = _tabController.index;
      });

      // Load statistics data when navigating to Statistics tab
      if (_selectedIndex == 2) {
        _fetchStatistics();
      }
    });

    // Fetch courses from Firebase
    _fetchCourses();
    _fetchAllDocuments();
  }

  // Fetch courses from Firebase
  Future<void> _fetchCourses() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Cancel any existing subscription
      await _coursesSubscription?.cancel();

      // Listen to the courses stream
      _coursesSubscription = _courseService.getCourses().listen((courses) {
        if (mounted) {
          setState(() {
            _courses = courses;
            _isLoading = false;
          });
        }
      }, onError: (error) {
        print('Error fetching courses: $error');
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      });
    } catch (e) {
      print('Exception when fetching courses: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Fetch all documents across courses for the Documents tab
  Future<void> _fetchAllDocuments() async {
    try {
      final documents = await _courseService.getAllDocuments();
      if (mounted) {
        setState(() {
          _allDocuments = documents;
        });
      }
    } catch (e) {
      print('Error fetching documents: $e');
    }
  }

  // Fetch statistics data for the Statistics tab
  Future<void> _fetchStatistics() async {
    if (!mounted) return;

    setState(() {
      _isLoadingStats = true;
    });

    try {
      final stats = await _courseService.getStatistics();
      if (mounted) {
        setState(() {
          _statsData = stats;
          _isLoadingStats = false;
        });
      }
    } catch (e) {
      print('Error fetching statistics: $e');
      if (mounted) {
        setState(() {
          _isLoadingStats = false;
        });
      }
    }
  }

  @override
  void dispose() {
    // Cancel the courses subscription
    _coursesSubscription?.cancel();
    // Dispose the tab controller
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.lightGrey3,
      appBar: AppBar(
        actionsIconTheme: IconThemeData(
          color: ColorManager.white,
        ),
        iconTheme: IconThemeData(color: ColorManager.white, size: 30),
        backgroundColor: ColorManager.primaryColor,
        toolbarHeight: Get.height * 0.07,
        shadowColor: ColorManager.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
        title: customText(
          text: 'Gestion des Cours',
          textStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: ColorManager.white,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          indicatorSize: TabBarIndicatorSize.tab,
          tabs: [
            Tab(text: 'Mes Cours'),
            Tab(text: 'Documents'),
            Tab(text: 'Statistiques'),
          ],
          labelStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.normal,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: ColorManager.primaryColor,
        onPressed: _showAddDialog,
        child: Icon(
          FeatherIcons.plus,
          color: Colors.white,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Mes Cours Tab
          CoursesTab(
            courses: _courses,
            isLoading: _isLoading,
            onAddCourse: _showAddCourseDialog,
            onViewCourseDetails: _showCourseDetails,
            onEditCourse: _editCourseDialog,
          ), // Documents Tab
          DocumentsTab(
            documents: _allDocuments,
            onAddDocument: _showAddDocumentDialog,
            onEditDocument: (document) {},
            onDownloadDocument: _downloadDocument,
            onViewDocument: _viewDocument,
          ),

          // Statistiques Tab
          StatisticsTab(
            isLoading: _isLoadingStats,
            statsData: _statsData,
            getColorFromHex: _getCourseColor,
          ),
        ],
      ),
    );
  }

  // Helper method to get color from hex string
  Color _getCourseColor(String colorHex) {
    try {
      return Color(int.parse('0xFF${colorHex.substring(1)}'));
    } catch (e) {
      return ColorManager.primaryColor;
    }
  }

  // View document
  void _viewDocument(Map<String, dynamic> document) {
    if (document['downloadUrl'] != null) {
      print('Opening document: ${document['title']}');
      // Implement document viewing functionality
    } else {
      Get.snackbar(
        'Erreur',
        'Ce document n\'a pas d\'URL de téléchargement',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Download document
  void _downloadDocument(Map<String, dynamic> document) {
    if (document['downloadUrl'] != null) {
      print('Downloading document: ${document['title']}');
      // Implement download functionality

      Get.snackbar(
        'Téléchargement',
        'Le téléchargement de "${document['title']}" a commencé',
        backgroundColor: ColorManager.blueprimaryColor,
        colorText: Colors.white,
      );
    } else {
      Get.snackbar(
        'Erreur',
        'Ce document n\'a pas d\'URL de téléchargement',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Show dialog to add course or document
  void _showAddDialog() {
    Get.bottomSheet(
      AddOptionsDialog(
        onAddCourse: () {
          Get.back();
          _showAddCourseDialog();
        },
        onAddDocument: () {
          Get.back();
          _showAddDocumentDialog();
        },
      ),
      backgroundColor: Colors.transparent,
    );
  }

  // Show course details dialog
  void _showCourseDetails(Course course) {
    Color courseColor = _getCourseColor(course.color);

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          width: Get.width * 0.9,
          constraints: BoxConstraints(maxHeight: Get.height * 0.8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Course header
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: courseColor.withOpacity(0.1),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  border: Border(
                    left: BorderSide(
                      color: courseColor,
                      width: 4,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: courseColor.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        FeatherIcons.bookOpen,
                        color: courseColor,
                        size: 24,
                      ),
                    ),
                    Gap(16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: customText(
                                  text: course.title,
                                  textStyle: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: ColorManager.SoftBlack,
                                  ),
                                ),
                              ),
                              customText(
                                text: course.code,
                                textStyle: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: courseColor,
                                ),
                              ),
                            ],
                          ),
                          Gap(4),
                          customText(
                            text:
                                '${course.students} étudiants • ${course.schedule}',
                            textStyle: TextStyle(
                              fontSize: 12,
                              color: ColorManager.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Course content
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Description
                      customText(
                        text: 'Description',
                        textStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: ColorManager.SoftBlack,
                        ),
                      ),
                      Gap(8),
                      customText(
                        text: course.description,
                        textStyle: TextStyle(
                          fontSize: 14,
                          color: ColorManager.grey,
                        ),
                      ),
                      Gap(24),

                      // Modules and Documents
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          customText(
                            text: 'Modules',
                            textStyle: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: ColorManager.SoftBlack,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () {
                              _showAddModuleDialog(course);
                            },
                            icon: Icon(
                              FeatherIcons.plus,
                              size: 16,
                            ),
                            label: Text('Ajouter'),
                            style: TextButton.styleFrom(
                              foregroundColor: courseColor,
                            ),
                          ),
                        ],
                      ),
                      Gap(16),

                      // Modules list
                      for (var module in course.modules)
                        _buildModuleCard(module, courseColor),
                    ],
                  ),
                ),
              ),

              // Action buttons
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: ColorManager.lightGrey,
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {
                        Get.back();
                        _editCourseDialog(course);
                      },
                      icon: Icon(FeatherIcons.edit),
                      label: Text('Modifier le cours'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: courseColor,
                        side: BorderSide(color: courseColor),
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                    Gap(10),
                    ElevatedButton.icon(
                      onPressed: () {
                        Get.back();
                        _showAddDocumentDialogWithModule(course);
                      },
                      icon: Icon(FeatherIcons.plus),
                      label: Text('Ajouter un document'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: courseColor,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Show dialog to add a new course
  void _showAddCourseDialog() {
    final _formKey = GlobalKey<FormState>();
    final TextEditingController _titleController = TextEditingController();
    final TextEditingController _codeController = TextEditingController();
    final TextEditingController _descriptionController =
        TextEditingController();
    final TextEditingController _scheduleController = TextEditingController();
    final TextEditingController _studentsController = TextEditingController();
    String selectedColor = '#4CAF50'; // Default color (green)

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: StatefulBuilder(
          builder: (context, setState) {
            return Container(
              width: Get.width * 0.9,
              padding: EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ajouter un nouveau cours',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Gap(24),

                    // Title field
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Titre du cours',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer un titre';
                        }
                        return null;
                      },
                    ),
                    Gap(16),

                    // Code field
                    TextFormField(
                      controller: _codeController,
                      decoration: InputDecoration(
                        labelText: 'Code du cours',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer un code';
                        }
                        return null;
                      },
                    ),
                    Gap(16),

                    // Description field
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    Gap(16),

                    // Schedule field
                    TextFormField(
                      controller: _scheduleController,
                      decoration: InputDecoration(
                        labelText: 'Horaire (ex: Lundi, Mercredi 10:00-12:00)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    Gap(16),

                    // Students field
                    TextFormField(
                      controller: _studentsController,
                      decoration: InputDecoration(
                        labelText: 'Nombre d\'étudiants',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    Gap(16),

                    // Color selector
                    Text(
                      'Couleur du cours',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    Gap(8),

                    // Color options
                    Wrap(
                      spacing: 8,
                      children: [
                        _buildColorSelector(
                            color: '#4CAF50', // Green
                            isSelected: selectedColor == '#4CAF50',
                            onTap: () {
                              setState(() {
                                selectedColor = '#4CAF50';
                              });
                            }),
                        _buildColorSelector(
                            color: '#2196F3', // Blue
                            isSelected: selectedColor == '#2196F3',
                            onTap: () {
                              setState(() {
                                selectedColor = '#2196F3';
                              });
                            }),
                        _buildColorSelector(
                            color: '#FFC107', // Amber
                            isSelected: selectedColor == '#FFC107',
                            onTap: () {
                              setState(() {
                                selectedColor = '#FFC107';
                              });
                            }),
                        _buildColorSelector(
                            color: '#9C27B0', // Purple
                            isSelected: selectedColor == '#9C27B0',
                            onTap: () {
                              setState(() {
                                selectedColor = '#9C27B0';
                              });
                            }),
                        _buildColorSelector(
                            color: '#F44336', // Red
                            isSelected: selectedColor == '#F44336',
                            onTap: () {
                              setState(() {
                                selectedColor = '#F44336';
                              });
                            }),
                      ],
                    ),
                    Gap(24),

                    // Submit button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            Get.back();
                          },
                          child: Text('Annuler'),
                        ),
                        Gap(8),
                        ElevatedButton(
                          onPressed: _isSubmitting
                              ? null
                              : () async {
                                  if (_formKey.currentState!.validate()) {
                                    setState(() {
                                      _isSubmitting = true;
                                    });

                                    try {
                                      // Create new course object
                                      final newCourse = Course(
                                        id: '',
                                        title: _titleController.text,
                                        code: _codeController.text,
                                        description:
                                            _descriptionController.text,
                                        schedule: _scheduleController.text,
                                        students: int.tryParse(
                                                _studentsController.text) ??
                                            0,
                                        color: selectedColor,
                                        modules: [],
                                      );

                                      // Add course to Firestore
                                      await _courseService.addCourse(newCourse);

                                      Get.back();
                                      Get.snackbar(
                                        'Succès',
                                        'Le cours a été créé avec succès',
                                        backgroundColor: ColorManager.green,
                                        colorText: Colors.white,
                                      );
                                    } catch (e) {
                                      print('Error adding course: $e');
                                      Get.snackbar(
                                        'Erreur',
                                        'Une erreur est survenue lors de la création du cours',
                                        backgroundColor: Colors.red,
                                        colorText: Colors.white,
                                      );
                                    } finally {
                                      setState(() {
                                        _isSubmitting = false;
                                      });
                                    }
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _getCourseColor(selectedColor),
                            foregroundColor: Colors.white,
                          ),
                          child: _isSubmitting
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text('Créer le cours'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Show dialog to edit a course
  void _editCourseDialog(Course course) {
    final _formKey = GlobalKey<FormState>();
    final TextEditingController _titleController =
        TextEditingController(text: course.title);
    final TextEditingController _codeController =
        TextEditingController(text: course.code);
    final TextEditingController _descriptionController =
        TextEditingController(text: course.description);
    final TextEditingController _scheduleController =
        TextEditingController(text: course.schedule);
    final TextEditingController _studentsController =
        TextEditingController(text: course.students.toString());
    String selectedColor = course.color;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: StatefulBuilder(
          builder: (context, setState) {
            return Container(
              width: Get.width * 0.9,
              padding: EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Modifier le cours',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Gap(24),

                      // Title field
                      TextFormField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          labelText: 'Titre du cours',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer un titre';
                          }
                          return null;
                        },
                      ),
                      Gap(16),

                      // Code field
                      TextFormField(
                        controller: _codeController,
                        decoration: InputDecoration(
                          labelText: 'Code du cours',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer un code';
                          }
                          return null;
                        },
                      ),
                      Gap(16),

                      // Description field
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      Gap(16), // Schedule field
                      TextFormField(
                        controller: _scheduleController,
                        decoration: InputDecoration(
                          labelText:
                              'Horaire (ex: Lundi, Mercredi 10:00-12:00)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      Gap(16),

                      // Students field
                      TextFormField(
                        controller: _studentsController,
                        decoration: InputDecoration(
                          labelText: 'Nombre d\'étudiants',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      Gap(16),

                      // Color selector
                      Text(
                        'Couleur du cours',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                      Gap(8),

                      // Color options
                      Wrap(
                        spacing: 8,
                        children: [
                          _buildColorSelector(
                              color: '#4CAF50', // Green
                              isSelected: selectedColor == '#4CAF50',
                              onTap: () {
                                setState(() {
                                  selectedColor = '#4CAF50';
                                });
                              }),
                          _buildColorSelector(
                              color: '#2196F3', // Blue
                              isSelected: selectedColor == '#2196F3',
                              onTap: () {
                                setState(() {
                                  selectedColor = '#2196F3';
                                });
                              }),
                          _buildColorSelector(
                              color: '#FFC107', // Amber
                              isSelected: selectedColor == '#FFC107',
                              onTap: () {
                                setState(() {
                                  selectedColor = '#FFC107';
                                });
                              }),
                          _buildColorSelector(
                              color: '#9C27B0', // Purple
                              isSelected: selectedColor == '#9C27B0',
                              onTap: () {
                                setState(() {
                                  selectedColor = '#9C27B0';
                                });
                              }),
                          _buildColorSelector(
                              color: '#F44336', // Red
                              isSelected: selectedColor == '#F44336',
                              onTap: () {
                                setState(() {
                                  selectedColor = '#F44336';
                                });
                              }),
                        ],
                      ),
                      Gap(24),

                      // Action buttons
                      Wrap(
                        children: [
                          TextButton.icon(
                            onPressed: _isSubmitting
                                ? null
                                : () async {
                                    Get.defaultDialog(
                                      title: 'Supprimer le cours',
                                      content: Text(
                                        'Êtes-vous sûr de vouloir supprimer ce cours et tous ses documents ? Cette action est irréversible.',
                                      ),
                                      textConfirm: 'Supprimer',
                                      textCancel: 'Annuler',
                                      confirmTextColor: Colors.white,
                                      cancelTextColor: Colors.black,
                                      buttonColor: Colors.red,
                                      onConfirm: () async {
                                        // Close the confirmation dialog
                                        Get.back();
                                        // Close the edit dialog
                                        Get.back();

                                        try {
                                          await _courseService
                                              .deleteCourse(course.id);
                                          Get.snackbar(
                                            'Succès',
                                            'Le cours a été supprimé',
                                            backgroundColor: Colors.green,
                                            colorText: Colors.white,
                                          );
                                        } catch (e) {
                                          print('Error deleting course: $e');
                                          Get.snackbar(
                                            'Erreur',
                                            'Une erreur est survenue lors de la suppression du cours',
                                            backgroundColor: Colors.red,
                                            colorText: Colors.white,
                                          );
                                        }
                                      },
                                    );
                                  },
                            icon: Icon(
                              FeatherIcons.trash2,
                              color: Colors.red,
                            ),
                            label: Text(
                              'Supprimer',
                              style: TextStyle(
                                color: Colors.red,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              TextButton(
                                onPressed: () {
                                  Get.back();
                                },
                                child: Text('Annuler'),
                              ),
                              Gap(8),
                              ElevatedButton(
                                onPressed: _isSubmitting
                                    ? null
                                    : () async {
                                        if (_formKey.currentState!.validate()) {
                                          setState(() {
                                            _isSubmitting = true;
                                          });

                                          try {
                                            // Update course
                                            final updatedCourse = Course(
                                              id: course.id,
                                              title: _titleController.text,
                                              code: _codeController.text,
                                              description:
                                                  _descriptionController.text,
                                              schedule:
                                                  _scheduleController.text,
                                              students: int.tryParse(
                                                      _studentsController
                                                          .text) ??
                                                  0,
                                              color: selectedColor,
                                              modules: course.modules,
                                            );

                                            await _courseService.updateCourse(
                                                course.id, updatedCourse);

                                            Get.back();
                                            Get.snackbar(
                                              'Succès',
                                              'Le cours a été mis à jour avec succès',
                                              backgroundColor:
                                                  ColorManager.green,
                                              colorText: Colors.white,
                                            );
                                          } catch (e) {
                                            print('Error updating course: $e');
                                            Get.snackbar(
                                              'Erreur',
                                              'Une erreur est survenue lors de la mise à jour du cours',
                                              backgroundColor: Colors.red,
                                              colorText: Colors.white,
                                            );
                                          } finally {
                                            setState(() {
                                              _isSubmitting = false;
                                            });
                                          }
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      _getCourseColor(selectedColor),
                                  foregroundColor: Colors.white,
                                ),
                                child: _isSubmitting
                                    ? SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text('Mettre à jour'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Show dialog to add a document
  void _showAddDocumentDialog() {
    final _formKey = GlobalKey<FormState>();
    final TextEditingController _titleController = TextEditingController();
    String? selectedCourseId;
    String? selectedModuleId;
    List<Module> modules = [];

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ajouter un nouveau document',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Gap(24),

                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Cours',
                        border: OutlineInputBorder(),
                      ),
                      value: selectedCourseId,
                      items: _courses.map((course) {
                        return DropdownMenuItem<String>(
                          value: course.id,
                          child: Text('${course.code} - ${course.title}'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedCourseId = value;
                          // Update modules list when course is selected
                          if (value != null) {
                            final selectedCourse =
                                _courses.firstWhere((c) => c.id == value);
                            modules = selectedCourse.modules;
                            selectedModuleId =
                                modules.isNotEmpty ? modules[0].id : null;
                          } else {
                            modules = [];
                            selectedModuleId = null;
                          }
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez sélectionner un cours';
                        }
                        return null;
                      },
                    ),
                    Gap(16),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Module',
                        border: OutlineInputBorder(),
                      ),
                      value: selectedModuleId,
                      items: modules.map((module) {
                        return DropdownMenuItem<String>(
                          value: module.id,
                          child: Text(module.title),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedModuleId = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez sélectionner un module';
                        }
                        return null;
                      },
                    ),
                    Gap(16),
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Titre du document',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer un titre';
                        }
                        return null;
                      },
                    ),
                    Gap(24),

                    // Action buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            Get.back();
                          },
                          child: Text('Annuler'),
                        ),
                        Gap(8),
                        ElevatedButton(
                          onPressed: _isSubmitting
                              ? null
                              : () async {
                                  if (_formKey.currentState!.validate()) {
                                    setState(() {
                                      _isSubmitting = true;
                                    });

                                    try {
                                      // Upload file
                                      await _courseService.uploadFile(
                                        selectedCourseId!,
                                        selectedModuleId!,
                                        _titleController.text,
                                      );

                                      // Refresh documents
                                      _fetchAllDocuments();

                                      Get.back();
                                      Get.snackbar(
                                        'Succès',
                                        'Le document a été ajouté avec succès',
                                        backgroundColor: ColorManager.green,
                                        colorText: Colors.white,
                                      );
                                    } catch (e) {
                                      print('Error adding document: $e');
                                      Get.snackbar(
                                        'Erreur',
                                        'Une erreur est survenue lors de l\'ajout du document',
                                        backgroundColor: Colors.red,
                                        colorText: Colors.white,
                                      );
                                    } finally {
                                      setState(() {
                                        _isSubmitting = false;
                                      });
                                    }
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorManager.primaryColor,
                            foregroundColor: Colors.white,
                          ),
                          child: _isSubmitting
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text('Ajouter'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Show dialog to add a document directly to a specific course
  void _showAddDocumentDialogWithModule(Course course) {
    final _formKey = GlobalKey<FormState>();
    final TextEditingController _titleController = TextEditingController();
    String? selectedModuleId =
        course.modules.isNotEmpty ? course.modules[0].id : null;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ajouter un document au cours ${course.code}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Gap(24),
                    if (course.modules.isEmpty)
                      Column(
                        children: [
                          Icon(
                            FeatherIcons.alertCircle,
                            color: Colors.amber,
                            size: 48,
                          ),
                          Gap(16),
                          Text(
                            'Ce cours n\'a pas encore de modules. Veuillez d\'abord créer un module.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: ColorManager.grey,
                            ),
                          ),
                          Gap(16),
                          ElevatedButton.icon(
                            onPressed: () {
                              Get.back();
                              _showAddModuleDialog(course);
                            },
                            icon: Icon(FeatherIcons.plus),
                            label: Text('Créer un module'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _getCourseColor(course.color),
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      )
                    else
                      Column(
                        children: [
                          DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: 'Module',
                              border: OutlineInputBorder(),
                            ),
                            value: selectedModuleId,
                            items: course.modules.map((module) {
                              return DropdownMenuItem<String>(
                                value: module.id,
                                child: Text(module.title),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedModuleId = value;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez sélectionner un module';
                              }
                              return null;
                            },
                          ),
                          Gap(16),
                          TextFormField(
                            controller: _titleController,
                            decoration: InputDecoration(
                              labelText: 'Titre du document',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez entrer un titre';
                              }
                              return null;
                            },
                          ),
                          Gap(24),

                          // Action buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () {
                                  Get.back();
                                },
                                child: Text('Annuler'),
                              ),
                              Gap(8),
                              ElevatedButton(
                                onPressed: _isSubmitting
                                    ? null
                                    : () async {
                                        if (_formKey.currentState!.validate()) {
                                          setState(() {
                                            _isSubmitting = true;
                                          });

                                          try {
                                            // Upload file
                                            await _courseService.uploadFile(
                                              course.id,
                                              selectedModuleId!,
                                              _titleController.text,
                                            );

                                            // Refresh documents
                                            _fetchAllDocuments();

                                            Get.back();
                                            Get.snackbar(
                                              'Succès',
                                              'Le document a été ajouté avec succès',
                                              backgroundColor:
                                                  ColorManager.green,
                                              colorText: Colors.white,
                                            );
                                          } catch (e) {
                                            print('Error adding document: $e');
                                            Get.snackbar(
                                              'Erreur',
                                              'Une erreur est survenue lors de l\'ajout du document',
                                              backgroundColor: Colors.red,
                                              colorText: Colors.white,
                                            );
                                          } finally {
                                            setState(() {
                                              _isSubmitting = false;
                                            });
                                          }
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      _getCourseColor(course.color),
                                  foregroundColor: Colors.white,
                                ),
                                child: _isSubmitting
                                    ? SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text('Ajouter'),
                              ),
                            ],
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Show dialog to add a new module to a course
  void _showAddModuleDialog(Course course) {
    final _formKey = GlobalKey<FormState>();
    final TextEditingController _titleController = TextEditingController();

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ajouter un module au cours ${course.code}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Gap(24),

                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Titre du module',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un titre';
                    }
                    return null;
                  },
                ),
                Gap(24),

                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Get.back();
                      },
                      child: Text('Annuler'),
                    ),
                    Gap(8),
                    ElevatedButton(
                      onPressed: _isSubmitting
                          ? null
                          : () async {
                              if (_formKey.currentState!.validate()) {
                                setState(() {
                                  _isSubmitting = true;
                                });

                                try {
                                  // Create new module
                                  final module = Module(
                                    id: const Uuid().v4(),
                                    title: _titleController.text,
                                    documents: [],
                                  );

                                  // Add module to course
                                  await _courseService.addModule(
                                      course.id, module);

                                  Get.back();
                                  Get.snackbar(
                                    'Succès',
                                    'Le module a été ajouté avec succès',
                                    backgroundColor: ColorManager.green,
                                    colorText: Colors.white,
                                  );
                                } catch (e) {
                                  print('Error adding module: $e');
                                  Get.snackbar(
                                    'Erreur',
                                    'Une erreur est survenue lors de l\'ajout du module',
                                    backgroundColor: Colors.red,
                                    colorText: Colors.white,
                                  );
                                } finally {
                                  setState(() {
                                    _isSubmitting = false;
                                  });
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _getCourseColor(course.color),
                        foregroundColor: Colors.white,
                      ),
                      child: _isSubmitting
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text('Ajouter'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper widget to build a module card in the course details view
  Widget _buildModuleCard(Module module, Color courseColor) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        title: Text(
          module.title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: ColorManager.SoftBlack,
          ),
        ),
        subtitle: Text(
          '${module.documents.length} document(s)',
          style: TextStyle(
            fontSize: 12,
            color: ColorManager.grey,
          ),
        ),
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: courseColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            FeatherIcons.folder,
            color: courseColor,
          ),
        ),
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                if (module.documents.isEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: Text(
                        'Aucun document dans ce module',
                        style: TextStyle(
                          fontSize: 14,
                          color: ColorManager.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  )
                else
                  for (var document in module.documents)
                    _buildDocumentItem(document, courseColor),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget to build a document item in a module
  Widget _buildDocumentItem(Document document, Color courseColor) {
    // Determine icon based on file type
    IconData fileIcon;
    switch (document.type) {
      case 'pdf':
        fileIcon = FeatherIcons.fileText;
        break;
      case 'doc':
      case 'docx':
        fileIcon = FeatherIcons.file;
        break;
      case 'ppt':
      case 'pptx':
        fileIcon = FeatherIcons.monitor;
        break;
      case 'xls':
      case 'xlsx':
        fileIcon = FeatherIcons.grid;
        break;
      case 'zip':
      case 'rar':
        fileIcon = FeatherIcons.archive;
        break;
      case 'jpg':
      case 'jpeg':
      case 'png':
        fileIcon = FeatherIcons.image;
        break;
      default:
        fileIcon = FeatherIcons.file;
    }

    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: courseColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          fileIcon,
          color: courseColor,
          size: 20,
        ),
      ),
      title: Text(
        document.title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: ColorManager.SoftBlack,
        ),
      ),
      subtitle: Text(
        'Ajouté le ${document.uploadDate} • ${document.size}',
        style: TextStyle(
          fontSize: 12,
          color: ColorManager.grey,
        ),
      ),
      trailing: IconButton(
        icon: Icon(
          FeatherIcons.download,
          size: 18,
          color: courseColor,
        ),
        onPressed: () {
          // Download document
          if (document.downloadUrl != null) {
            print('Downloading document: ${document.title}');
            Get.snackbar(
              'Téléchargement',
              'Le téléchargement de "${document.title}" a commencé',
              backgroundColor: courseColor,
              colorText: Colors.white,
            );
          } else {
            Get.snackbar(
              'Erreur',
              'Ce document n\'a pas d\'URL de téléchargement',
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
          }
        },
      ),
      onTap: () {
        // View document
        if (document.downloadUrl != null) {
          print('Viewing document: ${document.title}');
          // Implement actual document viewing
        } else {
          Get.snackbar(
            'Erreur',
            'Ce document n\'a pas d\'URL de téléchargement',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      },
    );
  }

  // Helper widget to build a color selector
  Widget _buildColorSelector({
    required String color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final Color colorValue = _getCourseColor(color);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        margin: EdgeInsets.only(right: 8, bottom: 8),
        decoration: BoxDecoration(
          color: colorValue,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.black : Colors.transparent,
            width: 2,
          ),
        ),
        child: isSelected
            ? Icon(
                FeatherIcons.check,
                color: Colors.white,
                size: 18,
              )
            : null,
      ),
    );
  }
}
