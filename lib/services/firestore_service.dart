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
  }

  // --- GOALS ---

  Stream<QuerySnapshot<Map<String, dynamic>>> getGoalsStream() {
    if (_user == null) return const Stream.empty();
    return _db.collection('users').doc(_user!.uid).collection('goals').orderBy('createdAt', descending: true).snapshots();
  }
   
  Future<void> addGoal(Map<String, dynamic> data) async {
    if (_user == null) return;
    await _db.collection('users').doc(_user!.uid).collection('goals').add(data);
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
  }
}
