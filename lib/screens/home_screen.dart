import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:qadam/screens/ai_coach_screen.dart';
import 'package:qadam/screens/health_screen.dart';
import 'package:qadam/screens/intellect_screen.dart';
import 'package:qadam/screens/psychology_screen.dart';
import 'package:qadam/screens/time_management_screen.dart';
import 'package:qadam/services/firestore_service.dart';
import 'package:qadam/theme/app_theme.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:qadam/utils/string_extension.dart';

class HomeScreen extends StatefulWidget {
  final void Function(int) onNavigate;

  const HomeScreen({Key? key, required this.onNavigate}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final FirestoreService _firestoreService = FirestoreService();
  late AnimationController _auroraController;
  late AnimationController _staggeredController;
  final GlobalKey _analyticsKey = GlobalKey();

  final Map<String, IconData> _moods = {
    'Happy': LucideIcons.smile,
    'Calm': LucideIcons.meh,
    'Productive': LucideIcons.brainCircuit,
    'Sad': LucideIcons.frown,
    'Tired': LucideIcons.battery,
  };

  @override
  void initState() {
    super.initState();
    _firestoreService.initUserData();

    _auroraController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat(reverse: true);

    _staggeredController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
  }

  @override
  void dispose() {
    _auroraController.dispose();
    _staggeredController.dispose();
    super.dispose();
  }

  Widget _buildAnimatedChild(Widget child, {required double start, double? duration}) {
    return AnimatedBuilder(
      animation: _staggeredController,
      child: child,
      builder: (context, child) {
        final curve = CurvedAnimation(
          parent: _staggeredController,
          curve: Interval(start, (start + (duration ?? 0.5)).clamp(0.0, 1.0), curve: Curves.easeOutCubic),
        );
        return FadeTransition(
          opacity: curve,
          child: Transform.translate(
            offset: Offset(0, (1.0 - curve.value) * 50),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080812), // Darker background
      body: Stack(
        children: [
          _buildAuroraBackground(),
          StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: _firestoreService.getUserDataStream(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting && !userSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final userData = userSnapshot.data?.data() ?? {};
              final dailyProgress = userData['dailyProgress'] as Map<String, dynamic>? ?? {};

              return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: _firestoreService.getGoalsStream(),
                builder: (context, goalsSnapshot) {
                  final goals = goalsSnapshot.data?.docs ?? [];
                  final completedGoals = goals.where((g) => (g.data()['isCompleted'] ?? false) == true).length;
                  final totalGoals = goals.length;
                  final double overallProgress = totalGoals > 0 ? completedGoals / totalGoals : 0.0;

                  return _buildContent(userData, dailyProgress, overallProgress, completedGoals, totalGoals);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAuroraBackground() {
    return AnimatedBuilder(
      animation: _auroraController,
      builder: (context, child) {
        return Stack(
          children: [
            Container(color: const Color(0xFF080812)),
            _buildAuroraBlob(color: AppTheme.primary.withAlpha(77), alignment: Alignment(-1.5 + (_auroraController.value * 1.0), -0.9), height: 400),
            _buildAuroraBlob(color: AppTheme.accent.withAlpha(102), alignment: Alignment(1.5 - (_auroraController.value * 0.5), 0.2), height: 500),
            _buildAuroraBlob(color: AppTheme.chart4.withAlpha(89), alignment: Alignment(-0.5 + (_auroraController.value * -1.0), 1.2), height: 450),
          ],
        );
      },
    );
  }

  Widget _buildAuroraBlob({required Color color, required Alignment alignment, required double height}) {
    return Align(
      alignment: alignment,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: color.withAlpha(128), blurRadius: 100, spreadRadius: 50)],
        ),
      ),
    );
  }

  Widget _buildContent(Map<String, dynamic> userData, Map<String, dynamic> dailyProgress, double overallProgress, int completedGoals, int totalGoals) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  _buildAnimatedChild(_buildHeader(userData), start: 0.0, duration: 0.4),
                  const SizedBox(height: 32),
                  _buildAnimatedChild(_buildMoodTracker(dailyProgress['mood']), start: 0.1, duration: 0.5),
                  const SizedBox(height: 32),
                  _buildAnimatedChild(_buildDailyProgress(dailyProgress, userData), start: 0.3, duration: 0.5),
                  const SizedBox(height: 32),
                ],
              ),
            ),
            _buildAnimatedChild(
              _buildQuickActions(),
              start: 0.5, duration: 0.5
            ),
            Padding(
               padding: const EdgeInsets.all(24.0),
               key: _analyticsKey,
               child: _buildAnimatedChild(
                _buildOverallProgress(dailyProgress, overallProgress, completedGoals, totalGoals),
                start: 0.7, duration: 0.5
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Map<String, dynamic> userData) {
    final user = FirebaseAuth.instance.currentUser;
    final displayName = userData['displayName'] ?? user?.displayName ?? "Zhanimk";
    final photoUrl = user?.photoURL;

    return Row(
      children: [
        CircleAvatar(
          radius: 26,
          backgroundColor: AppTheme.accent.withAlpha(128),
          child: CircleAvatar(
            radius: 23,
            backgroundImage: (photoUrl != null) ? NetworkImage(photoUrl) : null,
            backgroundColor: AppTheme.surface,
              child: (photoUrl == null)
              ? Text(displayName.isNotEmpty ? displayName[0].toUpperCase() : 'Z', style: const TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold))
              : null,
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Welcome back,", style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppTheme.mutedForeground)),
            Text(displayName, style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppTheme.onSurface, fontWeight: FontWeight.bold)),
          ],
        ),
        const Spacer(),
        IconButton(icon: const Icon(LucideIcons.bell, color: AppTheme.onSurface, size: 28), onPressed: () {}),
      ],
    );
  }
  
  Widget _buildMoodTracker(String? currentMood) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PsychologyScreen())),
          child: Text("How are you feeling?", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: _moods.entries.map((entry) {
            final moodName = entry.key;
            final moodIcon = entry.value;
            final isSelected = currentMood == moodName;

            return GestureDetector(
              onTap: () => _firestoreService.updateDailyProgress('mood', moodName),
              child: _buildGlowContainer(
                color: isSelected ? AppTheme.accent : Colors.transparent,
                borderRadius: 16,
                child: Container(
                   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                   decoration: BoxDecoration(
                     color: isSelected ? AppTheme.surface.withAlpha(220) : AppTheme.surface.withAlpha(50),
                     borderRadius: BorderRadius.circular(16),
                     border: isSelected ? Border.all(color: AppTheme.accent.withAlpha(200)) : Border.all(color: Colors.white.withAlpha(26)),
                   ),
                  child: Icon(moodIcon, color: isSelected ? AppTheme.accent : AppTheme.mutedForeground, size: 32)
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDailyProgress(Map<String, dynamic> dailyProgress, Map<String, dynamic> userData) {
    final goals = userData;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Your Daily Progress", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.3,
          children: [
             _StatCard(
              label: "Water Intake",
              value: (dailyProgress['waterIntake'] ?? 0).toString(),
              goal: "/ ${goals['waterIntakeGoal'] ?? 8} glasses",
              icon: LucideIcons.glassWater,
              color: AppTheme.chart1,
              onTap: () => _showUpdateValueSheet('waterIntake', dailyProgress['waterIntake'] ?? 0, isIncrement: true, incrementValue: 1),
            ),
            _StatCard(
              label: "Weight",
              value: (dailyProgress['currentWeight'] ?? 0).toString(),
              goal: "kg",
              icon: LucideIcons.activity,
              color: AppTheme.chart2,
              onTap: () => _showUpdateValueSheet('currentWeight', dailyProgress['currentWeight'] ?? 0),
            ),
             _StatCard(
              label: "Calories Burned",
              value: (dailyProgress['caloriesBurned'] ?? 0).toString(),
              goal: "/ ${goals['calorieGoal'] ?? 500} kcal",
              icon: LucideIcons.flame,
              color: AppTheme.chart4,
               onTap: () => _showUpdateValueSheet('caloriesBurned', dailyProgress['caloriesBurned'] ?? 0, isIncrement: true, incrementValue: 10),
            ),
            _StatCard(
              label: "Health",
              value: "Details",
              goal: "",
              icon: LucideIcons.heartPulse,
              color: AppTheme.chart3,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const HealthScreen())),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGlowContainer({required Widget child, required Color color, double borderRadius = 28}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(100),
            blurRadius: 25,
            spreadRadius: -8,
            offset: const Offset(0, 4)
          ),
        ],
      ),
      child: child,
    );
  }


  void _showUpdateValueSheet(String field, num currentValue, {bool isIncrement = false, num incrementValue = 10}) {
    final TextEditingController controller = TextEditingController(text: currentValue.toString());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: AppTheme.surface.withAlpha(204),
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(28), topRight: Radius.circular(28)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Update ${field.replaceAll(RegExp(r'(?<=[a-z])(?=[A-Z])'), ' ').capitalizeFirst()}", style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                if (isIncrement)
                  StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                    stream: _firestoreService.getUserDataStream(),
                    builder: (context, snapshot) {
                      num liveValue = currentValue;
                      if (snapshot.hasData && snapshot.data!.data()!.containsKey('dailyProgress')) {
                        final dailyProgress = snapshot.data!.data()!['dailyProgress'] as Map<String, dynamic>?;
                        if (dailyProgress != null && dailyProgress.containsKey(field)) {
                           liveValue = dailyProgress[field] ?? currentValue;
                        }
                      }
                      
                      return Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(icon: const Icon(LucideIcons.minusCircle, size: 40), onPressed: () => _firestoreService.incrementDailyProgress(field, -incrementValue)),
                            const SizedBox(width: 24),
                            Text(liveValue.toString(), style: Theme.of(context).textTheme.displayMedium?.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(width: 24),
                            IconButton(icon: const Icon(LucideIcons.plusCircle, size: 40, color: AppTheme.accent), onPressed: () => _firestoreService.incrementDailyProgress(field, incrementValue)),
                          ],
                        ),
                      );
                    }
                  )
                else
                  TextField(
                    controller: controller,
                    autofocus: true,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'New Value',
                      filled: true,
                      fillColor: AppTheme.surface.withAlpha(128),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    ),
                    onSubmitted: (value) {
                      final num? newValue = num.tryParse(value);
                      if (newValue != null) {
                         _firestoreService.updateDailyProgress(field, newValue);
                      }
                      Navigator.pop(context);
                    },
                  ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    child: const Text("Done"),
                    onPressed: () {
                      if (!isIncrement) {
                        final num? newValue = num.tryParse(controller.text);
                        if (newValue != null) {
                          _firestoreService.updateDailyProgress(field, newValue);
                        }
                      }
                      Navigator.pop(context);
                    },
                     style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: AppTheme.accent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
     final actions = [
      {'label': "Psychology", 'icon': LucideIcons.brain, 'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PsychologyScreen()))},
      {'label': "Time Mgmt", 'icon': LucideIcons.clock, 'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (context) => TimeManagementPage(onBack: () => Navigator.of(context).pop())))},
      {'label': "Self-dev", 'icon': LucideIcons.bookOpen, 'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (context) => IntellectPage(onBack: () => Navigator.of(context).pop())))},
      {'label': "AI Coach", 'icon': LucideIcons.messageCircle, 'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AICoachScreen()))},
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Text("Quick Actions", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 130,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            clipBehavior: Clip.none,
            scrollDirection: Axis.horizontal,
            itemCount: actions.length,
            itemBuilder: (context, index) {
              final action = actions[index];
              return Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: SizedBox(
                  width: 100,
                  child: _buildGlowContainer(
                    color: AppTheme.surface,
                    child: _buildGlassCard(
                      isTappable: true,
                      onTap: action['onTap'] as VoidCallback?,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(action['icon'] as IconData, size: 32, color: AppTheme.onSurface),
                          const SizedBox(height: 12),
                          Text(action['label'] as String, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.onSurface, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildOverallProgress(Map<String, dynamic> dailyProgress, double overallProgress, int completedGoals, int totalGoals) {
    return _buildGlowContainer(
      color: AppTheme.accent,
      child: _buildGlassCard(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                 Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Overall Progress", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                     Row(
                      children: [
                        Text("This week", style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.mutedForeground)),
                        const Icon(Icons.keyboard_arrow_down, color: AppTheme.mutedForeground, size: 20),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 24),
                CircularPercentIndicator(
                  radius: 85.0,
                  lineWidth: 14.0,
                  animation: true,
                  animationDuration: 1000,
                  percent: overallProgress,
                  center: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("${(overallProgress * 100).toInt()}%", style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold, color: AppTheme.onSurface, height: 1.1)),
                      Text("Completed", style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.mutedForeground)),
                    ],
                  ),
                  circularStrokeCap: CircularStrokeCap.round,
                  linearGradient: const LinearGradient(
                    colors: [AppTheme.accent, AppTheme.primary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  backgroundColor: AppTheme.surface.withAlpha(128),
                ),
                const SizedBox(height: 24),
                IntrinsicHeight(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildProgressStat(LucideIcons.flame, (dailyProgress['caloriesBurned'] ?? 0).toString(), "Kcal"),
                      const VerticalDivider(color: AppTheme.mutedForeground, indent: 8, endIndent: 8, thickness: 1),
                      _buildProgressStat(LucideIcons.target, "$completedGoals/$totalGoals", "Goals"),
                      const VerticalDivider(color: AppTheme.mutedForeground, indent: 8, endIndent: 8, thickness: 1),
                      _buildProgressStat(LucideIcons.clock, "${dailyProgress['focusHours'] ?? 0}h", "Focus"),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
    );
  }

  Widget _buildProgressStat(IconData icon, String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: AppTheme.mutedForeground, size: 22),
          const SizedBox(height: 8),
          Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.mutedForeground)),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String goal;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _StatCard({
    required this.label,
    required this.value,
    required this.goal,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _buildGlassCard(
      isTappable: true,
      onTap: onTap,
      borderRadius: 20,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, size: 28, color: color),
            const SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 Text(label, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 15)),
                 const SizedBox(height: 4),
                RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.mutedForeground),
                    children: [
                      TextSpan(text: value, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.onSurface, fontSize: 18)),
                      TextSpan(text: ' $goal', style: const TextStyle(fontSize: 12)),
                    ]
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildGlassCard({required Widget child, bool isTappable = false, double borderRadius = 28, VoidCallback? onTap}) {
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
