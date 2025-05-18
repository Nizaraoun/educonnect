import 'package:flutter/material.dart';
import '../model/course_model.dart';
import 'empty_course_state.dart';
import 'course_list_item.dart';

class CoursesTab extends StatelessWidget {
  final List<Course> courses;
  final bool isLoading;
  final Function() onAddCourse;
  final Function(Course) onViewCourseDetails;
  final Function(Course) onEditCourse;

  const CoursesTab({
    Key? key,
    required this.courses,
    required this.isLoading,
    required this.onAddCourse,
    required this.onViewCourseDetails,
    required this.onEditCourse,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    if (courses.isEmpty) {
      return EmptyCourseState(onAddPressed: onAddCourse);
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: courses.length,
      itemBuilder: (context, index) {
        final course = courses[index];
        return CourseListItem(
          course: course,
          onEdit: () => onEditCourse(course),
          onViewDetails: () => onViewCourseDetails(course),
        );
      },
    );
  }
}
