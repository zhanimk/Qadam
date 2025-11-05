import 'package:cloud_firestore/cloud_firestore.dart';

class Goal {
  final String id;
  final String title;
  final String category;
  final double progress; // Stored as a value between 0.0 and 1.0
  final String status;
  final List<Milestone> milestones;
  final DateTime dueDate;
  final String userId;

  Goal({
    required this.id,
    required this.title,
    required this.category,
    required this.progress,
    required this.status,
    required this.milestones,
    required this.dueDate,
    required this.userId,
  });

  // Factory constructor to create a Goal from a Firestore document
  factory Goal.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Goal(
      id: doc.id,
      title: data['title'] ?? '',
      category: data['category'] ?? '',
      progress: (data['progress'] as num?)?.toDouble() ?? 0.0,
      status: data['status'] ?? 'On Track',
      milestones: (data['milestones'] as List<dynamic>? ?? [])
          .map((m) => Milestone.fromMap(m as Map<String, dynamic>))
          .toList(),
      dueDate: (data['dueDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      userId: data['userId'] ?? '',
    );
  }

  // Method to convert a Goal object to a map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'category': category,
      'progress': progress,
      'status': status,
      'milestones': milestones.map((m) => m.toMap()).toList(),
      'dueDate': Timestamp.fromDate(dueDate),
      'userId': userId,
    };
  }
}

class Milestone {
  final String name;
  final bool isCompleted;

  Milestone({required this.name, this.isCompleted = false});

  // Factory constructor to create a Milestone from a map
  factory Milestone.fromMap(Map<String, dynamic> map) {
    return Milestone(
      name: map['name'] ?? '',
      isCompleted: map['isCompleted'] ?? false,
    );
  }

  // Method to convert a Milestone object to a map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'isCompleted': isCompleted,
    };
  }
}
