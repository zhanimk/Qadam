import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/app_theme.dart';

class FinanceScreen extends StatefulWidget {
  final VoidCallback onBack;

  const FinanceScreen({Key? key, required this.onBack}) : super(key: key);

  @override
  _FinanceScreenState createState() => _FinanceScreenState();
}

class _FinanceScreenState extends State<FinanceScreen> with TickerProviderStateMixin {
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
    final chartData = [
      const FlSpot(0, 50000), const FlSpot(1, 55000), const FlSpot(2, 52000),
      const FlSpot(3, 60000), const FlSpot(4, 58000), const FlSpot(5, 65000),
    ];
    final chartDataExpenses = [
      const FlSpot(0, 35000), const FlSpot(1, 38000), const FlSpot(2, 36000),
      const FlSpot(3, 40000), const FlSpot(4, 42000), const FlSpot(5, 45000),
    ];

    final financialGoals = [
      {'name': "Vacation Savings", 'target': 150000.0, 'current': 87000.0, 'color': AppTheme.chart2},
      {'name': "Emergency Fund", 'target': 300000.0, 'current': 180000.0, 'color': AppTheme.chart3},
      {'name': "New Gadget", 'target': 80000.0, 'current': 65000.0, 'color': AppTheme.chart1},
    ];

    final recentTransactions = [
      {'type': "income", 'name': "Salary", 'amount': 65000.0, 'date': "Oct 20", 'category': "Income"},
      {'type': "expense", 'name': "Groceries", 'amount': -5200.0, 'date': "Oct 19", 'category': "Food"},
      {'type': "expense", 'name': "Fitness", 'amount': -3500.0, 'date': "Oct 18", 'category': "Health"},
      {'type': "income", 'name': "Freelance", 'amount': 15000.0, 'date': "Oct 17", 'category': "Income"},
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
              _buildAnimatedWidget(
                _buildBalanceOverview(context),
                intervalStart: 0.1, intervalEnd: 0.5,
              ),
              const SizedBox(height: 16),
              _buildAnimatedWidget(
                _buildTotalBalance(context),
                intervalStart: 0.2, intervalEnd: 0.6,
              ),
              const SizedBox(height: 24),
              _buildAnimatedWidget(
                _buildChartCard(context, chartData, chartDataExpenses),
                intervalStart: 0.3, intervalEnd: 0.7,
              ),
              const SizedBox(height: 24),
              _buildFinancialGoals(context, financialGoals),
              const SizedBox(height: 24),
              _buildRecentTransactions(context, recentTransactions),
              const SizedBox(height: 24),
              _buildAnimatedWidget(
                _buildEducationalContent(context),
                intervalStart: 0.7, intervalEnd: 1.0,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return _buildAnimatedWidget(
      Row(
        children: [
          IconButton(
            icon: const Icon(LucideIcons.arrowLeft, color: AppTheme.onSurface),
            onPressed: widget.onBack,
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Financial Literacy", style: AppTheme.textTheme.headlineSmall),
              Text("Manage your finances", style: AppTheme.textTheme.bodyMedium?.copyWith(color: AppTheme.mutedForeground)),
            ],
          ),
        ],
      ),
      intervalStart: 0.0, intervalEnd: 0.4,
    );
  }

