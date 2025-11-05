
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_theme.dart';

class DailyProgressScreen extends StatelessWidget {
  final VoidCallback onBack;

  const DailyProgressScreen({Key? key, required this.onBack}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dailyStats = [
      {'label': "Steps", 'value': "8,432", 'goal': "10,000", 'icon': LucideIcons.activity, 'color': const [Color(0xFF10B981), Color(0xFF6EE7B7)], 'progress': 0.84},
      {'label': "Water", 'value': "6", 'goal': "8 cups", 'icon': LucideIcons.droplet, 'color': const [Color(0xFF3B82F6), Color(0xFF60A5FA)], 'progress': 0.75},
      {'label': "Sleep", 'value': "7.5h", 'goal': "8h", 'icon': LucideIcons.moon, 'color': const [Color(0xFF6366F1), Color(0xFF818CF8)], 'progress': 0.94},
      {'label': "Focus Time", 'value': "3.2h", 'goal': "4h", 'icon': LucideIcons.brain, 'color': const [Color(0xFF8B5CF6), Color(0xFFA78BFA)], 'progress': 0.80},
    ];

    final weeklyProgress = [
      {'day': "Mon", 'value': 85, 'completed': 12, 'total': 14},
      {'day': "Tue", 'value': 92, 'completed': 11, 'total': 12},
      {'day': "Wed", 'value': 78, 'completed': 10, 'total': 13},
      {'day': "Thu", 'value': 95, 'completed': 13, 'total': 14},
      {'day': "Fri", 'value': 88, 'completed': 11, 'total': 13},
      {'day': "Sat", 'value': 70, 'completed': 8, 'total': 11},
      {'day': "Sun", 'value': 82, 'completed': 9, 'total': 11},
    ];

    final todayActivities = [
      {'time': "07:00", 'activity': "Morning meditation", 'completed': true, 'duration': "15 min"},
      {'time': "07:30", 'activity': "Healthy breakfast", 'completed': true, 'duration': "30 min"},
      {'time': "09:00", 'activity': "Deep work session", 'completed': true, 'duration': "2 hours"},
      {'time': "12:00", 'activity': "Lunch & walk", 'completed': true, 'duration': "1 hour"},
      {'time': "14:00", 'activity': "Team meeting", 'completed': false, 'duration': "1 hour"},
      {'time': "18:00", 'activity': "Gym workout", 'completed': false, 'duration': "1.5 hours"},
      {'time': "21:00", 'activity': "Reading", 'completed': false, 'duration': "30 min"},
    ];


    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 24),
              _buildOverallProgress(context),
              const SizedBox(height: 32),
              _buildSectionHeader("Health Metrics"),
              const SizedBox(height: 16),
              _buildHealthMetrics(context, dailyStats),
              const SizedBox(height: 32),
              _buildSectionHeader("Weekly Overview"),
              const SizedBox(height: 16),
              _buildWeeklyOverview(context, weeklyProgress),
              const SizedBox(height: 32),
              _buildSectionHeader("Today's Timeline"),
              const SizedBox(height: 16),
              _buildTodayTimeline(context, todayActivities),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppTheme.onSurface),
          onPressed: onBack,
          style: IconButton.styleFrom(backgroundColor: AppTheme.card),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Daily Progress", style: AppTheme.textTheme.headlineSmall),
            Text(
              "Tuesday, July 23", // Example Date
              style: AppTheme.textTheme.bodyMedium?.copyWith(color: AppTheme.mutedForeground),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOverallProgress(BuildContext context) {
    final stats = [
      {'label': "Tasks", 'value': "12/15", 'icon': LucideIcons.checkCircle2},
      {'label': "Streak", 'value': "24", 'icon': LucideIcons.flame},
      {'label': "Time", 'value': "8.5h", 'icon': LucideIcons.clock},
      {'label': "Score", 'value': "1,240", 'icon': LucideIcons.award},
    ];
    const progressValue = 0.85;

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            SizedBox(
              width: 192,
              height: 192,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: progressValue),
                duration: const Duration(seconds: 2),
                builder: (context, value, child) {
                   return Stack(
                    fit: StackFit.expand,
                    children: [
                      CircularProgressIndicator(
                        value: 1,
                        strokeWidth: 12,
                        color: AppTheme.input,
                      ),
                      CircularProgressIndicator(
                        value: value,
                        strokeWidth: 12,
                        strokeCap: StrokeCap.round,
                        color: AppTheme.primary, // Simplified to one color
                      ),
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "${(value * 100).toInt()}%",
                              style: AppTheme.textTheme.displayMedium?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text("Daily Goal", style: AppTheme.textTheme.bodyMedium?.copyWith(color: AppTheme.mutedForeground)),
                          ],
                        ),
                      )
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: stats.map((stat) {
                return Column(
                  children: [
                    Icon(stat['icon'] as IconData, color: AppTheme.primary, size: 20),
                    const SizedBox(height: 8),
                    Text(stat['label'] as String, style: AppTheme.textTheme.bodySmall?.copyWith(color: AppTheme.mutedForeground)),
                    const SizedBox(height: 4),
                    Text(stat['value'] as String, style: AppTheme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthMetrics(BuildContext context, List<Map<String, dynamic>> stats) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.1,
      ),
      itemCount: stats.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final stat = stats[index];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: stat['color'] as List<Color>),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(stat['icon'] as IconData, color: Colors.white, size: 20),
                ),
                const Spacer(),
                Text(stat['value'] as String, style: AppTheme.textTheme.headlineSmall),
                 Text("Goal: ${stat['goal']}", style: AppTheme.textTheme.bodySmall?.copyWith(color: AppTheme.mutedForeground)),
                const SizedBox(height: 8),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: stat['progress'] as double),
                  duration: const Duration(seconds: 1),
                  builder: (context, value, child) {
                    return LinearProgressIndicator(
                      value: value,
                      backgroundColor: AppTheme.muted,
                      valueColor: AlwaysStoppedAnimation<Color>((stat['color'] as List<Color>)[0]),
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(3),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildWeeklyOverview(BuildContext context, List<Map<String, dynamic>> progress) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(
              height: 128,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: progress.map((day) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: (day['value'] as int) / 100.0),
                        duration: const Duration(milliseconds: 800),
                        builder: (context, value, child) {
                          return Flexible(
                            child: FractionallySizedBox(
                              heightFactor: value,
                              child: Container(
                                width: 24,
                                decoration: BoxDecoration(
                                  color: AppTheme.primary,
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      Text(
                        day['day'] as String,
                        style: AppTheme.textTheme.bodySmall?.copyWith(color: AppTheme.mutedForeground),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
             Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: progress.map((day) => Text(
                "${day['completed']}/${day['total']}",
                style: AppTheme.textTheme.bodySmall,
              )).toList(),
            )
          ],
        ),
      ),
    );
  }


  Widget _buildTodayTimeline(BuildContext context, List<Map<String, dynamic>> activities) {
    return Stack(
      children: [
        // Vertical line
        Positioned(
          left: 20,
          top: 10,
          bottom: 10,
          child: Container(width: 1.5, color: AppTheme.border),
        ),
        Column(
          children: activities.map((activity) {
            final isCompleted = activity['completed'] as bool;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  // Dot
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCompleted ? Colors.green : AppTheme.surface,
                      border: Border.all(color: isCompleted ? Colors.transparent : AppTheme.primary, width: 2),
                    ),
                    child: Icon(
                      isCompleted ? LucideIcons.check : LucideIcons.clock,
                      color: isCompleted ? Colors.white : AppTheme.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Card
                  Expanded(
                    child: Card(
                      color: AppTheme.card.withAlpha(isCompleted ? 150: 255),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              activity['activity'] as String,
                              style: AppTheme.textTheme.titleMedium?.copyWith(
                                decoration: isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                                color: isCompleted ? AppTheme.mutedForeground: AppTheme.onSurface
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "${activity['time']} • ${activity['duration']}",
                              style: AppTheme.textTheme.bodySmall?.copyWith(color: AppTheme.mutedForeground),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(title, style: AppTheme.textTheme.titleLarge);
  }
}
