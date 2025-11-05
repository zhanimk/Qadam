
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:qadam/theme/app_theme.dart';

class ProgressPage extends StatelessWidget {
  const ProgressPage({Key? key}) : super(key: key);

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
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: AnimationLimiter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: AnimationConfiguration.toStaggeredList(
                duration: const Duration(milliseconds: 375),
                childAnimationBuilder: (widget) => SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                    child: widget,
                  ),
                ),
                children: [
                  const Header(),
                  const SizedBox(height: 24),
                  _buildGlowContainer(
                    const OverallScore(),
                    glowColor: AppTheme.primary,
                  ),
                  const SizedBox(height: 24),
                  const KeyMetrics(),
                  const SizedBox(height: 24),
                  _buildGlowContainer(
                    const ProgressChart(),
                    glowColor: AppTheme.primary,
                  ),
                  const SizedBox(height: 24),
                  _buildGlowContainer(
                    const CategoryRadar(),
                    glowColor: AppTheme.primary,
                  ),
                  const SizedBox(height: 24),
                  _buildGlowContainer(
                    const WeeklyActivity(),
                    glowColor: AppTheme.primary,
                  ),
                  const SizedBox(height: 24),
                  _buildGlowContainer(
                    const StreakCalendar(),
                    glowColor: AppTheme.primary,
                  ),
                  const SizedBox(height: 24),
                  _buildGlowContainer(
                    const Insights(),
                    glowColor: AppTheme.chart3,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class Header extends StatelessWidget {
  const Header({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Progress & Analytics',
          style: AppTheme.textTheme.headlineSmall?.copyWith(color: AppTheme.onSurface),
        ),
        Text(
          'Track your achievements',
          style: AppTheme.textTheme.bodyMedium?.copyWith(color: AppTheme.mutedForeground),
        ),
      ],
    );
  }
}

class OverallScore extends StatelessWidget {
  const OverallScore({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [AppTheme.primary, AppTheme.secondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            children: [
              Text('Overall Development Score', style: AppTheme.textTheme.bodyMedium?.copyWith(color: AppTheme.primaryForeground.withAlpha(230))),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text('78', style: AppTheme.textTheme.displayMedium?.copyWith(color: AppTheme.primaryForeground)),
                  const SizedBox(width: 8),
                  const Row(
                    children: [
                      Icon(LucideIcons.arrowUp, color: Colors.greenAccent, size: 24),
                      Text('+6', style: TextStyle(color: Colors.greenAccent, fontSize: 24, fontWeight: FontWeight.bold)),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 4),
              Text('in the last month', style: AppTheme.textTheme.bodyMedium?.copyWith(color: AppTheme.primaryForeground.withAlpha(230))),
            ],
          ),
        ),
      ),
    );
  }
}

