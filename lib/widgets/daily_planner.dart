import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_theme.dart';

class DailyPlanner extends StatefulWidget {
  const DailyPlanner({Key? key}) : super(key: key);

  @override
  _DailyPlannerState createState() => _DailyPlannerState();
}

class _DailyPlannerState extends State<DailyPlanner> {
  final List<Map<String, dynamic>> _tasks = [
    {'task': 'Morning Standup', 'time': '9:00 AM', 'completed': true},
    {'task': 'Design Review', 'time': '11:00 AM', 'completed': false},
    {'task': 'Lunch Break', 'time': '1:00 PM', 'completed': false},
    {'task': 'Client Call', 'time': '3:00 PM', 'completed': false},
  ];

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Today's Tasks", style: AppTheme.textTheme.titleLarge),
            const SizedBox(height: 16),
            ..._tasks.map((task) {
              return ListTile(
                leading: Checkbox(
                  value: task['completed'] as bool,
                  onChanged: (value) {
                    setState(() {
                      task['completed'] = value!;
                    });
                  },
                ),
                title: Text(
                  task['task'] as String,
                  style: TextStyle(
                    decoration: (task['completed'] as bool) ? TextDecoration.lineThrough : TextDecoration.none,
                  ),
                ),
                subtitle: Text(task['time'] as String),
              );
            }),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(LucideIcons.plus),
              label: const Text("Add Task"),
            ),
          ],
        ),
      ),
    );
  }
}
