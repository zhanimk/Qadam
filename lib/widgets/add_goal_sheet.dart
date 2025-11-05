import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/goal_model.dart';

class AddGoalSheet extends StatefulWidget {
  final String userId;
  const AddGoalSheet({Key? key, required this.userId}) : super(key: key);

  @override
  _AddGoalSheetState createState() => _AddGoalSheetState();
}

class _AddGoalSheetState extends State<AddGoalSheet> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _category = '';
  DateTime? _dueDate;
  List<TextEditingController> _milestoneControllers = [TextEditingController()];
  bool _isLoading = false;

  @override
  void dispose() {
    for (var controller in _milestoneControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addMilestoneField() {
    setState(() {
      _milestoneControllers.add(TextEditingController());
    });
  }

  void _removeMilestoneField(int index) {
    setState(() {
      _milestoneControllers[index].dispose();
      _milestoneControllers.removeAt(index);
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _dueDate) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (_dueDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a due date.'), backgroundColor: Colors.red),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      final newGoal = Goal(
        id: '', // Firestore will generate this
        title: _title,
        category: _category,
        dueDate: _dueDate!,
        milestones: _milestoneControllers
            .map((c) => Milestone(name: c.text, isCompleted: false))
            .where((m) => m.name.isNotEmpty)
            .toList(),
        progress: 0.0,
        status: 'On Track',
        userId: widget.userId, // Use the passed userId
      );

      try {
        await FirebaseFirestore.instance.collection('goals').add(newGoal.toFirestore());
        if (mounted) {
          Navigator.of(context).pop(); // Close the sheet on success
        }
      } catch (e) {
         if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to add goal: $e'), backgroundColor: Colors.red),
            );
         }
      } finally {
         if (mounted) {
            setState(() {
              _isLoading = false;
            });
         }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets, // Adjusts padding for keyboard
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: const BoxDecoration(
          color: Color(0xFF1F1D36),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25.0),
            topRight: Radius.circular(25.0),
          ),
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text('Create a New Goal', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                _buildTextFormField(label: 'Goal Title', onSaved: (value) => _title = value!),
                const SizedBox(height: 16),
                _buildTextFormField(label: 'Category (e.g., Health, Education)', onSaved: (value) => _category = value!),
                const SizedBox(height: 16),
                _buildDatePicker(),
                const SizedBox(height: 20),
                const Text('Milestones', style: TextStyle(color: Colors.white70)),
                ..._buildMilestoneFields(),
                const SizedBox(height: 24),
                 _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  TextFormField _buildTextFormField({required String label, required FormFieldSetter<String> onSaved}) {
    return TextFormField(
      onSaved: onSaved,
      validator: (value) => value == null || value.isEmpty ? 'This field cannot be empty' : null,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withAlpha(153)),
        filled: true,
        fillColor: const Color(0xFF2A2849).withAlpha(128),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
    );
  }
  
  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: () => _selectDate(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2849).withAlpha(128),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined, color: Colors.white70, size: 20),
            const SizedBox(width: 12),
            Text(
              _dueDate == null ? 'Select Due Date' : DateFormat.yMMMd().format(_dueDate!),
              style: TextStyle(color: _dueDate == null ? Colors.white.withAlpha(153) : Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildMilestoneFields() {
    List<Widget> fields = [];
    for (int i = 0; i < _milestoneControllers.length; i++) {
      fields.add(
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _milestoneControllers[i],
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Milestone ${i + 1}',
                    hintStyle: TextStyle(color: Colors.white.withAlpha(102)),
                    border: InputBorder.none,
                  ),
                ),
              ),
              if (_milestoneControllers.length > 1)
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                  onPressed: () => _removeMilestoneField(i),
                ),
            ],
          ),
        ),
      );
    }
    fields.add(
      TextButton.icon(
        icon: const Icon(Icons.add, color: Color(0xFF9040F8)),
        label: const Text('Add Milestone', style: TextStyle(color: Color(0xFF9040F8))),
        onPressed: _addMilestoneField,
      ),
    );
    return fields;
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _submitForm,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
      child: Ink(
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF9040F8), Color(0xFFF92B7B)]),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18),
          alignment: Alignment.center,
          child: const Text('SAVE GOAL', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
        ),
      ),
    );
  }
}
