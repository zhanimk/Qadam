import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:qadam/theme/app_theme.dart';

class AppSettingsScreen extends StatelessWidget {
  const AppSettingsScreen({Key? key}) : super(key: key);

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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppTheme.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('App Settings', style: AppTheme.textTheme.headlineSmall),
      ),
      body: AnimationLimiter(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: AnimationConfiguration.toStaggeredList(
            duration: const Duration(milliseconds: 375),
            childAnimationBuilder: (widget) => SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: widget,
              ),
            ),
            children: [
              _buildSectionTitle('Storage'),
              _buildGlowContainer(
                Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 12.0, horizontal: 20.0),
                    leading: const Icon(LucideIcons.trash, color: AppTheme.mutedForeground),
                    title: Text('Clear Cache', style: AppTheme.textTheme.titleMedium),
                    subtitle: Text('Free up storage space', style: AppTheme.textTheme.bodyMedium?.copyWith(color: AppTheme.mutedForeground)),
                    trailing: Text('128 MB', style: AppTheme.textTheme.bodyLarge?.copyWith(color: AppTheme.primary)),
                    onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Cache Cleared!'),
                          backgroundColor: AppTheme.primary,
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Data'),
              _buildGlowContainer(
                Card(
                  child: SwitchListTile(
                     contentPadding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 20.0),
                    secondary: const Icon(LucideIcons.barChart, color: AppTheme.mutedForeground),
                    title: Text('Use Cellular Data', style: AppTheme.textTheme.titleMedium),
                     subtitle: Text('Allow data usage on cellular networks', style: AppTheme.textTheme.bodyMedium?.copyWith(color: AppTheme.mutedForeground)),
                    value: true, // Dummy value
                    onChanged: (bool value) {},
                     thumbColor: WidgetStateProperty.all(AppTheme.primary),
                     trackColor: WidgetStateProperty.all(AppTheme.primary.withAlpha(128)),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('General'),
               _buildGlowContainer(
                 Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
                    leading: const Icon(LucideIcons.refreshCw, color: AppTheme.mutedForeground),
                    title: Text('Reset Settings', style: AppTheme.textTheme.titleMedium),
                    subtitle: Text('Restore all settings to default', style: AppTheme.textTheme.bodyMedium?.copyWith(color: AppTheme.mutedForeground)),
                    onTap: () {
                      // Show confirmation dialog
                    },
                  ),
                             ),
               ),
                const SizedBox(height: 16),
                 _buildGlowContainer(
                   Card(
                  child: ListTile(
                     contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
                    leading: const Icon(LucideIcons.info, color: AppTheme.mutedForeground),
                    title: Text('About', style: AppTheme.textTheme.titleMedium),
                    subtitle: Text('Version 1.0.0', style: AppTheme.textTheme.bodyMedium?.copyWith(color: AppTheme.mutedForeground)),
                    trailing: const Icon(LucideIcons.chevronRight, color: AppTheme.mutedForeground),
                    onTap: () {
                      // Navigate to About Screen
                    },
                  ),
                             ),
                 ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
      child: Text(
        title,
        style: AppTheme.textTheme.titleMedium?.copyWith(color: AppTheme.mutedForeground),
      ),
    );
  }
}
