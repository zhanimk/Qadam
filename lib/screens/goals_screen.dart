import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:qadam/services/firestore_service.dart';
import 'package:qadam/theme/app_theme.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'dart:math';


// NOTE: The Goal and Milestone models are simplified here. 
// In a real app, you might want to use a more robust solution like Freezed.
class Goal {
  final String id;
  final String title;
  final String category;
  final String status;
  final String? description;
  final String? frequency;
  final Timestamp createdAt;

  Goal({
    required this.id,
    required this.title,
    required this.category,
    required this.status,
    this.description,
    this.frequency,
    required this.createdAt,
  });

  factory Goal.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    return Goal(
      id: snapshot.id,
      title: data['title'] ?? 'No Title',
      category: data['category'] ?? 'Uncategorized',
      status: data['status'] ?? 'on-track',
      description: data['description'],
      frequency: data['frequency'],
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }
}

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({Key? key}) : super(key: key);

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080812),
      body: Stack(
        children: [
          const AnimatedBackground(),
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: _firestoreService.getGoalsStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              }
              
              final goalsDocs = snapshot.data?.docs ?? [];
              final goals = goalsDocs.map((doc) => Goal.fromSnapshot(doc)).toList();

              final habits = goals.where((g) => g.category == 'Habit').toList();
              final completedHabits = habits.where((h) => h.status == 'completed').length;

              final totalGoals = goals.length;
              final completedGoals = goals.where((g) => g.status == 'completed').length;
              final inProgressGoals = totalGoals - completedGoals;

              return SafeArea(
                child: CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppTheme.onSurface), onPressed: () => Navigator.of(context).pop()),
                      floating: true,
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          children: [
                             const Header(),
                             const SizedBox(height: 24),
                             DailyProgressCard(habits: habits.length, completed: completedHabits),
                             const SizedBox(height: 24),
                             OverviewStats(total: totalGoals, inProgress: inProgressGoals, completed: completedGoals),
                             const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                    if (goals.isEmpty) 
                      SliverFillRemaining(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(LucideIcons.target, size: 60, color: AppTheme.mutedForeground),
                              const SizedBox(height: 16),
                              Text("No goals yet.", style: AppTheme.textTheme.headlineSmall?.copyWith(color: AppTheme.onSurface)),
                              Text("Tap '+' to add one!", style: AppTheme.textTheme.bodyLarge?.copyWith(color: AppTheme.mutedForeground)),
                            ],
                          )
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        sliver: SliverList(delegate: SliverChildBuilderDelegate(
                          (context, index) {
                             return AnimationConfiguration.staggeredList(
                                position: index,
                                duration: const Duration(milliseconds: 375),
                                child: SlideAnimation(
                                  verticalOffset: 50.0,
                                  child: FadeInAnimation(
                                    child: Padding(
                                      padding: const EdgeInsets.only(bottom: 16.0),
                                      child: GoalCard(goal: goals[index]),
                                    ),
                                  ),
                                ),
                              );
                          },
                          childCount: goals.length,
                        )),
                      )
                  ],
                ),
              );
            },
          ),
        ],
      ),
       floatingActionButton: FloatingActionButton( 
        onPressed: () => _showGoalDialog(context),
        backgroundColor: AppTheme.accent,
        child: const Icon(LucideIcons.plus, color: Colors.white),
      ),
    );
  }
}

class AnimatedBackground extends StatefulWidget {
  const AnimatedBackground({super.key});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground> with TickerProviderStateMixin {
  late AnimationController _controller1;
  late AnimationController _controller2;

  @override
  void initState() {
    super.initState();
    _controller1 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
    _controller2 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedBuilder(
          animation: _controller1,
          builder: (context, child) {
            return Positioned(
              top: MediaQuery.of(context).size.height * 0.25 + sin(_controller1.value * 2 * pi) * 30,
              right: -50,
              child: const CircleGlow(color: AppTheme.primary, size: 200),
            );
          },
        ),
        AnimatedBuilder(
          animation: _controller2,
          builder: (context, child) {
            return Positioned(
              bottom: MediaQuery.of(context).size.height * 0.33 + sin(_controller2.value * 2 * pi) * 30,
              left: -50,
              child: const CircleGlow(color: AppTheme.accent, size: 200),
            );
          },
        ),
      ],
    );
  }
}

class CircleGlow extends StatelessWidget {
  final Color color;
  final double size;

  const CircleGlow({super.key, required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(50),
            blurRadius: 100,
            spreadRadius: 50,
          ),
        ],
      ),
    );
  }
}

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              "My Goals",
              style: AppTheme.textTheme.headlineLarge?.copyWith(color: AppTheme.onSurface, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            const SparklesIcon(),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          "Plan and achieve your dreams",
          style: AppTheme.textTheme.bodyLarge?.copyWith(color: AppTheme.mutedForeground),
        ),
      ],
    );
  }
}

