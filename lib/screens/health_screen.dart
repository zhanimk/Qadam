import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:qadam/theme/app_theme.dart';

// Helper function to build glow container
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

class HealthPage extends StatefulWidget {
  final VoidCallback onBack;

  const HealthPage({Key? key, required this.onBack}) : super(key: key);

  @override
  _HealthPageState createState() => _HealthPageState();
}

class _HealthPageState extends State<HealthPage> with TickerProviderStateMixin {
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
                const HeroStats(),
                 intervalStart: 0.1, intervalEnd: 0.5,
              ),
              const SizedBox(height: 24),
              _buildAnimatedWidget(
                const HealthMetrics(),
                 intervalStart: 0.2, intervalEnd: 0.7,
              ),
              const SizedBox(height: 24),
              _buildAnimatedWidget(
                const ActivityChart(),
                 intervalStart: 0.3, intervalEnd: 0.8,
              ),
              const SizedBox(height: 24),
              _buildAnimatedWidget(
                const Workouts(),
                 intervalStart: 0.4, intervalEnd: 0.9,
              ),
              const SizedBox(height: 24),
              _buildAnimatedWidget(
                const HealthTips(),
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
              'Health & Fitness',
              style: AppTheme.textTheme.headlineSmall,
            ),
            Text(
              'Track your activity',
              style: AppTheme.textTheme.bodyMedium?.copyWith(color: AppTheme.mutedForeground),
            ),
          ],
        ),
      ],
    );
  }
}

class HeroStats extends StatelessWidget {
  const HeroStats({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _buildGlowContainer(
      Card(
        color: Colors.transparent,
        elevation: 0,
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
                    'Activity Today',
                    style: AppTheme.textTheme.titleMedium?.copyWith(color: AppTheme.primaryForeground.withAlpha(230)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '85%',
                    style: AppTheme.textTheme.displayMedium?.copyWith(color: AppTheme.primaryForeground),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryForeground.withAlpha(51),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(LucideIcons.activity, color: AppTheme.primaryForeground, size: 32),
              ),
            ],
          ),
        ),
      ),
      glowColor: AppTheme.accent,
    );
  }
}

