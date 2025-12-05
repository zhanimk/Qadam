import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:qadam/screens/goals_screen.dart'; 

class AddGoalSheet extends StatefulWidget {
  const AddGoalSheet({Key? key}) : super(key: key);

  @override
  _AddGoalSheetState createState() => _AddGoalSheetState();
}

class _AddGoalSheetState extends State<AddGoalSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _categoryController = TextEditingController();
  final _deadlineController = TextEditingController();

  Future<void> _addGoal() async {
    if (_formKey.currentState!.validate()) {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        // Handle user not being logged in
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You must be logged in to add a goal.')),
        );
        return;
      }

      final newGoal = Goal(
        id: '', // Firestore will generate this
        title: _titleController.text,
        category: _categoryController.text,
        deadline: _deadlineController.text,
        progress: 0,
        status: 'on-track',
        milestones: [],
      );

      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('goals')
            .add(newGoal.toMap());
        Navigator.of(context).pop();
      } catch (e) {
        // Handle error
        print("Error adding goal: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add goal: $e')), // Changed to showSnackBar
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Container(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add New Goal',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: 'Category'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a category';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _deadlineController,
                decoration: const InputDecoration(labelText: 'Deadline'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a deadline';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _addGoal,
                child: const Text('Add Goal'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
