import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:qadam/services/firestore_service.dart';
import '../theme/app_theme.dart';

class Achievement {
  final String id;
  final IconData icon;
  final String title;
  final String description;
  final String rarity;
  final int xp;
  bool isUnlocked;
  Timestamp? dateUnlocked;

  Achievement({
    required this.id,
    required this.icon,
    required this.title,
    required this.description,
    required this.rarity,
    required this.xp,
    this.isUnlocked = false,
    this.dateUnlocked,
  });
}

class AwardsScreen extends StatefulWidget {
  const AwardsScreen({Key? key}) : super(key: key);

  @override
  _AwardsScreenState createState() => _AwardsScreenState();
}

class _AwardsScreenState extends State<AwardsScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  final List<Achievement> allAchievements = [
    Achievement(id: 'first_goal', icon: LucideIcons.target, title: 'First Step', description: 'Create your first goal', rarity: 'Common', xp: 50),
    Achievement(id: 'first_task', icon: LucideIcons.checkCircle, title: 'Task Initiator', description: 'Create your first task', rarity: 'Common', xp: 50),
    Achievement(id: 'task_master', icon: LucideIcons.user, title: 'Productivity Guru', description: 'Complete 10 tasks', rarity: 'Uncommon', xp: 300),
    Achievement(id: 'week_of_strength', icon: LucideIcons.flame, title: 'Week of Strength', description: 'Maintain a 7-day streak', rarity: 'Common', xp: 100),
    Achievement(id: '30_day_marathon', icon: LucideIcons.flame, title: '30-Day Marathon', description: 'Maintain a 30-day streak', rarity: 'Rare', xp: 500),
    Achievement(id: 'bookworm', icon: LucideIcons.book, title: 'Bookworm', description: 'Read 10 books', rarity: 'Uncommon', xp: 200),
    Achievement(id: 'financial_genius', icon: LucideIcons.crown, title: 'Financial Genius', description: 'Achieve all financial goals', rarity: 'Epic', xp: 1000),
    Achievement(id: 'first_transaction', icon: LucideIcons.dollarSign, title: 'Money Mover', description: 'Record your first transaction', rarity: 'Common', xp: 50),
  ];

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
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: _firestoreService.getUserDataStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data?.data() == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final userData = snapshot.data!.data()!;
          final awardsData = userData['awards'] as Map<String, dynamic>? ?? {};
          final int xp = awardsData['xp'] ?? 0;
          final int level = awardsData['level'] ?? 1;
          final List<dynamic> unlockedIds = awardsData['unlocked'] ?? [];
          
          int xpForNextLevel = 100 + (level * 50);
          double levelProgress = xp.toDouble() / xpForNextLevel.toDouble();

          for (var ach in allAchievements) {
            ach.isUnlocked = unlockedIds.contains(ach.id);
          }

          int unlockedCount = allAchievements.where((a) => a.isUnlocked).length;
          int totalAchievements = allAchievements.length;

          return SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Text('Achievements', style: AppTheme.textTheme.headlineLarge),
                    const SizedBox(height: 4),
                    Text('Your successes and awards', style: AppTheme.textTheme.bodyLarge?.copyWith(color: AppTheme.mutedForeground)),
                    const SizedBox(height: 24),
                    _buildSummaryCard(level, xp, xpForNextLevel, levelProgress, unlockedCount, totalAchievements),
                    const SizedBox(height: 24),
                    // Stats Grid - This can be made dynamic later
                    _buildStatsGrid(),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('All Achievements', style: AppTheme.textTheme.headlineSmall),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.card.withAlpha(128),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Text('$unlockedCount of $totalAchievements', style: AppTheme.textTheme.bodyMedium),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    AnimationLimiter(
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: allAchievements.length,
                        itemBuilder: (context, index) {
                          return AnimationConfiguration.staggeredList(
                            position: index,
                            duration: const Duration(milliseconds: 375),
                            child: SlideAnimation(
                              verticalOffset: 50.0,
                              child: FadeInAnimation(
                                child: _buildAchievementItem(allAchievements[index]),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 80), // Space for bottom nav bar
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(int level, int xp, int xpForNextLevel, double levelProgress, int unlockedCount, int totalAchievements) {
    return _buildGlowContainer(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Level $level', style: AppTheme.textTheme.titleLarge?.copyWith(color: AppTheme.primaryForeground, fontWeight: FontWeight.bold)),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryForeground.withAlpha(64),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(LucideIcons.shield, color: AppTheme.primaryForeground, size: 32),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('$xp / $xpForNextLevel XP', style: AppTheme.textTheme.displayMedium?.copyWith(color: AppTheme.primaryForeground, fontSize: 32)),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: levelProgress,
              backgroundColor: AppTheme.primaryForeground.withAlpha(77),
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryForeground),
              minHeight: 6,
              borderRadius: BorderRadius.circular(3),
            ),
            const SizedBox(height: 16),
            Text('Achievements: $unlockedCount/$totalAchievements', style: AppTheme.textTheme.bodyMedium?.copyWith(color: AppTheme.primaryForeground)),
          ],
        ),
      ),
      glowColor: AppTheme.primary,
    );
  }

  Widget _buildStatsGrid() {
    // This remains static for now, but can be fed with dynamic data in the future
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 0.9,
      children: [
        _buildStatItem(LucideIcons.star, '5', 'Learning'),
        _buildStatItem(LucideIcons.flame, '3', 'Streaks'),
        _buildStatItem(LucideIcons.target, '4', 'Goals'),
        _buildStatItem(LucideIcons.shield, '2', 'Elite'),
      ],
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return _buildGlowContainer(
      ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.card.withAlpha(128),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: AppTheme.border.withAlpha(128)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: AppTheme.onSurface, size: 24),
                const SizedBox(height: 8),
                Text(value, style: AppTheme.textTheme.titleLarge),
                const SizedBox(height: 4),
                Flexible(
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: AppTheme.textTheme.bodyMedium?.copyWith(color: AppTheme.mutedForeground),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      glowColor: AppTheme.primary,
    );
  }

  Widget _buildAchievementItem(Achievement achievement) {
    final color = achievement.rarity == 'Rare'
        ? AppTheme.accent
        : achievement.rarity == 'Epic'
            ? AppTheme.primary
            : achievement.rarity == 'Uncommon'
                ? AppTheme.chart4
                : AppTheme.chart3;

    return _buildGlowContainer(
      Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.card.withAlpha(128),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.border.withAlpha(128)),
              ),
              child: Row(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: achievement.isUnlocked ? color.withAlpha(64) : AppTheme.muted.withAlpha(64),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Icon(
                          achievement.icon,
                          color: achievement.isUnlocked ? color : AppTheme.mutedForeground,
                          size: 30,
                        ),
                      ),
                      if (achievement.isUnlocked)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: AppTheme.surface,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(LucideIcons.checkCircle, color: AppTheme.chart3, size: 20),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(achievement.title, style: AppTheme.textTheme.titleMedium),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: color.withAlpha(26),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: color, width: 1),
                              ),
                              child: Text(achievement.rarity, style: AppTheme.textTheme.bodySmall?.copyWith(color: color, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(achievement.description, style: AppTheme.textTheme.bodyMedium?.copyWith(color: AppTheme.mutedForeground)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(LucideIcons.star, color: AppTheme.chart4, size: 16),
                            const SizedBox(width: 4),
                            Text('${achievement.xp} XP', style: AppTheme.textTheme.bodyMedium),
                            const Spacer(),
                            Flexible(
                              child: Text(
                                achievement.isUnlocked ? 'Unlocked' : 'Locked',
                                textAlign: TextAlign.end,
                                style: AppTheme.textTheme.bodySmall?.copyWith(
                                  color: achievement.isUnlocked ? AppTheme.chart3 : AppTheme.mutedForeground,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      glowColor: color,
    );
  }
}
