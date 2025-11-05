import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_theme.dart';

// Model for an achievement
class Achievement {
  final IconData icon;
  final String title;
  final String description;
  final String rarity;
  final int xp;
  final bool isUnlocked;
  final String? dateUnlocked;

  Achievement({
    required this.icon,
    required this.title,
    required this.description,
    required this.rarity,
    required this.xp,
    this.isUnlocked = false,
    this.dateUnlocked,
  });
}

class AwardsScreen extends StatelessWidget {
  const AwardsScreen({Key? key}) : super(key: key);

  // Dummy data based on the design
  static final List<Achievement> achievements = [
    Achievement(
      icon: LucideIcons.target,
      title: 'First Step',
      description: 'Create your first goal',
      rarity: 'Common',
      xp: 50,
      isUnlocked: true,
      dateUnlocked: 'Unlocked: Oct 5, 2025',
    ),
    Achievement(
      icon: LucideIcons.flame,
      title: 'Week of Strength',
      description: 'Maintain a 7-day streak',
      rarity: 'Common',
      xp: 100,
      isUnlocked: true,
      dateUnlocked: 'Unlocked: Oct 12, 2025',
    ),
    Achievement(
      icon: LucideIcons.flame,
      title: '30-Day Marathon',
      description: 'Maintain a 30-day streak',
      rarity: 'Rare',
      xp: 500,
    ),
    Achievement(
      icon: LucideIcons.book,
      title: 'Bookworm',
      description: 'Read 10 books',
      rarity: 'Uncommon',
      xp: 200,
      isUnlocked: true,
      dateUnlocked: 'Unlocked: Oct 18, 2025',
    ),
    Achievement(
      icon: LucideIcons.user,
      title: 'Productivity Guru',
      description: 'Complete 100 tasks',
      rarity: 'Uncommon',
      xp: 300,
      isUnlocked: true,
      dateUnlocked: 'Unlocked: Oct 20, 2025',
    ),
    Achievement(
      icon: LucideIcons.zap,
      title: 'Habit Master',
      description: 'Track 10 different habits',
      rarity: 'Rare',
      xp: 400,
    ),
    Achievement(
      icon: LucideIcons.crown,
      title: 'Financial Genius',
      description: 'Achieve all financial goals',
      rarity: 'Epic',
      xp: 1000,
    ),
    Achievement(
      icon: LucideIcons.award,
      title: 'Iron Man',
      description: 'Train for 30 days straight',
      rarity: 'Rare',
      xp: 600,
    ),
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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                // Header
                Text('Achievements', style: AppTheme.textTheme.headlineLarge),
                const SizedBox(height: 4),
                Text('Your successes and awards', style: AppTheme.textTheme.bodyLarge?.copyWith(color: AppTheme.mutedForeground)),
                const SizedBox(height: 24),
                // Summary Card
                _buildSummaryCard(),
                const SizedBox(height: 24),
                // Stats Grid
                _buildStatsGrid(),
                const SizedBox(height: 24),
                // All Achievements Title
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
                      child: Text('4 of 8', style: AppTheme.textTheme.bodyMedium),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Achievements List
                AnimationLimiter(
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: achievements.length,
                    itemBuilder: (context, index) {
                      return AnimationConfiguration.staggeredList(
                        position: index,
                        duration: const Duration(milliseconds: 375),
                        child: SlideAnimation(
                          verticalOffset: 50.0,
                          child: FadeInAnimation(
                            child: _buildAchievementItem(achievements[index]),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                // Next Goal Card
                _buildNextGoalCard(),
                const SizedBox(height: 80), // Space for bottom nav bar
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
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
                Text('Unlocked', style: AppTheme.textTheme.titleLarge?.copyWith(color: AppTheme.primaryForeground)),
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
            Text('4/8', style: AppTheme.textTheme.displayMedium?.copyWith(color: AppTheme.primaryForeground)),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: 0.5,
              backgroundColor: AppTheme.primaryForeground.withAlpha(77),
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryForeground),
            ),
            const SizedBox(height: 16),
            Text('Total XP earned: 650', style: AppTheme.textTheme.bodyMedium?.copyWith(color: AppTheme.primaryForeground)),
          ],
        ),
      ),
      glowColor: AppTheme.primary,
    );
  }

  Widget _buildStatsGrid() {
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
                Text(label, textAlign: TextAlign.center, softWrap: true, style: AppTheme.textTheme.bodyMedium?.copyWith(color: AppTheme.mutedForeground)),
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
                                achievement.isUnlocked ? achievement.dateUnlocked! : 'Locked',
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

  Widget _buildNextGoalCard() {
    return _buildGlowContainer(
      ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.border.withAlpha(128)),
              gradient: const LinearGradient(
                colors: [AppTheme.primary, AppTheme.accent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                const Icon(LucideIcons.target, color: AppTheme.primaryForeground, size: 40),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Next Goal', style: AppTheme.textTheme.titleMedium?.copyWith(color: AppTheme.primaryForeground)),
                      const SizedBox(height: 4),
                      Text('6 days left to unlock the "30-Day Marathon" achievement', style: AppTheme.textTheme.bodyMedium?.copyWith(color: AppTheme.primaryForeground.withAlpha(204))),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: 0.8, // 24 days / 30 days
                        backgroundColor: AppTheme.primaryForeground.withAlpha(77),
                        minHeight: 6,
                        borderRadius: BorderRadius.circular(3),
                        valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryForeground),
                      ),
                    ],
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
}