class SparklesIcon extends StatefulWidget {
  const SparklesIcon({super.key});

  @override
  _SparklesIconState createState() => _SparklesIconState();
}

class _SparklesIconState extends State<SparklesIcon> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: Tween(begin: 0.0, end: 0.1).animate(_controller),
      child: const Icon(LucideIcons.sparkles, color: Colors.amber, size: 28),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

Widget _buildGlowContainer(Widget child, {Color? glowColor, double borderRadius = 20}) {
  return Container(
    decoration: BoxDecoration(
       borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: [
        BoxShadow(
          color: (glowColor ?? AppTheme.primary).withAlpha(102),
          blurRadius: 25,
          spreadRadius: -8,
           offset: const Offset(0, 5),
        ),
      ],
    ),
    child: child,
  );
}

class DailyProgressCard extends StatelessWidget {
  final int habits;
  final int completed;

  const DailyProgressCard({Key? key, required this.habits, required this.completed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double progress = habits > 0 ? completed / habits : 0;

    return _buildGlowContainer(
      _buildGlassCard(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(width: 70, height: 70, child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 8,
                      backgroundColor: AppTheme.surface.withAlpha(150),
                      valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.chart3),
                    )),
                    Text("${(progress * 100).toInt()}%"),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Your Daily Progress", style: AppTheme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text("$completed of $habits habits completed today", style: AppTheme.textTheme.bodyMedium?.copyWith(color: AppTheme.mutedForeground)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      glowColor: AppTheme.chart3,
    );
  }
}

class OverviewStats extends StatelessWidget {
  final int total, inProgress, completed;
  const OverviewStats({required this.total, required this.inProgress, required this.completed, super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: StatCard(
            value: total.toString(),
            label: "Total Goals",
            color: AppTheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatCard(
            value: inProgress.toString(),
            label: "In Progress",
            color: AppTheme.chart3,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatCard(
            value: completed.toString(),
            label: "Completed",
            color: AppTheme.chart4,
          ),
        ),
      ],
    );
  }
}

class StatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const StatCard({
    super.key,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return _buildGlowContainer(
       _buildGlassCard(
        borderRadius: 16,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: AppTheme.textTheme.displaySmall?.copyWith(color: AppTheme.onSurface, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: AppTheme.textTheme.bodyMedium?.copyWith(color: AppTheme.mutedForeground),
              ),
            ],
          ),
        ),
      ),
      glowColor: color,
    );
  }
}

class GoalCard extends StatelessWidget {
  final Goal goal;

  const GoalCard({super.key, required this.goal});

  Color getStatusColor(String status) {
    switch (status) {
      case "on-track":
        return AppTheme.chart3;
      case "at-risk":
        return AppTheme.chart5;
      case "completed":
        return AppTheme.chart4;
      default:
        return AppTheme.mutedForeground;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = getStatusColor(goal.status);

    return _buildGlowContainer(
       _buildGlassCard(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(goal.category == 'Habit' ? LucideIcons.repeat : LucideIcons.flag, color: AppTheme.primary, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(goal.title,
                              style: AppTheme.textTheme.titleLarge?.copyWith(color: AppTheme.onSurface, fontWeight: FontWeight.bold)),
                          Text(goal.category, style: AppTheme.textTheme.bodyMedium?.copyWith(color: AppTheme.mutedForeground)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(LucideIcons.moreVertical, color: AppTheme.onSurface),
                      onPressed: () => _showActionMenu(context, goal),
                    ),
                  ],
                ),
                if (goal.description != null && goal.description!.isNotEmpty)
                   Padding(
                     padding: const EdgeInsets.only(top: 8.0),
                     child: Text(goal.description!, style: AppTheme.textTheme.bodyMedium?.copyWith(color: AppTheme.mutedForeground)),
                   ),
                const SizedBox(height: 12),
                Chip(
                  label: Text(goal.status.replaceAll('-', ' ')),
                  backgroundColor: statusColor.withAlpha(50),
                  labelStyle: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
                  side: BorderSide(color: statusColor.withAlpha(100)),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(LucideIcons.calendar, size: 16, color: AppTheme.mutedForeground),
                     const SizedBox(width: 8),
                     Text( 'Created: ${goal.createdAt.toDate().day}/${goal.createdAt.toDate().month}/${goal.createdAt.toDate().year}', style: AppTheme.textTheme.bodySmall?.copyWith(color: AppTheme.mutedForeground)),
                  ],
                ),
              ],
            ),
          ),
        ),
      glowColor: statusColor,
    );
  }
}

