
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
  final Timestamp createdAt;

  Goal({
    required this.id,
    required this.title,
    required this.category,
    required this.status,
    this.description,
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
      backgroundColor: AppTheme.surface, // Use theme color
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

              final totalGoals = goals.length;
              final completedGoals = goals.where((g) => g.status == 'completed').length;
              final inProgressGoals = totalGoals - completedGoals;

              return SafeArea(
                child: CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.of(context).pop()),
                      floating: true,
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          children: [
                             const Header(),
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
                              Text("No goals yet.", style: AppTheme.textTheme.headlineSmall),
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
        color: color.withAlpha(26),
      ),
      child: Center(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withAlpha(26),
                blurRadius: 50,
                spreadRadius: 20,
              ),
            ],
          ),
        ),
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
              style: AppTheme.textTheme.headlineLarge,
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

Widget _buildGlowContainer(Widget child, {Color? glowColor}) {
  return Container(
    decoration: BoxDecoration(
      boxShadow: [
        BoxShadow(
          color: (glowColor ?? AppTheme.primary).withAlpha(102),
          blurRadius: 15,
          spreadRadius: -5,
          offset: const Offset(0, 5),
        ),
      ],
    ),
    child: child,
  );
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
            gradient: const LinearGradient(colors: [AppTheme.primary, AppTheme.accent]),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatCard(
            value: inProgress.toString(),
            label: "In Progress",
            gradient: const LinearGradient(colors: [AppTheme.chart3, AppTheme.chart2]),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatCard(
            value: completed.toString(),
            label: "Completed",
            gradient: const LinearGradient(colors: [AppTheme.chart4, AppTheme.chart5]),
          ),
        ),
      ],
    );
  }
}

class StatCard extends StatelessWidget {
  final String value;
  final String label;
  final Gradient gradient;

  const StatCard({
    super.key,
    required this.value,
    required this.label,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return _buildGlowContainer(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: AppTheme.textTheme.displaySmall?.copyWith(color: AppTheme.primaryForeground),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTheme.textTheme.bodyMedium?.copyWith(color: AppTheme.primaryForeground.withAlpha(204)),
            ),
          ],
        ),
      ),
      glowColor: (gradient as LinearGradient).colors.first,
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
      Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(LucideIcons.flag, color: AppTheme.primary, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(goal.title,
                            style: AppTheme.textTheme.titleLarge),
                        Text(goal.category, style: AppTheme.textTheme.bodyMedium?.copyWith(color: AppTheme.mutedForeground)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.moreVertical),
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
                backgroundColor: statusColor.withAlpha(26),
                labelStyle: TextStyle(color: statusColor),
                side: BorderSide(color: statusColor),
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

// --- Dialog and Action Menu --- 

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
                color: AppTheme.surface.withAlpha(204),
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
                  leading: const Icon(LucideIcons.checkCircle, color: AppTheme.chart3),
                  title: Text(goal.status == 'completed' ? 'Mark as In Progress' : 'Mark as Completed', style: const TextStyle(color: AppTheme.chart3)),
                  onTap: () {
                     final newStatus = goal.status == 'completed' ? 'on-track' : 'completed';
                    _firestoreService.updateGoal(goal.id, {'status': newStatus});
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(LucideIcons.trash2, color: AppTheme.chart5),
                  title: const Text('Delete Goal', style: TextStyle(color: AppTheme.chart5)),
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
      backgroundColor: AppTheme.surface,
      title: const Text("Delete Goal?"),
      content: const Text("This action cannot be undone."),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
        ElevatedButton(
          onPressed: () {
            _firestoreService.deleteGoal(goalId);
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.chart5),
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

  final categories = ['Personal', 'Work', 'Health', 'Finance', 'Learning'];
  final statuses = ['on-track', 'at-risk', 'completed'];

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: AppTheme.surface,
            title: Text(goal == null ? "New Goal" : "Edit Goal"),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    initialValue: title,
                    decoration: const InputDecoration(labelText: "Title"),
                    validator: (value) =>
                        (value?.isEmpty ?? true) ? "Title cannot be empty" : null,
                    onSaved: (value) => title = value!,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: category,
                    decoration: const InputDecoration(labelText: "Category"),
                    items: categories
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        category = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: status,
                    decoration: const InputDecoration(labelText: "Status"),
                    items: statuses
                        .map((s) => DropdownMenuItem(
                            value: s, child: Text(s.replaceAll('-', ' '))))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        status = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: description,
                    decoration:
                        const InputDecoration(labelText: "Description (optional)"),
                    onSaved: (value) => description = value ?? '',
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel")),
              ElevatedButton(
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
