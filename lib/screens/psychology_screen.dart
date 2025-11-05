import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_theme.dart';

class PsychologyPage extends StatefulWidget {
  final VoidCallback onBack;

  const PsychologyPage({Key? key, required this.onBack}) : super(key: key);

  @override
  _PsychologyPageState createState() => _PsychologyPageState();
}

class _PsychologyPageState extends State<PsychologyPage> with TickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildAnimatedWidget(Widget child, {required double intervalStart, double intervalEnd = 1.0, Offset slideBegin = const Offset(0, 30)}) {
    return AnimatedBuilder(
      animation: _animationController,
      child: child,
      builder: (context, child) {
        final animation = CurvedAnimation(
          parent: _animationController,
          curve: Interval(intervalStart, intervalEnd, curve: Curves.easeOutCubic),
        );
        final opacity = Tween<double>(begin: 0.0, end: 1.0).animate(animation);
        final slide = Tween<Offset>(begin: slideBegin, end: Offset.zero).animate(animation);

        return Opacity(
          opacity: opacity.value,
          child: Transform.translate(
            offset: slide.value,
            child: child,
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAnimatedWidget(
                Header(onBack: widget.onBack),
                intervalStart: 0.0, intervalEnd: 0.4,
              ),
              const SizedBox(height: 24),
              _buildAnimatedWidget(
                const HeroCard(),
                intervalStart: 0.1, intervalEnd: 0.5,
              ),
              const SizedBox(height: 24),
              _buildAnimatedWidget(
                const MoodTracker(),
                intervalStart: 0.2, intervalEnd: 0.6,
              ),
              const SizedBox(height: 24),
              _buildAnimatedWidget(
                const DailyJournal(),
                intervalStart: 0.3, intervalEnd: 0.8,
              ),
              const SizedBox(height: 24),
              _buildAnimatedWidget(
                const Courses(),
                intervalStart: 0.4, intervalEnd: 0.9,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Header extends StatelessWidget {
  final VoidCallback onBack;

  const Header({Key? key, required this.onBack}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppTheme.onSurface),
          onPressed: onBack,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Psychology & Self-Knowledge',
                style: AppTheme.textTheme.headlineSmall,
              ),
              Text(
                'Develop your emotional intelligence',
                style: AppTheme.textTheme.bodyMedium?.copyWith(color: AppTheme.mutedForeground),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class HeroCard extends StatelessWidget {
  const HeroCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _buildGlowContainer(
      Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [AppTheme.primary, AppTheme.accent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(LucideIcons.brain, color: Colors.white, size: 24),
                  const SizedBox(width: 8),
                  Text('Your Progress', style: AppTheme.textTheme.titleMedium?.copyWith(color: Colors.white)),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                '45%',
                style: TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('Keep up the great work!', style: AppTheme.textTheme.bodyMedium?.copyWith(color: Colors.white.withAlpha(204))),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: 0.45,
                backgroundColor: Colors.white.withAlpha(77),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ],
          ),
        ),
      ),
      glowColor: AppTheme.primary,
    );
  }
}

class MoodTracker extends StatelessWidget {
  const MoodTracker({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final moods = [
      {"icon": LucideIcons.smile, "label": "Great", "color": AppTheme.chart3},
      {"icon": LucideIcons.zap, "label": "Energetic", "color": AppTheme.chart4},
      {"icon": LucideIcons.heart, "label": "Grateful", "color": AppTheme.chart5},
      {"icon": LucideIcons.meh, "label": "Okay", "color": AppTheme.chart2},
      {"icon": LucideIcons.frown, "label": "Sad", "color": AppTheme.mutedForeground},
    ];

    return _buildGlowContainer(
      Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('How are you feeling today?', style: AppTheme.textTheme.titleLarge),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: moods.map((mood) {
                  return Column(
                    children: [
                      Icon(mood["icon"] as IconData, color: mood["color"] as Color, size: 32),
                      const SizedBox(height: 8),
                      Text(mood["label"] as String, style: AppTheme.textTheme.bodySmall),
                    ],
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DailyJournal extends StatelessWidget {
  const DailyJournal({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _buildGlowContainer(
      Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(LucideIcons.bookOpen, color: AppTheme.primary, size: 24),
                  const SizedBox(width: 8),
                  Text('Self-Reflection Journal', style: AppTheme.textTheme.titleLarge),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Write down your thoughts and feelings for today',
                style: AppTheme.textTheme.bodyMedium?.copyWith(color: AppTheme.mutedForeground),
              ),
              const SizedBox(height: 16),
              const TextField(
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'What\'s on your mind? What are you grateful for today?',
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {},
                child: const Text('Save Entry'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
              )
            ],
          ),
        ),
      ),
      glowColor: AppTheme.primary,
    );
  }
}

class Courses extends StatelessWidget {
  const Courses({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final courses = [
      {
        "title": "Emotion Management",
        "lessons": 12,
        "progress": 45,
        "locked": false,
        "image":
            "https://images.unsplash.com/photo-1630406866478-a2fca6070d25?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxwc3ljaG9sb2d5JTIwbWluZCUyMG1lZGl0YXRpb258ZW58MXx8fHwxNzYxMjk3MzQ4fDA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral"
      },
      {
        "title": "Meditation for Beginners",
        "lessons": 8,
        "progress": 100,
        "locked": false,
        "image":
            "https://images.unsplash.com/photo-1630406866478-a2fca6070d25?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxwc3ljaG9sb2d5JTIwbWluZCUyMG1lZGl0YXRpb258ZW58MXx8fHwxNzYxMjk3MzQ4fDA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral"
      },
      {
        "title": "Positive Thinking",
        "lessons": 10,
        "progress": 0,
        "locked": true,
        "image":
            "https://images.unsplash.com/photo-1630406866478-a2fca6070d25?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxwc3ljaG9sb2d5JTIwbWluZCUyMG1lZGl0YXRpb258ZW58MXx8fHwxNzYxMjk3MzQ4fDA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral"
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Courses & Exercises', style: AppTheme.textTheme.titleLarge),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: courses.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final course = courses[index];
            return _buildGlowContainer(
              Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.bottomLeft,
                      children: [
                        Image.network(
                          course["image"] as String,
                          height: 160,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                         Container(
                          height: 160,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.black.withAlpha(179), Colors.transparent],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                          ),
                        ),
                        if (course["locked"] as bool)
                          Container(
                            height: 160,
                            color: Colors.black.withAlpha(153),
                            child: const Center(
                              child: Icon(LucideIcons.lock, color: Colors.white, size: 40),
                            ),
                          ),
                           Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(course['title'] as String, style: AppTheme.textTheme.headlineSmall?.copyWith(color: Colors.white)),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                           Text('${course['lessons']} lessons', style: AppTheme.textTheme.bodySmall),
                          const SizedBox(height: 16),
                          if (!(course["locked"] as bool)) ...[
                            LinearProgressIndicator(
                              value: (course['progress'] as int) / 100.0,
                              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
                              backgroundColor: AppTheme.muted,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {},
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(LucideIcons.play, size: 16),
                                  const SizedBox(width: 8),
                                  Text((course['progress'] as int) > 0
                                      ? 'Continue'
                                      : 'Start Course'),
                                ],
                              ),
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 48),
                              ),
                            ),
                          ]
                        ],
                      ),
                    )
                  ],
                ),
              ),
              glowColor: AppTheme.primary,
            );
          },
        ),
      ],
    );
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