  Widget _buildBalanceOverview(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildGlowContainer(
            Card(
              color: AppTheme.chart3.withAlpha(150),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(children: [Icon(LucideIcons.arrowUpRight, size: 16), SizedBox(width: 8), Text("Income")]),
                    const SizedBox(height: 8),
                    Text("₸65,000", style: AppTheme.textTheme.headlineSmall),
                    const SizedBox(height: 4),
                    Text("+8% from last month", style: AppTheme.textTheme.bodySmall),
                  ],
                ),
              ),
            ),
            glowColor: AppTheme.chart3,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildGlowContainer(
            Card(
              color: AppTheme.destructive.withAlpha(150),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(children: [Icon(LucideIcons.arrowDownRight, size: 16), SizedBox(width: 8), Text("Expenses")]),
                    const SizedBox(height: 8),
                    Text("₸45,000", style: AppTheme.textTheme.headlineSmall),
                    const SizedBox(height: 4),
                    Text("-5% from last month", style: AppTheme.textTheme.bodySmall),
                  ],
                ),
              ),
            ),
            glowColor: AppTheme.destructive,
          ),
        ),
      ],
    );
  }

  Widget _buildTotalBalance(BuildContext context) {
    return _buildGlowContainer(
      Card(
        color: AppTheme.primary,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Total Balance", style: AppTheme.textTheme.titleMedium),
                      Text("₸250,000", style: AppTheme.textTheme.displaySmall),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.white.withAlpha(51), borderRadius: BorderRadius.circular(16)),
                    child: const Icon(LucideIcons.wallet, size: 32),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(LucideIcons.trendingUp, color: Colors.greenAccent.shade400, size: 16),
                  const SizedBox(width: 8),
                  Text("+15% this month", style: AppTheme.textTheme.bodyMedium?.copyWith(color: Colors.greenAccent.shade400)),
                ],
              )
            ],
          ),
        ),
      ),
      glowColor: AppTheme.primary,
    );
  }

  Widget _buildChartCard(BuildContext context, List<FlSpot> income, List<FlSpot> expenses) {
    Widget bottomTitleWidgets(double value, TitleMeta meta) {
      const style = TextStyle(color: AppTheme.mutedForeground, fontSize: 12);
      Widget text;
      switch (value.toInt()) {
        case 0: text = const Text('Jan', style: style); break;
        case 1: text = const Text('Feb', style: style); break;
        case 2: text = const Text('Mar', style: style); break;
        case 3: text = const Text('Apr', style: style); break;
        case 4: text = const Text('May', style: style); break;
        case 5: text = const Text('Jun', style: style); break;
        default: text = const Text('', style: style); break;
      }
      return text;
    }

    return _buildGlowContainer(
      Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Financial Dynamics", style: AppTheme.textTheme.titleLarge),
              const SizedBox(height: 24),
              SizedBox(
                height: 200,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: true,
                      getDrawingHorizontalLine: (value) => const FlLine(color: AppTheme.border, strokeWidth: 0.5),
                      getDrawingVerticalLine: (value) => const FlLine(color: AppTheme.border, strokeWidth: 0.5),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30, interval: 1, getTitlesWidget: bottomTitleWidgets)),
                      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      _buildLineChartBarData(income, AppTheme.chart3),
                      _buildLineChartBarData(expenses, AppTheme.destructive, isExpense: true),
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

  LineChartBarData _buildLineChartBarData(List<FlSpot> spots, Color color, {bool isExpense = false}) {
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      color: color,
      barWidth: 3,
      isStrokeCapRound: true,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(
        show: true,
        gradient: LinearGradient(
          colors: [color.withAlpha(77), color.withAlpha(0)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }

  Widget _buildFinancialGoals(BuildContext context, List<Map<String, dynamic>> goals) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildAnimatedWidget(
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Financial Goals", style: AppTheme.textTheme.titleLarge),
              ElevatedButton.icon(
                icon: const Icon(LucideIcons.plus, size: 16),
                label: const Text("Add New"),
                onPressed: () {},
              ),
            ],
          ),
          intervalStart: 0.4, intervalEnd: 0.8,
        ),
        const SizedBox(height: 16),
        ...goals.asMap().entries.map((entry) {
          final index = entry.key;
          final goal = entry.value;
          final progress = (goal['current'] as double) / (goal['target'] as double);
          return _buildAnimatedWidget(
            _buildGlowContainer(
              Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8), 
                            decoration: BoxDecoration(color: goal['color'] as Color, borderRadius: BorderRadius.circular(8)), 
                            child: const Icon(LucideIcons.target, color: Colors.white, size: 20),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(goal['name'] as String, style: AppTheme.textTheme.titleMedium),
                                Text("₸${(goal['current'] as double).toInt()} / ₸${(goal['target'] as double).toInt()}", style: AppTheme.textTheme.bodySmall?.copyWith(color: AppTheme.mutedForeground)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(4),
                        backgroundColor: AppTheme.muted,
                        valueColor: AlwaysStoppedAnimation<Color>(goal['color'] as Color),
                      ),
                      const SizedBox(height: 8),
                      Align(alignment: Alignment.centerRight, child: Text("${(progress * 100).toInt()}%", style: AppTheme.textTheme.bodySmall?.copyWith(color: AppTheme.mutedForeground)))
                    ],
                  ),
                ),
              ),
              glowColor: goal['color'] as Color,
            ),
            intervalStart: 0.5 + (index * 0.1), intervalEnd: 0.9 + (index * 0.1),
          );
        })
      ],
    );
  }

  Widget _buildRecentTransactions(BuildContext context, List<Map<String, dynamic>> transactions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildAnimatedWidget(
          Text("Recent Transactions", style: AppTheme.textTheme.titleLarge),
          intervalStart: 0.6, intervalEnd: 1.0,
        ),
        const SizedBox(height: 16),
        ...transactions.asMap().entries.map((entry) {
          final index = entry.key;
          final transaction = entry.value;
          final isIncome = transaction['type'] == "income";
          final color = isIncome ? AppTheme.chart3 : AppTheme.destructive;

          return _buildAnimatedWidget(
            _buildGlowContainer(
              Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: color.withAlpha(30), borderRadius: BorderRadius.circular(10)),
                        child: Icon(LucideIcons.dollarSign, color: color, size: 20),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(transaction['name'] as String, style: AppTheme.textTheme.titleMedium),
                            Text("${transaction['category']} • ${transaction['date']}", style: AppTheme.textTheme.bodySmall?.copyWith(color: AppTheme.mutedForeground)),
                          ],
                        ),
                      ),
                      Text(
                        "${isIncome ? '+' : ''}₸${(transaction['amount'] as double).abs().toInt()}",
                        style: AppTheme.textTheme.titleMedium?.copyWith(color: color, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              glowColor: color,
            ),
            intervalStart: 0.7 + (index * 0.05), intervalEnd: 1.0,
          );
        }),
      ],
    );
  }

  Widget _buildEducationalContent(BuildContext context) {
    return _buildGlowContainer(
      Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8), 
                    decoration: BoxDecoration(color: AppTheme.chart4.withAlpha(50), borderRadius: BorderRadius.circular(8)), 
                    child: Icon(LucideIcons.piggyBank, color: AppTheme.chart4, size: 20),
                  ),
                  const SizedBox(width: 16),
                  Text("Financial Tip of the Day", style: AppTheme.textTheme.titleLarge),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                "The 50/30/20 Rule: Allocate your income - 50% for needs, 30% for wants, and 20% for savings.", 
                style: AppTheme.textTheme.bodyMedium?.copyWith(color: AppTheme.mutedForeground)
              ),
              const SizedBox(height: 16),
              OutlinedButton(onPressed: (){}, child: const Text("Learn More"), style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 48)))
            ],
          ),
        ),
      ),
      glowColor: AppTheme.chart4,
    );
  }
}
