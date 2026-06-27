import 'package:cloud_firestore/cloud_firestore.dart';

class TaskModel {
  String id;
  String title;
  String memo;
  String status; // 'todo', 'done', or 'Specific Column ID'[cite: 13]
  int points;
  double progress;
  String priority; // 'Quick', 'Normal', 'Important'[cite: 13]
  DateTime? dueDate;
  DateTime? createdAt;

  TaskModel({
    required this.id,
    required this.title,
    this.memo = '',
    this.status = 'todo',
    this.points = 1,
    this.progress = 0.0,
    this.priority = 'Normal',
    this.dueDate,
    this.createdAt,
  });

  factory TaskModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TaskModel(
      id: doc.id,
      title: data['title'] ?? '',
      memo: data['memo'] ?? '',
      status: data['status'] ?? 'todo',
      points: data['points'] ?? 1,
      progress: (data['progress'] ?? 0.0).toDouble(),
      priority: data['priority'] ?? 'Normal', 
      dueDate: (data['dueDate'] as Timestamp?)?.toDate(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'memo': memo,
      'status': status,
      'points': points,
      'progress': progress,
      'priority': priority,
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }
}