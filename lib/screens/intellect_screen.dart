import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_theme.dart';

class IntellectPage extends StatefulWidget {
  final VoidCallback onBack;

  const IntellectPage({Key? key, required this.onBack}) : super(key: key);

  @override
  _IntellectPageState createState() => _IntellectPageState();
}

class _IntellectPageState extends State<IntellectPage> with TickerProviderStateMixin {
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
                const LearningStats(),
                intervalStart: 0.2, intervalEnd: 0.6,
              ),
              const SizedBox(height: 24),
              _buildAnimatedWidget(
                const Courses(),
                intervalStart: 0.3, intervalEnd: 0.8,
              ),
              const SizedBox(height: 24),
              _buildAnimatedWidget(
                const ReadingList(),
                intervalStart: 0.4, intervalEnd: 0.9,
              ),
              const SizedBox(height: 24),
              _buildAnimatedWidget(
                const DailyChallenge(),
                intervalStart: 0.5, intervalEnd: 1.0,
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
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Intellectual Development',
              style: AppTheme.textTheme.headlineSmall?.copyWith(color: AppTheme.onSurface),
            ),
            Text(
              'Develop your mind',
              style: AppTheme.textTheme.bodyMedium?.copyWith(color: AppTheme.mutedForeground),
            ),
          ],
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
        color: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [AppTheme.chart2, AppTheme.accent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Knowledge Level',
                    style: AppTheme.textTheme.titleMedium?.copyWith(color: Colors.white.withAlpha(230)),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '47',
                    style: TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: List.generate(5, (index) => Icon(LucideIcons.star, color: index < 3 ? Colors.white : Colors.white.withAlpha(128), size: 20)),
                  )
                ],
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(51),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(LucideIcons.brain, color: Colors.white, size: 40),
              ),
            ],
          ),
        ),
      ),
      glowColor: AppTheme.accent,
    );
  }
}

class LearningStats extends StatelessWidget {
  const LearningStats({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final learningStats = [
      {"icon": LucideIcons.bookOpen, "label": "Books Read", "value": "23", "color": AppTheme.chart2},
      {"icon": LucideIcons.brain, "label": "Courses Completed", "value": "8", "color": AppTheme.primary},
      {"icon": LucideIcons.lightbulb, "label": "Skills Mastered", "value": "15", "color": AppTheme.chart4},
      {"icon": LucideIcons.trophy, "label": "Certificates", "value": "5", "color": AppTheme.chart3},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.4,
      ),
      itemCount: learningStats.length,
      itemBuilder: (context, index) {
        final stat = learningStats[index];
        return _buildGlowContainer(
          Card(
            color: AppTheme.card,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: stat["color"] as Color,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(stat["icon"] as IconData, color: Colors.white, size: 20),
                  ),
                  const Spacer(),
                  Text(stat["value"] as String, style: AppTheme.textTheme.headlineMedium?.copyWith(color: AppTheme.cardForeground)),
                  const SizedBox(height: 4),
                  Text(stat["label"] as String, style: AppTheme.textTheme.bodySmall?.copyWith(color: AppTheme.mutedForeground)),
                ],
              ),
            ),
          ),
          glowColor: stat["color"] as Color,
        );
      },
    );
  }
}

class Courses extends StatelessWidget {
  const Courses({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final courses = [
      {"title": "Speed Reading", "category": "Learning Skills", "progress": 75, "lessons": 12, "completed": 9, "locked": false, "difficulty": "Intermediate", "image": "https://images.unsplash.com/photo-1542725752-e9f7259b3881?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxib29rcyUyMGxlYXJuaW5nJTIwZWR1Y2F0aW9ufGVufDF8fHx8MTc2MTI4MjcxN3ww&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral"},
      {"title": "Critical Thinking", "category": "Mindset", "progress": 45, "lessons": 16, "completed": 7, "locked": false, "difficulty": "Advanced", "image": "https://images.unsplash.com/photo-1542725752-e9f7259b3881?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxib29rcyUyMGxlYXJuaW5nJTIwZWR1Y2F0aW9ufGVufDF8fHx8MTc2MTI4MjcxN3ww&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral"},
      {"title": "Memory Development", "category": "Cognitive Skills", "progress": 0, "lessons": 10, "completed": 0, "locked": true, "difficulty": "Beginner", "image": "https://images.unsplash.com/photo-1542725752-e9f7259b3881?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxib29rcyUyMGxlYXJuaW5nJTIwZWR1Y2F0aW9ufGVufDF8fHx8MTc2MTI4MjcxN3ww&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral"},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Active Courses', style: AppTheme.textTheme.titleLarge?.copyWith(color: AppTheme.onSurface)),
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
                color: AppTheme.card,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.bottomLeft,
                      children: [
                        Image.network(course["image"] as String, height: 160, width: double.infinity, fit: BoxFit.cover),
                        Container(height: 160, width: double.infinity, decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.black.withAlpha(204), Colors.transparent], begin: Alignment.bottomCenter, end: Alignment.topCenter))),
                        if (course["locked"] as bool)
                          Container(height: 160, width: double.infinity, color: Colors.black.withAlpha(153), child: const Center(child: Icon(LucideIcons.lock, color: Colors.white, size: 40))),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  Chip(label: Text(course['category'] as String), backgroundColor: AppTheme.accent.withAlpha(204)),
                                  const SizedBox(width: 8),
                                  Chip(label: Text(course['difficulty'] as String), backgroundColor: Colors.white.withAlpha(51)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(course['title'] as String, style: AppTheme.textTheme.headlineSmall?.copyWith(color: Colors.white)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${course['completed']} of ${course['lessons']} lessons', style: AppTheme.textTheme.bodyMedium?.copyWith(color: AppTheme.mutedForeground)),
                              Text('${course['progress']}% ', style: AppTheme.textTheme.bodyMedium?.copyWith(color: AppTheme.mutedForeground)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: (course['progress'] as int) / 100.0,
                            backgroundColor: AppTheme.muted,
                            valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accent),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: (course["locked"] as bool) ? null : () {},
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(LucideIcons.play, size: 16),
                                const SizedBox(width: 8),
                                Text((course['progress'] as int) > 0 ? 'Continue Learning' : 'Start Course'),
                              ],
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: (course['progress'] as int) > 0 ? AppTheme.primary : AppTheme.card,
                              foregroundColor: AppTheme.primaryForeground,
                              minimumSize: const Size(double.infinity, 48),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
              glowColor: AppTheme.accent,
            );
          },
        ),
      ],
    );
  }
}