Widget _buildGlassCard({required Widget child, double borderRadius = 20, bool isTappable = false, VoidCallback? onTap}) {
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
            ? Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(borderRadius),
                  child: child,
                ),
              )
            : child,
      ),
    ),
  );
}

final _firestoreService = FirestoreService();

void _showActionMenu(BuildContext context, Goal goal) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return BackdropFilter(
           filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
           child: Container(
             padding: const EdgeInsets.all(16),
             decoration: BoxDecoration(
                color: AppTheme.surface.withAlpha(220),
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
             ),
            child: Wrap(
              children: <Widget>[
                ListTile(
                  leading: const Icon(LucideIcons.edit, color: AppTheme.onSurface),
                  title: const Text('Edit Goal', style: TextStyle(color: AppTheme.onSurface)),
                  onTap: () {
                    Navigator.pop(context);
                    _showGoalDialog(context, goal: goal);
                  },
                ),
                ListTile(
                  leading: Icon(LucideIcons.checkCircle, color: AppTheme.chart3),
                  title: Text(goal.status == 'completed' ? 'Mark as In Progress' : 'Mark as Completed', style: TextStyle(color: AppTheme.chart3)),
                  onTap: () {
                     final newStatus = goal.status == 'completed' ? 'on-track' : 'completed';
                    _firestoreService.updateGoal(goal.id, {'status': newStatus});
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Icon(LucideIcons.trash2, color: AppTheme.chart5),
                  title: Text('Delete Goal', style: TextStyle(color: AppTheme.chart5)),
                  onTap: () {
                    Navigator.pop(context);
                    _showDeleteConfirmation(context, goal.id);
                  },
                ),
              ],
            ),
           ),
        );
      },
    );
}

void _showDeleteConfirmation(BuildContext context, String goalId) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: AppTheme.surface.withAlpha(220),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text("Delete Goal?", style: TextStyle(color: AppTheme.onSurface)),
      content: const Text("This action cannot be undone.", style: TextStyle(color: AppTheme.mutedForeground)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel", style: TextStyle(color: AppTheme.onSurface))),
        ElevatedButton(
          onPressed: () {
            _firestoreService.deleteGoal(goalId);
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.chart5, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
          child: const Text("Delete"),
        ),
      ],
    ),
  );
}

void _showGoalDialog(BuildContext context, {Goal? goal}) {
  final formKey = GlobalKey<FormState>();
  String title = goal?.title ?? '';
  String description = goal?.description ?? '';
  String category = goal?.category ?? 'Personal';
  String status = goal?.status ?? 'on-track';

  final categories = ['Personal', 'Work', 'Health', 'Finance', 'Learning', 'Habit'];
  final statuses = ['on-track', 'at-risk', 'completed'];

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: AppTheme.surface.withAlpha(240),
             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text(goal == null ? "New Goal" : "Edit Goal", style: AppTheme.textTheme.headlineSmall?.copyWith(color: AppTheme.onSurface)),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    initialValue: title,
                    style: const TextStyle(color: AppTheme.onSurface),
                    decoration: _getInputDecoration("Title"),
                    validator: (value) => (value?.isEmpty ?? true) ? "Title cannot be empty" : null,
                    onSaved: (value) => title = value!,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: category,
                     style: const TextStyle(color: AppTheme.onSurface),
                     dropdownColor: AppTheme.surface,
                    decoration: _getInputDecoration("Category"),
                    items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (value) => setState(() => category = value!),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: status,
                     style: const TextStyle(color: AppTheme.onSurface),
                    dropdownColor: AppTheme.surface,
                    decoration: _getInputDecoration("Status"),
                    items: statuses.map((s) => DropdownMenuItem(value: s, child: Text(s.replaceAll('-', ' ')))).toList(),
                    onChanged: (value) => setState(() => status = value!),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: description,
                    style: const TextStyle(color: AppTheme.onSurface),
                    decoration: _getInputDecoration("Description (optional)"),
                    onSaved: (value) => description = value ?? '',
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel", style: TextStyle(color: AppTheme.onSurface))),
              ElevatedButton(
                 style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    formKey.currentState!.save();
                    final data = {
                      'title': title,
                      'description': description,
                      'category': category,
                      'status': status,
                      'createdAt': goal?.createdAt ?? FieldValue.serverTimestamp(),
                    };
                    if (goal == null) {
                      _firestoreService.addGoal(data);
                    } else {
                      _firestoreService.updateGoal(goal.id, data);
                    }
                    Navigator.pop(context);
                  }
                },
                child: const Text("Save"),
              ),
            ],
          );
        },
      );
    },
  );
}

InputDecoration _getInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppTheme.mutedForeground),
      filled: true,
      fillColor: AppTheme.surface.withAlpha(100),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.white.withAlpha(26))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppTheme.accent)),
    );
  }
