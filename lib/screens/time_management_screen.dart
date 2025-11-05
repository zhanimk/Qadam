import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_theme.dart';
import '../widgets/pomodoro_timer.dart';
import '../widgets/weekly_calendar.dart';
import '../widgets/daily_planner.dart';

class TimeManagementPage extends StatefulWidget {
  final VoidCallback onBack;

  const TimeManagementPage({Key? key, required this.onBack}) : super(key: key);

  @override
  _TimeManagementPageState createState() => _TimeManagementPageState();
}

class _TimeManagementPageState extends State<TimeManagementPage> with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _animationController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAnimatedWidget(
                _buildHeader(),
                intervalStart: 0.0, intervalEnd: 0.4,
              ),
              const SizedBox(height: 24),
              _buildAnimatedWidget(
                _buildQuickStats(),
                intervalStart: 0.1, intervalEnd: 0.6,
              ),
              const SizedBox(height: 24),
              _buildAnimatedWidget(
                _buildTabs(),
                intervalStart: 0.2, intervalEnd: 0.7,
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.7,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildPomodoroContent(),
                    const WeeklyCalendar(),
                    const DailyPlanner(),
                    _buildStatsContent(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: widget.onBack,
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Time Management", style: AppTheme.textTheme.headlineSmall),
            Text("Maximize your productivity", style: AppTheme.textTheme.bodyMedium?.copyWith(color: AppTheme.mutedForeground)),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickStats() {
    final stats = [
      { "label": "Focus Time", "value": "5.2h", "change": "+12%", "color": [AppTheme.primary, AppTheme.accent] },
      { "label": "Tasks Done", "value": "24", "change": "+8%", "color": [AppTheme.chart3, AppTheme.chart2] },
      { "label": "Productivity", "value": "87%", "change": "+5%", "color": [AppTheme.chart4, AppTheme.chart5] },
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(stats.length, (index) {
        final stat = stats[index];
        final colors = stat["color"] as List<Color>;
        return Expanded(
          child: _buildGlowContainer(
             Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(stat["value"] as String, style: AppTheme.textTheme.headlineSmall),
                      const SizedBox(height: 4),
                      Text(stat["label"] as String, style: AppTheme.textTheme.bodySmall?.copyWith(color: AppTheme.mutedForeground)),
                      const SizedBox(height: 4),
                      Text(stat["change"] as String, style: AppTheme.textTheme.bodySmall?.copyWith(color: AppTheme.chart3)),
                    ],
                  ),
                ),
              ),
            glowColor: colors[0],
          ),
        );
      }),
    );
  }

  Widget _buildTabs() {
    return TabBar(
      controller: _tabController,
      tabs: const [
        Tab(icon: Icon(LucideIcons.timer), text: "Timer"),
        Tab(icon: Icon(LucideIcons.calendar), text: "Week"),
        Tab(icon: Icon(LucideIcons.listTodo), text: "Tasks"),
        Tab(icon: Icon(LucideIcons.barChart3), text: "Stats"),
      ],
    );
  }

  Widget _buildPomodoroContent() {
    final tips = [
      { "step": "1", "text": "Choose a task to work on" },
      { "step": "2", "text": "Set timer for 25 minutes" },
      { "step": "3", "text": "Work until timer rings" },
      { "step": "4", "text": "Take a 5 minute break" },
      { "step": "5", "text": "After 4 sessions, take 15-30 min break" },
    ];
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildAnimatedWidget(
            const PomodoroTimer(),
            intervalStart: 0.3, intervalEnd: 0.8,
          ),
          const SizedBox(height: 24),
          _buildAnimatedWidget(
            _buildGlowContainer(
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Pomodoro Technique", style: AppTheme.textTheme.titleLarge),
                      const SizedBox(height: 16),
                      ...tips.map((tip) => Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 12,
                              backgroundColor: AppTheme.primary,
                              child: Text(tip["step"] as String, style: const TextStyle(color: Colors.white, fontSize: 12)),
                            ),
                            const SizedBox(width: 16),
                            Expanded(child: Text(tip["text"] as String)),
                          ],
                        ),
                      )),
                    ],
                  ),
                ),
              ),
            ),
             intervalStart: 0.4, intervalEnd: 0.9,
          ),
        ],
      ),
    );
  }

  Widget _buildStatsContent() {
    final timeDistribution = [
      { "category": "Deep Work", "hours": 18, "total": 40, "color": [AppTheme.primary, AppTheme.accent] },
      { "category": "Meetings", "hours": 8, "total": 40, "color": [AppTheme.chart4, AppTheme.chart5] },
      { "category": "Learning", "hours": 6, "total": 40, "color": [AppTheme.chart3, AppTheme.chart2] },
      { "category": "Breaks", "hours": 5, "total": 40, "color": [AppTheme.chart1, AppTheme.chart2] },
      { "category": "Other", "hours": 3, "total": 40, "color": [AppTheme.muted, AppTheme.mutedForeground] },
    ];

    final productivity = [
      { "day": "Mon", "score": 85 },
      { "day": "Tue", "score": 92 },
      { "day": "Wed", "score": 78 },
      { "day": "Thu", "score": 95 },
      { "day": "Fri", "score": 88 },
      { "day": "Sat", "score": 70 },
      { "day": "Sun", "score": 82 },
    ];
    
    final peakTimes = [
      { "period": "Morning (9-11 AM)", "productivity": "Very High", "icon": "🌅" },
      { "period": "Afternoon (2-4 PM)", "productivity": "High", "icon": "☀️" },
      { "period": "Evening (7-9 PM)", "productivity": "Medium", "icon": "🌆" },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAnimatedWidget(
             _buildGlowContainer(
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Time Distribution (This Week)", style: AppTheme.textTheme.titleLarge),
                        const SizedBox(height: 16),
                        ...timeDistribution.map((item) {
                          final percentage = (item["hours"] as int) / (item["total"] as int);
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(item["category"] as String),
                                    Text("${item["hours"]}h"),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                LinearProgressIndicator(
                                  value: percentage.toDouble(),
                                  backgroundColor: AppTheme.muted,
                                  valueColor: AlwaysStoppedAnimation<Color>((item["color"] as List<Color>)[0]),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ),
              intervalStart: 0.3, intervalEnd: 0.8,
          ),
          const SizedBox(height: 24),
          _buildAnimatedWidget(
            _buildGlowContainer(
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Productivity Score", style: AppTheme.textTheme.titleLarge),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 150,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: productivity.map((item) {
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                 Flexible(
                                   child: FractionallySizedBox(
                                    heightFactor: (item['score'] as int) / 100.0,
                                    child: Container(
                                      width: 20,
                                      decoration: BoxDecoration(
                                        color: AppTheme.primary,
                                        borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                                      ),
                                    ),
                                ),
                                 ),
                                const SizedBox(height: 8),
                                Text(item['day'] as String),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
               glowColor: AppTheme.primary,
            ),
             intervalStart: 0.4, intervalEnd: 0.9,
          ),
          const SizedBox(height: 24),
           _buildAnimatedWidget(
              _buildGlowContainer(
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Your Peak Performance Times", style: AppTheme.textTheme.titleLarge),
                        const SizedBox(height: 16),
                        ...peakTimes.map((time) => ListTile(
                              leading: Text(time['icon'] as String, style: const TextStyle(fontSize: 24)),
                              title: Text(time['period'] as String),
                              subtitle: Text(time['productivity'] as String),
                            )),
                      ],
                    ),
                  ),
                ),
              ),
               intervalStart: 0.5, intervalEnd: 1.0,
           ),
        ],
      ),
    );
  }
}
