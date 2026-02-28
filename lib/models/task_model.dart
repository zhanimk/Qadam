import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  final String id;
  final String title;
  final DateTime dueDate;
  final String status; // e.g., 'To Do', 'In Progress', 'Done'
  final int estimatedMinutes;
  final int minutesSpent;

  Task({
    required this.id,
    required this.title,
    required this.dueDate,
    required this.status,
    required this.estimatedMinutes,
    this.minutesSpent = 0,
  });

  factory Task.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    return Task(
      id: snapshot.id,
      title: data['title'] ?? 'Untitled Task',
      dueDate: (data['dueDate'] as Timestamp).toDate(),
      status: data['status'] ?? 'To Do',
      estimatedMinutes: data['estimatedMinutes'] ?? 30,
      minutesSpent: data['minutesSpent'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'dueDate': Timestamp.fromDate(dueDate),
      'status': status,
      'estimatedMinutes': estimatedMinutes,
      'minutesSpent': minutesSpent,
    };
  }
}
