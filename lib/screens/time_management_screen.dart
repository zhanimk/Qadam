import 'dart:async';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:qadam/models/task_model.dart';
import 'package:qadam/services/firestore_service.dart';
import 'package:qadam/theme/app_theme.dart';

class TimeManagementPage extends StatefulWidget {
  final VoidCallback onBack;
  const TimeManagementPage({Key? key, required this.onBack}) : super(key: key);

  @override
  _TimeManagementPageState createState() => _TimeManagementPageState();
}

class _TimeManagementPageState extends State<TimeManagementPage> {
  final FirestoreService _firestoreService = FirestoreService();
  Timer? _timer;
  String? _currentTaskId;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer(Task task) {
    if (_currentTaskId == task.id) return; 
    _stopTimer(); 

    setState(() => _currentTaskId = task.id);

    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      final newMinutes = task.minutesSpent + 1;
      _firestoreService.updateTask(task.id, {'minutesSpent': newMinutes});
      _firestoreService.incrementDailyProgress('focusHours', 1/60);
    });
  }

  void _stopTimer() {
    if (_timer == null) return;
    _timer!.cancel();
    setState(() => _currentTaskId = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080812),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppTheme.onSurface),
          onPressed: widget.onBack,
        ),
        title: Text("Task Manager", style: AppTheme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: AppTheme.onSurface)),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _firestoreService.getTasksStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final tasks = snapshot.data!.docs.map((doc) => Task.fromSnapshot(doc)).toList();
          final groupedTasks = _groupTasks(tasks);

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: groupedTasks.length,
            itemBuilder: (context, index) {
              final date = groupedTasks.keys.elementAt(index);
              final dailyTasks = groupedTasks[date]!;
              return _buildDateSection(date, dailyTasks);
            },
          );
        },
      ),
       floatingActionButton: FloatingActionButton(
        onPressed: () => _showTaskDialog(),
        backgroundColor: AppTheme.primary,
        child: const Icon(LucideIcons.plus, color: Colors.white),
      ),
    );
  }

  Map<DateTime, List<Task>> _groupTasks(List<Task> tasks) {
    final Map<DateTime, List<Task>> grouped = {};
    for (var task in tasks) {
      final dateKey = DateTime(task.dueDate.year, task.dueDate.month, task.dueDate.day);
      if (grouped[dateKey] == null) grouped[dateKey] = [];
      grouped[dateKey]!.add(task);
    }
    return grouped;
  }

  Widget _buildDateSection(DateTime date, List<Task> tasks) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 16.0, top: 24.0),
          child: Text(
            DateFormat.yMMMMd().format(date),
            style: AppTheme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: AppTheme.onSurface),
          ),
        ),
        ...tasks.map((task) => _buildTaskCard(task)),
      ],
    );
  }

  Widget _buildTaskCard(Task task) {
    final isCurrent = _currentTaskId == task.id;
    final progress = task.estimatedMinutes > 0 ? (task.minutesSpent / task.estimatedMinutes).clamp(0.0, 1.0) : 0.0;

    return _buildGlowContainer(
      _buildGlassCard(
        isTappable: true,
        onTap: () => _showTaskDialog(task: task),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text(task.title, style: AppTheme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: AppTheme.onSurface))),
                  const SizedBox(width: 16),
                  _buildStatusChip(task.status),
                  IconButton(
                    icon: Icon(isCurrent ? LucideIcons.pauseCircle : LucideIcons.playCircle, color: isCurrent ? AppTheme.primary : AppTheme.accent, size: 28),
                    onPressed: () => isCurrent ? _stopTimer() : _startTimer(task),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(LucideIcons.clock, size: 16, color: AppTheme.mutedForeground),
                  const SizedBox(width: 8),
                  Text("${task.minutesSpent} / ${task.estimatedMinutes} min", style: AppTheme.textTheme.bodyMedium?.copyWith(color: AppTheme.mutedForeground)),
                ],
              ),
              const SizedBox(height: 12),
              if (progress > 0) LinearProgressIndicator(
                value: progress,
                backgroundColor: AppTheme.surface.withAlpha(50),
                valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
              ),
            ],
          ),
        ),
      ),
      glowColor: isCurrent ? AppTheme.primary : Colors.transparent,
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    IconData icon;
    switch (status) {
      case 'In Progress':
        color = AppTheme.chart4;
        icon = LucideIcons.loader;
        break;
      case 'Done':
        color = AppTheme.chart3;
        icon = LucideIcons.checkCircle2;
        break;
      default: // To Do
        color = AppTheme.mutedForeground;
        icon = LucideIcons.circle;
        break;
    }
    return Chip(
      avatar: Icon(icon, color: color, size: 16),
      label: Text(status, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
      backgroundColor: color.withAlpha(25),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }


  void _showTaskDialog({Task? task}) {
    final isNew = task == null;
    final _titleController = TextEditingController(text: task?.title);
    final _minutesController = TextEditingController(text: task?.estimatedMinutes.toString());
    DateTime _selectedDate = task?.dueDate ?? DateTime.now();
    String _selectedStatus = task?.status ?? 'To Do';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: Text(isNew ? 'New Task' : 'Edit Task', style: const TextStyle(color: AppTheme.onSurface)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                style: const TextStyle(color: AppTheme.onSurface),
                decoration: const InputDecoration(labelText: 'Title', labelStyle: TextStyle(color: AppTheme.mutedForeground)),
              ),
              TextField(
                controller: _minutesController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: AppTheme.onSurface),
                decoration: const InputDecoration(labelText: 'Estimated Minutes', labelStyle: TextStyle(color: AppTheme.mutedForeground)),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                initialValue: _selectedStatus,
                dropdownColor: AppTheme.surface,
                style: const TextStyle(color: AppTheme.onSurface),
                decoration: const InputDecoration(labelText: 'Status', labelStyle: TextStyle(color: AppTheme.mutedForeground)),
                items: ['To Do', 'In Progress', 'Done'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (value) => _selectedStatus = value!,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Text('Due: ${DateFormat.yMd().format(_selectedDate)}', style: const TextStyle(color: AppTheme.onSurface)),
                  IconButton(icon: const Icon(LucideIcons.calendar, color: AppTheme.accent), onPressed: () async {
                    final newDate = await showDatePicker(context: context, initialDate: _selectedDate, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)));
                    if (newDate != null) setState(() => _selectedDate = newDate);
                  })
                ],
              ),
            ],
          ),
        ),
        actions: [
          if (!isNew) TextButton(
            child: const Text('Delete', style: TextStyle(color: AppTheme.chart2)),
            onPressed: () {
              _firestoreService.deleteTask(task.id);
              Navigator.of(context).pop();
            },
          ),
          TextButton(child: const Text('Cancel'), onPressed: () => Navigator.of(context).pop()),
          TextButton(
            child: const Text('Save'),
            onPressed: () {
              final data = {
                'title': _titleController.text,
                'estimatedMinutes': int.tryParse(_minutesController.text) ?? 30,
                'dueDate': Timestamp.fromDate(_selectedDate),
                'status': _selectedStatus,
              };
              if (isNew) {
                _firestoreService.addTask(data);
              } else {
                _firestoreService.updateTask(task.id, data);
              }
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGlassCard({required Widget child, bool isTappable = false, VoidCallback? onTap, double borderRadius = 20}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.surface.withAlpha(50),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: Colors.white.withAlpha(26)),
          ),
          child: isTappable
              ? Material(color: Colors.transparent, child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(borderRadius), child: child))
              : child,
        ),
      ),
    );
  }

  Widget _buildGlowContainer(Widget child, {Color? glowColor, double borderRadius = 20}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: (glowColor ?? AppTheme.primary.withAlpha(0)).withAlpha(glowColor == Colors.transparent ? 0 : 102),
            blurRadius: 25,
            spreadRadius: -8,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }
}
