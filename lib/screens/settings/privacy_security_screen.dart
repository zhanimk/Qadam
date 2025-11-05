import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:qadam/screens/placeholder_screen.dart';
import 'package:qadam/theme/app_theme.dart';

class PrivacySecurityScreen extends StatefulWidget {
  const PrivacySecurityScreen({Key? key}) : super(key: key);

  @override
  _PrivacySecurityScreenState createState() => _PrivacySecurityScreenState();
}

class _PrivacySecurityScreenState extends State<PrivacySecurityScreen> {
  bool _twoFactorEnabled = false;

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
        title: Text('Privacy & Security', style: AppTheme.textTheme.headlineSmall),
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
              _buildGlowContainer(
                Card(
                  child: SwitchListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 20.0),
                    title: Text('Two-Factor Authentication', style: AppTheme.textTheme.titleMedium),
                    subtitle: Text('Add an extra layer of security', style: AppTheme.textTheme.bodyMedium?.copyWith(color: AppTheme.mutedForeground)),
                    value: _twoFactorEnabled,
                     secondary: const Icon(LucideIcons.shieldCheck, color: AppTheme.primary),
                    onChanged: (bool value) {
                      setState(() {
                        _twoFactorEnabled = value;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(value ? 'Two-Factor Authentication Enabled' : 'Two-Factor Authentication Disabled'),
                          backgroundColor: AppTheme.primary,
                        ),
                      );
                    },
                     thumbColor: WidgetStateProperty.all(AppTheme.primary),
                     trackColor: WidgetStateProperty.all(AppTheme.primary.withAlpha(128)),
                  ),
                ),
                 glowColor: _twoFactorEnabled ? AppTheme.primary : AppTheme.surface.withAlpha(0),
              ),
              const SizedBox(height: 16),
               _buildGlowContainer(
                 Card(
                  child: ListTile(
                     contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
                    leading: const Icon(LucideIcons.smartphone, color: AppTheme.mutedForeground),
                    title: Text('Manage Sessions', style: AppTheme.textTheme.titleMedium),
                    subtitle: Text('Review and revoke active sessions', style: AppTheme.textTheme.bodyMedium?.copyWith(color: AppTheme.mutedForeground)),
                    trailing: const Icon(LucideIcons.chevronRight, color: AppTheme.mutedForeground),
                    onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const PlaceholderScreen(title: 'Manage Sessions')));
                    },
                  ),
                             ),
               ),
              const SizedBox(height: 24),
              Text(
                'Data Management',
                style: AppTheme.textTheme.titleMedium?.copyWith(color: AppTheme.mutedForeground),
              ),
              const SizedBox(height: 8),
               _buildGlowContainer(
                 Card(
                  child: ListTile(
                     contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
                    leading: const Icon(LucideIcons.downloadCloud, color: AppTheme.mutedForeground),
                    title: Text('Download Your Data', style: AppTheme.textTheme.titleMedium),
                     subtitle: Text('Get a copy of your personal data', style: AppTheme.textTheme.bodyMedium?.copyWith(color: AppTheme.mutedForeground)),
                    trailing: const Icon(LucideIcons.chevronRight, color: AppTheme.mutedForeground),
                    onTap: () {
                         Navigator.push(context, MaterialPageRoute(builder: (context) => const PlaceholderScreen(title: 'Download Data')));
                    },
                  ),
                             ),
               ),
                const SizedBox(height: 24),
                 _buildGlowContainer(
                   Card(
                     elevation: 0,
                     color: AppTheme.chart5.withAlpha(26),
                     shape: RoundedRectangleBorder(
                         borderRadius: BorderRadius.circular(16),
                         side: const BorderSide(color: AppTheme.chart5, width: 1)),
                     child: ListTile(
                       contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
                       leading: const Icon(LucideIcons.trash2, color: AppTheme.chart5),
                       title: Text('Delete Account', style: AppTheme.textTheme.titleMedium?.copyWith(color: AppTheme.chart5)),
                       subtitle: Text('Permanently delete your account', style: AppTheme.textTheme.bodyMedium?.copyWith(color: AppTheme.chart5.withAlpha(200))),
                       onTap: () {
                         // Show confirmation dialog
                       },
                     ),
                   ),
                   glowColor: AppTheme.chart5,
                 )
            ],
          ),
        ),
      ),
    );
  }
}
