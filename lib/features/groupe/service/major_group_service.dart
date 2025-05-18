import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:educonnect/features/authentification/model/userdata.dart';
import 'package:educonnect/features/chat/controller/ChatController.dart';
import 'package:educonnect/features/groupe/model/group_model.dart';
import 'package:uuid/uuid.dart';

/// A service to group students by major and assign them to teachers from matching departments
class MajorGroupService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final uuid = const Uuid();

  /// Creates chat groups based on majors with matching teachers
  /// This will:
  /// 1. Fetch all students and group them by major
  /// 2. Fetch all teachers and match them with corresponding student majors
  /// 3. Create a chat group for each major with matched teachers
  Future<List<String>> createMajorBasedGroups() async {
    try {
      // Step 1: Fetch users and separate them into students and teachers
      final QuerySnapshot userSnapshot =
          await _firestore.collection('users').get();

      // Maps to store our grouped data
      final Map<String, List<UserModel>> studentsByMajor = {};
      final Map<String, List<UserModel>> teachersByDepartment = {};
      final List<String> createdGroupIds = [];

      // Categorize users
      for (var doc in userSnapshot.docs) {
        final user = UserModel.fromFirestore(doc);

        if (user.userType == 'student' &&
            user.major != null &&
            user.major!.isNotEmpty) {
          // Normalize major name (trim whitespace and convert to lowercase for comparison)
          final normalizedMajor = user.major!.trim().toLowerCase();

          if (!studentsByMajor.containsKey(normalizedMajor)) {
            studentsByMajor[normalizedMajor] = [];
          }
          studentsByMajor[normalizedMajor]!.add(user);
        } else if (user.userType == 'teacher' &&
            user.department != null &&
            user.department!.isNotEmpty) {
          // Normalize department name (trim whitespace and convert to lowercase for comparison)
          final normalizedDepartment = user.department!.trim().toLowerCase();

          if (!teachersByDepartment.containsKey(normalizedDepartment)) {
            teachersByDepartment[normalizedDepartment] = [];
          }
          teachersByDepartment[normalizedDepartment]!.add(user);
        }
      }

      // Step 2: For each student major, create a group with matching teachers
      for (var entry in studentsByMajor.entries) {
        final normalizedMajor = entry.key;
        final students = entry.value;

        // Skip if no students in this major
        if (students.isEmpty) continue;

        // Find teachers in a matching department
        List<UserModel> matchingTeachers = [];
        for (var deptEntry in teachersByDepartment.entries) {
          // Match department with major ignoring case and whitespace
          if (deptEntry.key == normalizedMajor) {
            matchingTeachers = deptEntry.value;
            break;
          }
        }

        // Create a group with these students and teachers
        if (students.isNotEmpty) {
          final originalMajorName =
              students.first.major!; // Use the original casing
          final groupId = await _createGroupForMajor(
              originalMajorName, students, matchingTeachers);
          if (groupId.isNotEmpty) {
            createdGroupIds.add(groupId);
          }
        }
      }

      return createdGroupIds;
    } catch (e) {
      print("Error creating major-based groups: $e");
      return [];
    }
  }

  /// Creates a group for a specific major with students and matching teachers
  Future<String> _createGroupForMajor(String majorName,
      List<UserModel> students, List<UserModel> teachers) async {
    try {
      // Generate a unique ID for the group
      final groupId = uuid.v4();

      // Combine all member IDs
      final List<String> memberIds = [
        ...students.map((student) => student.id),
        ...teachers.map((teacher) => teacher.id)
      ];

      // Teacher with longest experience (first in list) will be admin
      // Otherwise the first student becomes admin if no teachers
      final List<String> adminIds = teachers.isNotEmpty
          ? [teachers.first.id]
          : students.isNotEmpty
              ? [students.first.id]
              : [];

      // Create the group data
      final group = GroupModel(
        id: groupId,
        name: majorName,
        description:
            'Groupe pour les étudiants en $majorName avec leurs professeurs correspondants',
        category: 'Académique',
        creatorId: adminIds.isNotEmpty ? adminIds.first : memberIds.first,
        creatorName: 'Système EduConnect',
        memberIds: memberIds,
        adminIds: adminIds,
        memberCount: memberIds.length,
        createdAt: DateTime.now(),
        lastActivity: DateTime.now(),
        isPublic: false, // These are private groups
        hasChat: true, // Enable chat for these groups
      );

      // Save the group to Firestore
      await _firestore.collection('groups').doc(groupId).set(group.toJson());

      // Create a chat forum for the group
      try {
        // We need to ensure the ChatController is registered
        ChatController chatController;
        try {
          chatController = Get.find<ChatController>();
        } catch (e) {
          chatController = Get.put(ChatController());
        }

        await chatController.createForum(
          groupId: groupId,
          groupName: majorName,
          memberIds: memberIds,
        );

        print(
            "Created major group: $majorName with ${students.length} students and ${teachers.length} teachers");
        return groupId;
      } catch (e) {
        print("Error creating forum for major $majorName: $e");
        return groupId; // Still return groupId as the group was created
      }
    } catch (e) {
      print("Error creating group for major $majorName: $e");
      return '';
    }
  }
}
