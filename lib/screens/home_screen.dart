import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:qadam/screens/intellect_screen.dart';
import '../theme/app_theme.dart';
import 'psychology_screen.dart';
import 'finance_screen.dart';
import 'health_screen.dart';
import 'time_management_screen.dart';

// A placeholder for the analytics widget
class AnalyticsWidget extends StatelessWidget {
  const AnalyticsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('Analytics Widget Placeholder', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _staggeredController;

  @override
  void initState() {
    super.initState();
    _staggeredController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _staggeredController.forward();
  }

  @override
  void dispose() {
    _staggeredController.dispose();
    super.dispose();
  }

  Widget _buildAnimatedWidget(Widget child, {required double intervalStart, double intervalEnd = 1.0, Offset slideBegin = const Offset(0, 50)}) {
    return AnimatedBuilder(
      animation: _staggeredController,
      child: child,
      builder: (context, child) {
        final animation = CurvedAnimation(
          parent: _staggeredController,
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

  final categories = [
    {
      'id': "psychology",
      'icon': LucideIcons.brain,
      'title': "Psychology",
      'subtitle': "Self-Knowledge",
      'color': [AppTheme.chart2, AppTheme.chart1, AppTheme.primary],
      'progress': 45.0
    },
    {
      'id': "finance",
      'icon': LucideIcons.dollarSign,
      'title': "Finance",
      'subtitle': "Financial Literacy",
       'color': [const Color(0xFF11998e), const Color(0xFF38ef7d), Colors.greenAccent.shade700],
      'progress': 32.0
    },
    {
      'id': "health",
      'icon': LucideIcons.heart,
      'title': "Health",
      'subtitle': "Physical Activity",
       'color': [const Color(0xFFFDC830), const Color(0xFFF37335), Colors.orangeAccent.shade700],
      'progress': 67.0
    },
    {
      'id': "intellect",
      'icon': LucideIcons.bookOpen,
      'title': "Intellect",
      'subtitle': "Development",
      'color': [const Color(0xFF00D2FF), const Color(0xFF3A7BD5), Colors.blueAccent.shade700],
      'progress': 54.0
    },
    {
      'id': "time",
      'icon': LucideIcons.clock,
      'title': "Time Management",
      'subtitle': "Productivity",
       'color': [AppTheme.chart1, AppTheme.chart4, AppTheme.chart5],
      'progress': 38.0
    },
  ];

  final stats = [
    {'label': "Current Streak", 'value': "24", 'icon': LucideIcons.flame, 'page': null},
    {'label': "Active Goals", 'value': "8", 'icon': LucideIcons.target, 'page': "goals"},
    {'label': "Daily Progress", 'value': "85%", 'icon': LucideIcons.trendingUp, 'page': "daily"},
    {'label': "Achievements", 'value': "15", 'icon': LucideIcons.award, 'page': "achievements"},
  ];

  final quickActions = [
    {'id': "focus", 'icon': LucideIcons.zap, 'label': "Focus", 'color': const Color(0xFFFDC830)},
    {'id': "habits", 'icon': LucideIcons.repeat, 'label': "Habits", 'color': const Color(0xFF38ef7d)},
    {'id': "time", 'icon': LucideIcons.clock, 'label': "Timer", 'color': AppTheme.primary},
    {'id': "daily", 'icon': LucideIcons.calendar, 'label': "Daily", 'color': const Color(0xFF00D2FF)},
  ];

  final tasks = [
    {'task': "15-minute meditation", 'time': "09:00", 'completed': true},
    {'task': "Read 30 pages", 'time': "14:00", 'completed': false},
    {'task': "Gym workout", 'time': "18:00", 'completed': false},
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
              title: _buildAnimatedWidget(
                StreamBuilder<User?>(
                  stream: FirebaseAuth.instance.userChanges(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Text("Hello!");
                    }
                    final user = snapshot.data;
                    final displayName = user?.displayName ?? "User";
                    return Text("Hello, $displayName!");
                  },
                ),
                intervalStart: 0.0,
                intervalEnd: 0.4,
              ),
              background: Container(color: AppTheme.surface),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAnimatedWidget(
                    Text("Let's continue your journey to success", style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppTheme.mutedForeground)),
                     intervalStart: 0.1,
                     intervalEnd: 0.5,
                  ),
                  const SizedBox(height: 24),
                  _buildStatsGrid(),
                  const SizedBox(height: 24),
                  _buildMotivationalCard(),
                  const SizedBox(height: 24),
                  _buildDevelopmentAreas(),
                   const SizedBox(height: 24),
                  _buildAnimatedWidget(
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                         Text("This Week's Analytics", style: Theme.of(context).textTheme.headlineSmall),
                         const SizedBox(height: 16),
                         const AnalyticsWidget(),
                      ],
                    ),
                     intervalStart: 0.7,
                     intervalEnd: 0.9,
                  ),
                   const SizedBox(height: 24),
                  _buildQuickActions(),
                   const SizedBox(height: 24),
                  _buildTodaysTasks(),
                  const SizedBox(height: 120), // Padding for nav bar
                ],
              ),
            ),
          ),
        ],
      ),
    );
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

  Widget _buildStatsGrid() {
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
        return _buildAnimatedWidget(
          _buildGlowContainer(
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                     Icon(stat['icon'] as IconData, color: AppTheme.primary, size: 28),
                     Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                          Text(stat['value'] as String, style: Theme.of(context).textTheme.displaySmall),
                          Text(stat['label'] as String, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.mutedForeground)),
                       ],
                     ),
                  ],
                ),
              ),
            ),
          ),
          intervalStart: 0.2 + (index * 0.05),
          intervalEnd: 0.6 + (index * 0.05),
        );
      },
    );
  }

  Widget _buildMotivationalCard() {
    return _buildAnimatedWidget(
      _buildGlowContainer(
        Card(
          color: AppTheme.primary,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 Text("Daily Motivation ✨", style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppTheme.primaryForeground.withAlpha(204))),
                const SizedBox(height: 8),
                Text(
                  '"Success is the sum of small efforts, repeated day in and day out"',
                   style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppTheme.primaryForeground, fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text("— Robert Collier", style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.primaryForeground.withAlpha(178))),
                ),
              ],
            ),
          ),
        ),
        glowColor: AppTheme.primary,
      ),
      intervalStart: 0.4,
      intervalEnd: 0.8,
    );
  }

  Widget _buildDevelopmentAreas() {
    return _buildAnimatedWidget(
      Column(
         crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Development Areas", style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          ListView.builder(
            itemCount: categories.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final category = categories[index];
              final colors = category['color'] as List<Color>;
              return _buildAnimatedWidget(
                 _buildGlowContainer(
                   GestureDetector(
                      onTap: () {
                        if (category['id'] == 'psychology') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => PsychologyPage(onBack: () => Navigator.pop(context))),
                          );
                        } else if (category['id'] == 'finance') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => FinanceScreen(onBack: () => Navigator.pop(context))),
                          );
                        } else if (category['id'] == 'health') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => HealthPage(onBack: () => Navigator.pop(context))),
                          );
                        } else if (category['id'] == 'intellect') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => IntellectPage(onBack: () => Navigator.pop(context))),
                          );
                        } else if (category['id'] == 'time') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => TimeManagementPage(onBack: () => Navigator.pop(context))),
                          );
                        }
                      },
                      child: Card(
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.all(12),
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(12),
                                                    gradient: LinearGradient(colors: colors)
                                                  ),
                                                  child: Icon(category['icon'] as IconData, color: Colors.white),
                                                ),
                                                const SizedBox(width: 16),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(category['title'] as String, style: Theme.of(context).textTheme.titleLarge),
                                                      Text(category['subtitle'] as String, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.mutedForeground)),
                                                    ],
                                                  ),
                                                ),
                                                const Icon(LucideIcons.chevronRight, color: AppTheme.mutedForeground),
                                              ],
                                            ),
                                            const SizedBox(height: 16),
                                             Row(
                                              children: [
                                                Expanded(
                                                  child: ClipRRect(
                                                    borderRadius: BorderRadius.circular(10),
                                                    child: LinearProgressIndicator(
                                                      value: (category['progress'] as double) / 100,
                                                      minHeight: 10,
                                                      valueColor: AlwaysStoppedAnimation<Color>(colors[0]),
                                                      backgroundColor: AppTheme.muted,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 16),
                                                Text("${(category['progress'] as double).toInt()}%", style: Theme.of(context).textTheme.titleMedium?.copyWith(color: colors[0])),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                   ),
                   glowColor: colors[0],
                 ),
                intervalStart: 0.5 + (index * 0.05),
                intervalEnd: 0.9 + (index * 0.05),
                slideBegin: const Offset(-30, 0),
              );
            },
          ),
        ],
      ),
      intervalStart: 0.5,
      intervalEnd: 0.9,
    );
  }

  Widget _buildQuickActions() {
    return _buildAnimatedWidget(
       Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           Text("Quick Actions", style: Theme.of(context).textTheme.headlineSmall),
           const SizedBox(height: 16),
           GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: quickActions.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final action = quickActions[index];
                final color = action['color'] as Color;
                return _buildAnimatedWidget(
                  _buildGlowContainer(
                    Card(
                      color: color.withAlpha(51),
                      child: InkWell(
                        onTap: () {},
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(action['icon'] as IconData, color: color),
                            const SizedBox(height: 8),
                            Text(action['label'] as String, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color)),
                          ],
                        ),
                      ),
                    ),
                    glowColor: color,
                  ),
                  intervalStart: 0.8 + (index * 0.05),
                  intervalEnd: 1.0,
                );
              },
            ),
         ],
       ),
        intervalStart: 0.8,
        intervalEnd: 1.0
    );
  }

  Widget _buildTodaysTasks() {
     return _buildAnimatedWidget(
        Column(
           crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Today's Tasks", style: Theme.of(context).textTheme.headlineSmall),
                  TextButton(
                    onPressed: () {},
                    child: Row(
                      children: const [
                        Text("View All"),
                        Icon(LucideIcons.chevronRight, size: 16),
                      ],
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 16),
            ListView.builder(
              itemCount: tasks.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                 final task = tasks[index];
                 final bool isCompleted = task['completed'] as bool;
                return _buildAnimatedWidget(
                  _buildGlowContainer(
                    Card(
                      color: isCompleted ? AppTheme.chart2.withAlpha(51) : AppTheme.card,
                      child: ListTile(
                        leading: Icon(
                          isCompleted ? LucideIcons.checkCircle2 : LucideIcons.circle,
                          color: isCompleted ? AppTheme.chart2 : AppTheme.mutedForeground,
                        ),
                        title: Text(
                          task['task'] as String,
                          style: TextStyle(
                            decoration: isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                            color: isCompleted ? AppTheme.mutedForeground : AppTheme.onSurface
                          ),
                        ),
                        subtitle: Text(task['time'] as String, style: TextStyle(color: AppTheme.mutedForeground)),
                      ),
                    ),
                    glowColor: isCompleted ? AppTheme.chart2 : AppTheme.primary,
                  ),
                  intervalStart: 0.9 + (index * 0.05),
                  intervalEnd: 1.0,
                );
              },
            )
          ],
        ),
        intervalStart: 0.9,
        intervalEnd: 1.0
     );
  }
}
