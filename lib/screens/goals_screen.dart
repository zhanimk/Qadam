
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:qadam/theme/app_theme.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class Goal {
  final String id;
  final String title;
  final String category;
  final int progress;
  final String deadline;
  final String status;
  final List<Milestone> milestones;

  Goal({
    required this.id,
    required this.title,
    required this.category,
    required this.progress,
    required this.deadline,
    required this.status,
    required this.milestones,
  });

  factory Goal.fromMap(String id, Map<String, dynamic> data) {
    return Goal(
      id: id,
      title: data['title'] ?? 'No Title',
      category: data['category'] ?? 'Uncategorized',
      progress: (data['progress'] ?? 0).toInt(),
      deadline: data['deadline'] ?? 'No Deadline',
      status: data['status'] ?? 'on-track',
      milestones: (data['milestones'] as List<dynamic>? ?? [])
          .map((m) => Milestone.fromMap(m))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'category': category,
      'progress': progress,
      'deadline': deadline,
      'status': status,
      'milestones': milestones.map((m) => m.toMap()).toList(),
    };
  }
}

class Milestone {
  final String name;
  final bool completed;

  Milestone({required this.name, required this.completed});

  factory Milestone.fromMap(Map<String, dynamic> data) {
    return Milestone(
      name: data['name'] ?? 'Unnamed Milestone',
      completed: data['completed'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'completed': completed,
    };
  }
}

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.surface,
      child: Stack(
        children: [
          const AnimatedBackground(),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(24.0),
              children: const [
                Header(),
                SizedBox(height: 24),
                OverviewStats(),
                SizedBox(height: 24),
                GoalsList(),
                SizedBox(height: 16),
                MotivationalCard(),
              ],
            ),
          ),
        ],
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
  const OverviewStats({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: StatCard(
            value: "8",
            label: "Total Goals",
            gradient: LinearGradient(colors: [AppTheme.primary, AppTheme.accent]),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatCard(
            value: "5",
            label: "In Progress",
            gradient: LinearGradient(colors: [AppTheme.chart3, AppTheme.chart2]),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatCard(
            value: "3",
            label: "Completed",
            gradient: LinearGradient(colors: [AppTheme.chart4, AppTheme.chart5]),
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

class GoalsList extends StatefulWidget {
  const GoalsList({super.key});

  @override
  State<GoalsList> createState() => _GoalsListState();
}

class _GoalsListState extends State<GoalsList> {
  Stream<QuerySnapshot>? _goalsStream;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _goalsStream = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('goals')
          .snapshots();
    } else {
      _goalsStream = Stream.empty();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (FirebaseAuth.instance.currentUser == null) {
      return const Center(
        child: Text("Please log in to see your goals."),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: _goalsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No goals yet. Add one!"));
        }

        final goals = snapshot.data!.docs
            .map((doc) => Goal.fromMap(doc.id, doc.data() as Map<String, dynamic>))
            .toList();

        return AnimationLimiter(
          child: ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: goals.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final goal = goals[index];
              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 375),
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                    child: GoalCard(goal: goal),
                  ),
                ),
              );
            },
          ),
        );
      },
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
    final completedMilestones = goal.milestones.where((m) => m.completed).length;

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
                  const Icon(LucideIcons.flag, color: AppTheme.primary, size: 32),
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
                  const Icon(LucideIcons.moreVertical),
                ],
              ),
              const SizedBox(height: 12),
              Chip(
                label: Text(goal.status.replaceAll('-', ' ')),
                backgroundColor: statusColor.withAlpha(26),
                labelStyle: TextStyle(color: statusColor),
                side: BorderSide(color: statusColor),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Overall Progress"),
                  Text("${goal.progress}%",
                      style: AppTheme.textTheme.titleMedium),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: goal.progress / 100,
                backgroundColor: AppTheme.muted,
                valueColor: AlwaysStoppedAnimation<Color>(statusColor),
              ),
              const SizedBox(height: 16),
              Text("Milestones:", style: AppTheme.textTheme.titleMedium),
              ...goal.milestones.map((milestone) => MilestoneItem(milestone: milestone)),
              const Divider(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(LucideIcons.calendar, size: 16, color: AppTheme.mutedForeground),
                      const SizedBox(width: 8),
                      Text(goal.deadline, style: AppTheme.textTheme.bodyMedium?.copyWith(color: AppTheme.mutedForeground)),
                    ],
                  ),
                  Text("$completedMilestones/${goal.milestones.length}",
                      style: AppTheme.textTheme.bodyMedium?.copyWith(color: AppTheme.mutedForeground)),
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

class MilestoneItem extends StatelessWidget {
  final Milestone milestone;

  const MilestoneItem({super.key, required this.milestone});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(
            milestone.completed ? LucideIcons.checkCircle : LucideIcons.circle,
            color: milestone.completed ? AppTheme.chart3 : AppTheme.mutedForeground,
          ),
          const SizedBox(width: 8),
          Text(
            milestone.name,
            style: AppTheme.textTheme.bodyMedium?.copyWith(
              decoration: milestone.completed ? TextDecoration.lineThrough : null,
              color: milestone.completed ? AppTheme.mutedForeground : AppTheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class MotivationalCard extends StatelessWidget {
  const MotivationalCard({super.key});

  @override
  Widget build(BuildContext context) {
    return _buildGlowContainer(
      Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.primary, AppTheme.accent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Icon(LucideIcons.trendingUp, color: Colors.white, size: 32),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Keep it up!",
                        style: AppTheme.textTheme.titleLarge?.copyWith(color: AppTheme.primaryForeground)),
                    const SizedBox(height: 4),
                    Text(
                      "You're on the right track to achieving your goals. Small steps every day lead to big results.",
                      style: AppTheme.textTheme.bodyMedium?.copyWith(color: AppTheme.primaryForeground.withAlpha(204)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      glowColor: AppTheme.primary,
    );
  }
}
