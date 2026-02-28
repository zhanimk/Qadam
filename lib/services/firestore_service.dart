import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? get _user => FirebaseAuth.instance.currentUser;

  // --- USER DATA ---

  Future<void> initUserData() async {
    if (_user == null) return;
    final userDocRef = _db.collection('users').doc(_user!.uid);
    final doc = await userDocRef.get();

    if (!doc.exists) {
      debugPrint("Creating new user data in Firestore...");
      await userDocRef.set({
        'displayName': _user!.displayName ?? _user!.email?.split('@').first ?? 'Anonymous',
        'email': _user!.email,
        'createdAt': FieldValue.serverTimestamp(),
        'dailyProgress': {
          'mood': 'Calm',
          'caloriesBurned': 0,
          'caloriesGoal': 500,
          'focusHours': 0,
          'waterIntake': 0,
          'waterGoal': 8,
          'weight': 0.0,
          'spending': 0.0,
        },
        'awards': {
          'xp': 0,
          'level': 1,
          'unlocked': [],
        }
      });
    }
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>>? getUserDataStream() {
    if (_user == null) return null;
    return _db.collection('users').doc(_user!.uid).snapshots();
  }

  Future<void> updateDailyProgress(String field, dynamic value) async {
    if (_user == null) return;
    if (field.isEmpty) return;
    _db.collection('users').doc(_user!.uid).update({
      'dailyProgress.$field': value,
    });
  }

  Future<void> incrementDailyProgress(String field, num value) async {
    if (_user == null) return;
     if (field.isEmpty) return;
    _db.collection('users').doc(_user!.uid).update({
      'dailyProgress.$field': FieldValue.increment(value),
    });
    await addXp(5); // Add 5 XP for any daily progress update
  }

  // --- GOALS ---

  Stream<QuerySnapshot<Map<String, dynamic>>> getGoalsStream() {
    if (_user == null) return const Stream.empty();
    return _db.collection('users').doc(_user!.uid).collection('goals').orderBy('createdAt', descending: true).snapshots();
  }
   
  Future<void> addGoal(Map<String, dynamic> data) async {
    if (_user == null) return;
    await _db.collection('users').doc(_user!.uid).collection('goals').add(data);
    await addXp(25);
    await checkAndUnlockAchievement('first_goal');
  }

  Future<void> updateGoal(String goalId, Map<String, dynamic> data) async {
    if (_user == null) return;
    await _db.collection('users').doc(_user!.uid).collection('goals').doc(goalId).update(data);
  }

  Future<void> deleteGoal(String goalId) async {
    if (_user == null) return;
    await _db.collection('users').doc(_user!.uid).collection('goals').doc(goalId).delete();
  }

  // --- SPENDING GOALS ---

  Stream<QuerySnapshot<Map<String, dynamic>>> getSpendingGoalsStream() {
    if (_user == null) return const Stream.empty();
    return _db.collection('users').doc(_user!.uid).collection('spendingGoals').orderBy('createdAt', descending: true).snapshots();
  }
   
  Future<void> addSpendingGoal(Map<String, dynamic> data) async {
    if (_user == null) return;
    await _db.collection('users').doc(_user!.uid).collection('spendingGoals').add(data);
    await addXp(20);
  }

  Future<void> updateSpendingGoal(String goalId, Map<String, dynamic> data) async {
    if (_user == null) return;
    await _db.collection('users').doc(_user!.uid).collection('spendingGoals').doc(goalId).update(data);
  }

  Future<void> deleteSpendingGoal(String goalId) async {
    if (_user == null) return;
    await _db.collection('users').doc(_user!.uid).collection('spendingGoals').doc(goalId).delete();
  }

  // --- TRANSACTIONS ---

  Stream<QuerySnapshot<Map<String, dynamic>>> getTransactionsStream() {
    if (_user == null) return const Stream.empty();
    return _db.collection('users').doc(_user!.uid).collection('transactions').orderBy('date', descending: true).snapshots();
  }

  Future<void> addTransaction(Map<String, dynamic> data) async {
    if (_user == null) return;
    await _db.collection('users').doc(_user!.uid).collection('transactions').add(data);
    if (data['type'] == 'expense') {
      await incrementDailyProgress('spending', data['amount']);
    }
    await addXp(10);
    await checkAndUnlockAchievement('first_transaction');
  }

  // --- TASKS ---

  Stream<QuerySnapshot<Map<String, dynamic>>> getTasksStream() {
    if (_user == null) return const Stream.empty();
    return _db.collection('users').doc(_user!.uid).collection('tasks').orderBy('dueDate').snapshots();
  }

  Future<void> addTask(Map<String, dynamic> data) async {
    if (_user == null) return;
    await _db.collection('users').doc(_user!.uid).collection('tasks').add(data);
    await addXp(15);
    await checkAndUnlockAchievement('first_task');
  }

  Future<void> updateTask(String taskId, Map<String, dynamic> data) async {
    if (_user == null) return;
    await _db.collection('users').doc(_user!.uid).collection('tasks').doc(taskId).update(data);
    if (data.containsKey('status') && data['status'] == 'Done') {
      await addXp(30);
      await checkAndUnlockAchievement('task_master', 10);
    }
  }

  Future<void> deleteTask(String taskId) async {
    if (_user == null) return;
    await _db.collection('users').doc(_user!.uid).collection('tasks').doc(taskId).delete();
  }

  // --- AWARDS ---

  Future<void> addXp(int amount) async {
    if (_user == null) return;
    final userRef = _db.collection('users').doc(_user!.uid);
    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(userRef);
      final awards = snapshot.data()!['awards'] as Map<String, dynamic>;

      int currentXp = awards['xp'] ?? 0;
      int currentLevel = awards['level'] ?? 1;
      int newXp = currentXp + amount;

      int xpForNextLevel = 100 + (currentLevel * 50);

      while (newXp >= xpForNextLevel) {
        currentLevel++;
        newXp -= xpForNextLevel;
        xpForNextLevel = 100 + (currentLevel * 50);
      }

      transaction.update(userRef, {
        'awards.xp': newXp,
        'awards.level': currentLevel,
      });
    });
  }

  Future<void> checkAndUnlockAchievement(String achievementId, [int requiredCount = 0]) async {
    if (_user == null) return;

    final userRef = _db.collection('users').doc(_user!.uid);
    final snapshot = await userRef.get();
    final awards = snapshot.data()!['awards'] as Map<String, dynamic>;
    final unlocked = List<String>.from(awards['unlocked'] ?? []);

    if (unlocked.contains(achievementId)) return; // Already unlocked

    bool shouldUnlock = false;
    switch (achievementId) {
      case 'first_goal':
      case 'first_task':
      case 'first_transaction':
        shouldUnlock = true;
        break;
      case 'task_master':
        final tasksSnapshot = await userRef.collection('tasks').where('status', isEqualTo: 'Done').get();
        if (tasksSnapshot.docs.length >= requiredCount) {
          shouldUnlock = true;
        }
        break;
      // Add more achievement checks here...
    }

    if (shouldUnlock) {
      await userRef.update({
        'awards.unlocked': FieldValue.arrayUnion([achievementId])
      });
      await addXp(100); // Bonus XP for unlocking an achievement
    }
  }
}