class KeyMetrics extends StatelessWidget {
  const KeyMetrics({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final metrics = [
      {"label": "Current Level", "value": "47", "change": "+5", "trend": "up", "icon": LucideIcons.trendingUp},
      {"label": "Streak Days", "value": "24", "change": "+1", "trend": "up", "icon": LucideIcons.calendar},
      {"label": "Tasks Completed", "value": "156", "change": "+12", "trend": "up", "icon": LucideIcons.target},
      {"label": "XP Earned", "value": "4,230", "change": "+180", "trend": "up", "icon": LucideIcons.award},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2, // Changed from 1.5 to 1.2 to increase height
      ),
      itemCount: metrics.length,
      itemBuilder: (context, index) {
        final metric = metrics[index];
        return Card(
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(metric["icon"] as IconData, color: AppTheme.primary, size: 24),
                const Spacer(),
                Text(metric["value"] as String, style: AppTheme.textTheme.headlineSmall?.copyWith(color: AppTheme.onSurface)),
                const SizedBox(height: 4),
                Text(metric["label"] as String, style: AppTheme.textTheme.bodySmall?.copyWith(color: AppTheme.mutedForeground)),
                 const SizedBox(height: 4),
                Row(
                  children: [
                     const Icon(LucideIcons.arrowUp, color: Colors.green, size: 12),
                     const SizedBox(width: 4),
                     Text('${metric["change"]} in a week', style: AppTheme.textTheme.bodySmall?.copyWith(color: Colors.green, fontSize: 10)),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
}

class ProgressChart extends StatelessWidget {
  const ProgressChart({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final overallProgress = [
      {"month": "Jan", "score": 45.0},
      {"month": "Feb", "score": 52.0},
      {"month": "Mar", "score": 58.0},
      {"month": "Apr", "score": 65.0},
      {"month": "May", "score": 72.0},
      {"month": "Jun", "score": 78.0},
    ];

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Development Dynamics', style: AppTheme.textTheme.titleLarge),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true, drawVerticalLine: true, getDrawingHorizontalLine: (value) => FlLine(color: AppTheme.border, strokeWidth: 1), getDrawingVerticalLine: (value) => FlLine(color: AppTheme.border, strokeWidth: 1)),
                  titlesData: FlTitlesData(
                      show: true, 
                      bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 22, getTitlesWidget: (value, meta) => Text(overallProgress[value.toInt()]['month'] as String, style: AppTheme.textTheme.bodySmall?.copyWith(color: AppTheme.mutedForeground)))),
                      leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40, getTitlesWidget: (value, meta) => Text(value.toStringAsFixed(0), style: AppTheme.textTheme.bodySmall?.copyWith(color: AppTheme.mutedForeground)))),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: overallProgress.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value['score'] as double)).toList(),
                      isCurved: true,
                      color: AppTheme.primary,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(show: true, color: AppTheme.primary.withAlpha(51)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryRadar extends StatelessWidget {
  const CategoryRadar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
     final categoryProgress = [
      {"category": "Psychology", "value": 75.0},
      {"category": "Finance", "value": 65.0},
      {"category": "Health", "value": 85.0},
      {"category": "Intellect", "value": 70.0},
      {"category": "Time Management", "value": 60.0},
    ];

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Progress by Category', style: AppTheme.textTheme.titleLarge),
            const SizedBox(height: 24),
            SizedBox(
              height: 300,
              child: RadarChart(
                RadarChartData(
                  dataSets: [
                    RadarDataSet(
                      dataEntries: categoryProgress.map((data) => RadarEntry(value: data['value'] as double)).toList(),
                      borderColor: AppTheme.primary,
                      fillColor: AppTheme.primary.withAlpha(128),
                      borderWidth: 2,
                    )
                  ],
                  getTitle: (index, angle) => RadarChartTitle(text: categoryProgress[index]['category'] as String, angle: angle),
                  tickCount: 5,
                  ticksTextStyle: const TextStyle(color: Colors.transparent, fontSize: 10),
                  tickBorderData: const BorderSide(color: Colors.transparent),
                   gridBorderData: const BorderSide(color: AppTheme.border, width: 1),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WeeklyActivity extends StatelessWidget {
  const WeeklyActivity({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final weeklyStats = [
      {"day": "Mon", "completed": 8, "total": 10},
      {"day": "Tue", "completed": 7, "total": 8},
      {"day": "Wed", "completed": 9, "total": 12},
      {"day": "Thu", "completed": 6, "total": 9},
      {"day": "Fri", "completed": 10, "total": 10},
      {"day": "Sat", "completed": 5, "total": 6},
      {"day": "Sun", "completed": 4, "total": 5},
    ];

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Weekly Activity', style: AppTheme.textTheme.titleLarge),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: weeklyStats.map((day) {
                final completionRate = (day["completed"] as int) / (day["total"] as int);
                return Column(
                  children: [
                    Text(day["day"] as String, style: AppTheme.textTheme.bodySmall?.copyWith(color: AppTheme.mutedForeground)),
                    const SizedBox(height: 8),
                    Container(
                      height: 120,
                      width: 30,
                      decoration: BoxDecoration(color: AppTheme.muted, borderRadius: BorderRadius.circular(8)),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          height: 120 * completionRate,
                          decoration: BoxDecoration(
                            color: AppTheme.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('${day["completed"]}/${day["total"]}', style: AppTheme.textTheme.bodySmall?.copyWith(color: AppTheme.mutedForeground, fontSize: 10)),
                  ],
                );
              }).toList(),
            )
          ],
        ),
      ),
    );
  }
}

class StreakCalendar extends StatelessWidget {
  const StreakCalendar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Activity Calendar', style: AppTheme.textTheme.titleLarge),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, crossAxisSpacing: 8, mainAxisSpacing: 8),
              itemCount: 35,
              itemBuilder: (context, index) {
                // Dummy data
                final isActive = (index % 3 != 0);
                final intensity = (index % 5) / 4.0;
                return Container(
                  decoration: BoxDecoration(
                    color: isActive ? AppTheme.primary.withAlpha((intensity * 255).toInt()) : AppTheme.muted,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              },
            ),
             const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Less', style: AppTheme.textTheme.bodySmall?.copyWith(color: AppTheme.mutedForeground)),
                Row(
                  children: List.generate(4, (index) => Container(width: 12, height: 12, margin: const EdgeInsets.symmetric(horizontal: 2), decoration: BoxDecoration(color: AppTheme.primary.withAlpha(((index + 1) * 0.25 * 255).toInt()), borderRadius: BorderRadius.circular(2)))),
                ),
                Text('More', style: AppTheme.textTheme.bodySmall?.copyWith(color: AppTheme.mutedForeground)),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class Insights extends StatelessWidget {
  const Insights({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [AppTheme.chart3, AppTheme.chart2],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppTheme.onSurface.withAlpha(51), borderRadius: BorderRadius.circular(12)), child: const Icon(LucideIcons.activity, color: AppTheme.onSurface, size: 32)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Your Achievements', style: AppTheme.textTheme.titleLarge?.copyWith(color: AppTheme.onSurface)),
                  const SizedBox(height: 8),
                  Text('You are 25% more productive than last month! Health shows the best results.', style: AppTheme.textTheme.bodyMedium?.copyWith(color: AppTheme.onSurface.withAlpha(230))),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text('More details'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.onSurface.withAlpha(51),
                      foregroundColor: AppTheme.onSurface,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