class HealthMetrics extends StatelessWidget {
  const HealthMetrics({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final healthMetrics = [
      {"icon": LucideIcons.footprints, "label": "Steps", "value": "12458", "target": "10000", "unit": "", "color": AppTheme.chart1},
      {"icon": LucideIcons.flame, "label": "Calories", "value": "650", "target": "500", "unit": "kcal", "color": AppTheme.chart5},
      {"icon": LucideIcons.droplet, "label": "Water", "value": "1.8", "target": "2.5", "unit": "L", "color": AppTheme.chart2},
      {"icon": LucideIcons.moon, "label": "Sleep", "value": "7.5", "target": "8", "unit": "h", "color": AppTheme.chart4},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.1,
      ),
      itemCount: healthMetrics.length,
      itemBuilder: (context, index) {
        final metric = healthMetrics[index];
        final progress = (double.parse(metric["value"] as String) / double.parse(metric["target"] as String));
        return _buildGlowContainer(
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (metric["color"] as Color).withAlpha(51),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(metric["icon"] as IconData, color: metric["color"] as Color, size: 20),
                  ),
                  const SizedBox(height: 8),
                  Text(metric["label"] as String, style: AppTheme.textTheme.bodyMedium?.copyWith(color: AppTheme.mutedForeground)),
                  Text('${metric["value"]} ${metric["unit"]}', style: AppTheme.textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       LinearProgressIndicator(
                        value: progress.clamp(0.0, 1.0),
                        backgroundColor: AppTheme.muted,
                        valueColor: AlwaysStoppedAnimation<Color>(metric["color"] as Color),
                      ),
                      const SizedBox(height: 4),
                      Text('Goal: ${metric["target"]} ${metric["unit"]}', style: AppTheme.textTheme.bodySmall?.copyWith(color: AppTheme.mutedForeground)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          glowColor: metric["color"] as Color,
        );
      },
    );
  }
}

class ActivityChart extends StatelessWidget {
  const ActivityChart({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final weekData = [
      {"day": "Mon", "steps": 8500.0},
      {"day": "Tue", "steps": 10200.0},
      {"day": "Wed", "steps": 7800.0},
      {"day": "Thu", "steps": 12500.0},
      {"day": "Fri", "steps": 9300.0},
      {"day": "Sat", "steps": 15000.0},
      {"day": "Sun", "steps": 6500.0},
    ];

    return _buildGlowContainer(
      Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Weekly Activity', style: AppTheme.textTheme.titleLarge),
              const SizedBox(height: 24),
              SizedBox(
                height: 200,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (value) {
                        return const FlLine(color: AppTheme.border, strokeWidth: 1);
                      },
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30, interval: 1, getTitlesWidget: (value, meta) => Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(weekData[value.toInt()]['day'] as String, style: AppTheme.textTheme.bodySmall?.copyWith(color: AppTheme.mutedForeground)),
                      ))),
                      leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40, getTitlesWidget: (value, meta) => Text((value/1000).toStringAsFixed(0) + 'k', style: AppTheme.textTheme.bodySmall?.copyWith(color: AppTheme.mutedForeground)))),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: weekData.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value['steps'] as double)).toList(),
                        isCurved: true,
                        color: AppTheme.primary,
                        barWidth: 4,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.primary.withAlpha(77),
                              AppTheme.primary.withAlpha(0),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          )
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Workouts extends StatelessWidget {
  const Workouts({Key? key}) : super(key: key);

  @override
Widget build(BuildContext context) {
    final workouts = [
      {"name": "Morning Yoga", "duration": "20 min", "calories": 150, "completed": true, "image": "https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?q=80&w=2120&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D"},
      {"name": "Strength Training", "duration": "45 min", "calories": 380, "completed": false, "image": "https://images.unsplash.com/photo-1599058917212-d750089bc07e?q=80&w=2069&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D"},
      {"name": "Cardio", "duration": "30 min", "calories": 250, "completed": false, "image": "https://images.unsplash.com/photo-1538805363940-22c7c5925348?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D"},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Today\'s Workouts', style: AppTheme.textTheme.titleLarge),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: workouts.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final workout = workouts[index];
            return _buildGlowContainer(
              Card(
                clipBehavior: Clip.antiAlias,
                child: Row(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.network(workout["image"] as String, width: 80, height: 80, fit: BoxFit.cover),
                        if (workout["completed"] as bool)
                          Container(
                            width: 80, height: 80,
                            color: Colors.black.withAlpha(153),
                            child: const Icon(LucideIcons.checkCircle, color: Colors.greenAccent, size: 32),
                          ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            workout["name"] as String,
                            style: AppTheme.textTheme.titleMedium?.copyWith(
                              decoration: (workout["completed"] as bool) ? TextDecoration.lineThrough : TextDecoration.none,
                              color: (workout["completed"] as bool) ? AppTheme.mutedForeground : AppTheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${workout["duration"]} • ${workout["calories"]} kcal',
                             style: AppTheme.textTheme.bodyMedium?.copyWith(color: AppTheme.mutedForeground),
                          ),
                        ],
                      ),
                    ),
                    if (!(workout["completed"] as bool))
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: IconButton(
                          icon: const Icon(LucideIcons.play, color: AppTheme.onSurface),
                          onPressed: () {},
                          style: IconButton.styleFrom(backgroundColor: AppTheme.primary),
                        ),
                      ),
                  ],
                ),
              ),
              glowColor: (workout["completed"] as bool) ? AppTheme.chart3 : AppTheme.primary,
            );
          },
        ),
      ],
    );
  }
}

class HealthTips extends StatelessWidget {
  const HealthTips({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _buildGlowContainer(
      Card(
        color: AppTheme.accent.withAlpha(26),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppTheme.accent)
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.accent.withAlpha(51),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(LucideIcons.sparkles, color: AppTheme.accent, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Text('Tip of the Day', style: AppTheme.textTheme.titleLarge),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Stay hydrated! Proper hydration helps improve focus and physical performance.',
                 style: AppTheme.textTheme.bodyMedium?.copyWith(color: AppTheme.mutedForeground),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {},
                child: const Text('More Tips'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accent,
                  foregroundColor: AppTheme.accentForeground,
                  minimumSize: const Size(double.infinity, 48),
                ),
              )
            ],
          ),
        ),
      ),
      glowColor: AppTheme.accent,
    );
  }
}
