import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qadam/services/firestore_service.dart';

class AddGoalSheet extends StatefulWidget {
  const AddGoalSheet({Key? key}) : super(key: key);

  @override
  _AddGoalSheetState createState() => _AddGoalSheetState();
}

class _AddGoalSheetState extends State<AddGoalSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _categoryController = TextEditingController(text: 'Personal');
  final _descriptionController = TextEditingController();
  final _startDateController = TextEditingController();
  final _dueDateController = TextEditingController();
  final _frequencyController = TextEditingController(text: 'daily');
  final _firestoreService = FirestoreService();

  DateTime? _startDate;
  DateTime? _dueDate;

  Future<void> _addGoal() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final data = {
        'title': _titleController.text,
        'category': _categoryController.text,
        'description': _descriptionController.text,
        'status': 'on-track',
        'createdAt': FieldValue.serverTimestamp(),
        'startDate': _startDate != null ? Timestamp.fromDate(_startDate!) : null,
        'dueDate': _dueDate != null ? Timestamp.fromDate(_dueDate!) : null,
        'frequency': _categoryController.text == 'Habit' ? _frequencyController.text : null,
      };

      try {
        await _firestoreService.addGoal(data);
        Navigator.of(context).pop();
      } catch (e) {
        print("Error adding goal: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add goal: $e')),
        );
      }
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          _startDateController.text = DateFormat.yMd().format(picked);
        } else {
          _dueDate = picked;
          _dueDateController.text = DateFormat.yMd().format(picked);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = ['Personal', 'Work', 'Health', 'Finance', 'Learning', 'Habit'];
    final frequencies = ['daily', 'weekly', 'monthly'];

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
              DropdownButtonFormField<String>(
                initialValue: _categoryController.text,
                decoration: const InputDecoration(labelText: "Category"),
                items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (value) => setState(() {
                  _categoryController.text = value!;
                }),
              ),
               if (_categoryController.text == 'Habit') ...[
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _frequencyController.text,
                  decoration: const InputDecoration(labelText: "Frequency"),
                  items: frequencies.map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
                  onChanged: (value) => setState(() {
                    _frequencyController.text = value!;
                  }),
                ),
              ],
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description (optional)'),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _startDateController,
                      decoration: const InputDecoration(labelText: 'Start Date'),
                      readOnly: true,
                      onTap: () => _selectDate(context, true),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _dueDateController,
                      decoration: const InputDecoration(labelText: 'Due Date'),
                      readOnly: true,
                      onTap: () => _selectDate(context, false),
                    ),
                  ),
                ],
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