class ReadingList extends StatelessWidget {
  const ReadingList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final readingList = [
      {"title": "Thinking, Fast and Slow", "author": "Daniel Kahneman", "progress": 65, "pages": 656},
      {"title": "Atomic Habits", "author": "James Clear", "progress": 100, "pages": 320},
      {"title": "Flow", "author": "Mihaly Csikszentmihalyi", "progress": 30, "pages": 461},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Reading List', style: AppTheme.textTheme.titleLarge?.copyWith(color: AppTheme.onSurface)),
        const SizedBox(height: 16),
        ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: readingList.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final book = readingList[index];
              return _buildGlowContainer(
                Card(
                  color: AppTheme.card,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Container(
                          width: 64, height: 80, 
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                             gradient: const LinearGradient(colors: [AppTheme.primary, AppTheme.accent]),
                          ),
                          child: const Icon(LucideIcons.bookOpen, color: Colors.white, size: 32),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(book['title'] as String, style: AppTheme.textTheme.titleMedium?.copyWith(color: AppTheme.cardForeground)),
                              const SizedBox(height: 4),
                              Text(book['author'] as String, style: AppTheme.textTheme.bodySmall?.copyWith(color: AppTheme.mutedForeground)),
                              const SizedBox(height: 8),
                               Row(
                                 children: [
                                   Text('${book['pages']} pages', style: AppTheme.textTheme.bodySmall?.copyWith(color: AppTheme.mutedForeground)),
                                   const SizedBox(width: 8),
                                   Text('•', style: AppTheme.textTheme.bodySmall?.copyWith(color: AppTheme.mutedForeground)),
                                   const SizedBox(width: 8),
                                   Text('${book['progress']}% ', style: AppTheme.textTheme.bodySmall?.copyWith(color: AppTheme.mutedForeground)),
                                 ],
                               ),
                               const SizedBox(height: 8),
                              LinearProgressIndicator(
                                value: (book['progress'] as int) / 100.0,
                                backgroundColor: AppTheme.muted,
                                valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
                              ),
                               if (book['progress'] == 100)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Row(
                                     children: [
                                       const Icon(LucideIcons.checkCircle, color: AppTheme.chart3, size: 16),
                                       const SizedBox(width: 4),
                                       Text('Completed', style: AppTheme.textTheme.bodySmall?.copyWith(color: AppTheme.chart3)),
                                     ],
                                  ),
                                )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                glowColor: AppTheme.primary,
              );
            }),
      ],
    );
  }
}

class DailyChallenge extends StatelessWidget {
  const DailyChallenge({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _buildGlowContainer(
      Card(
        color: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [AppTheme.chart4, AppTheme.chart5],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                   Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(51),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(LucideIcons.lightbulb, color: Colors.white, size: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                         Text('Intellectual Challenge', style: AppTheme.textTheme.titleMedium?.copyWith(color: Colors.white)),
                         Text('Daily brain workout', style: AppTheme.textTheme.bodyMedium?.copyWith(color: Colors.white.withAlpha(179))),
                      ],
                    ),
                  )
                ],
              ),
              const SizedBox(height: 16),
              Text('Solve 5 logic puzzles and earn +50 XP', style: AppTheme.textTheme.bodyMedium?.copyWith(color: Colors.white.withAlpha(179))),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {},
                child: const Text('Start Challenge'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppTheme.chart4,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              )
            ],
          ),
        ),
      ),
      glowColor: AppTheme.chart4,
    );
  }
}

// Helper function to build glow container, assuming it's defined in the scope of the state class
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
