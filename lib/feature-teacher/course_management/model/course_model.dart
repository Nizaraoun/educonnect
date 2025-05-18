import 'package:cloud_firestore/cloud_firestore.dart';

class Course {
  final String id;
  final String title;
  final String code;
  final int students;
  final String schedule;
  final String description;
  final String color;
  final List<Module> modules;

  Course({
    required this.id,
    required this.title,
    required this.code,
    required this.students,
    required this.schedule,
    required this.description,
    required this.color,
    required this.modules,
  });
  // Convert Firestore document to Course object
  factory Course.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Course(
      id: doc.id,
      title: data['title'] ?? '',
      code: data['code'] ?? '',
      students: data['students'] ?? 0,
      schedule: data['schedule'] ?? '',
      description: data['description'] ?? '',
      color: data['color'] ?? '#4CAF50',
      modules: data['modules'] != null
          ? List<Module>.from(
              (data['modules'] as List).map((module) => Module.fromMap(module)))
          : [],
    );
  }
  // Convert Course object to a Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'code': code,
      'students': students,
      'schedule': schedule,
      'description': description,
      'color': color,
      'modules': modules.map((module) => module.toMap()).toList(),
    };
  }
}

class Module {
  final String id;
  final String title;
  final List<Document> documents;

  Module({
    required this.id,
    required this.title,
    required this.documents,
  });

  // Convert Map to Module object
  factory Module.fromMap(Map<String, dynamic> map) {
    return Module(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      documents: map['documents'] != null
          ? List<Document>.from(
              (map['documents'] as List).map((doc) => Document.fromMap(doc)))
          : [],
    );
  }

  // Convert Module object to a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'documents': documents.map((doc) => doc.toMap()).toList(),
    };
  }
}

class Document {
  final String id;
  final String title;
  final String type;
  final String size;
  final String uploadDate;
  final String? downloadUrl; // URL to download the file from Firebase Storage

  Document({
    required this.id,
    required this.title,
    required this.type,
    required this.size,
    required this.uploadDate,
    this.downloadUrl,
  });

  // Convert Map to Document object
  factory Document.fromMap(Map<String, dynamic> map) {
    return Document(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      type: map['type'] ?? '',
      size: map['size'] ?? '',
      uploadDate: map['uploadDate'] ?? '',
      downloadUrl: map['downloadUrl'],
    );
  }

  // Convert Document object to a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'type': type,
      'size': size,
      'uploadDate': uploadDate,
      'downloadUrl': downloadUrl,
    };
  }
}
