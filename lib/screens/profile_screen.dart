import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:qadam/screens/auth_screen.dart';
import 'package:qadam/screens/premium/premium_screen.dart';
import 'package:qadam/screens/settings/app_settings_screen.dart';
import 'package:qadam/screens/settings/language_screen.dart';
import 'package:qadam/screens/settings/privacy_security_screen.dart';
import 'package:qadam/screens/support/help_faq_screen.dart';
import 'package:qadam/theme/app_theme.dart';

// Helper function to show the edit name dialog
Future<void> _showEditNameDialog(BuildContext context, User currentUser) async {
  final nameController = TextEditingController(text: currentUser.displayName ?? '');
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Edit Name'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(hintText: "Enter your new name"),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('CANCEL'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          TextButton(
            child: const Text('SAVE'),
            onPressed: () async {
              if (nameController.text.isNotEmpty) {
                await currentUser.updateDisplayName(nameController.text);
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(currentUser.uid)
                    .update({'displayName': nameController.text});
                Navigator.pop(context);
              }
            },
          ),
        ],
      );
    },
  );
}

// Helper function for the glow effect
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

class ProfilePage extends StatelessWidget {
  final VoidCallback onBack;

  const ProfilePage({Key? key, required this.onBack}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
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
                  Header(onBack: onBack),
                  const SizedBox(height: 16),
                  const UserInfoCard(),
                  const SizedBox(height: 24),
                  const Stats(),
                  const SizedBox(height: 24),
                  const Preferences(),
                  const SizedBox(height: 24),
                  const Account(),
                  const SizedBox(height: 24),
                  const Support(),
                  const SizedBox(height: 24),
                  const PremiumCard(),
                  const SizedBox(height: 24),
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
  final VoidCallback onBack;

  const Header({Key? key, required this.onBack}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(LucideIcons.arrowLeft, color: AppTheme.onSurface),
            onPressed: onBack,
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Profile', style: AppTheme.textTheme.headlineSmall),
              const SizedBox(height: 4),
              Text('Manage your account',
                  style: AppTheme.textTheme.bodyMedium
                      ?.copyWith(color: AppTheme.mutedForeground)),
            ],
          ),
        ],
      ),
    );
  }
}

class UserInfoCard extends StatelessWidget {
  const UserInfoCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.userChanges(),
      builder: (context, snapshot) {
        final user = snapshot.data;
        if (user == null) {
          return const Center(child: Text("Not logged in"));
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: _buildGlowContainer(
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [AppTheme.primary, AppTheme.accent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: NetworkImage(user.photoURL ??
                            'https://i.pravatar.cc/150?u=a042581f4e29026704d'),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(user.displayName ?? 'No Name',
                                  style: AppTheme.textTheme.titleLarge
                                      ?.copyWith(color: AppTheme.primaryForeground)),
                              const SizedBox(width: 4),
                              const Icon(LucideIcons.crown, color: Colors.amber, size: 16),
                            ],
                          ),
                          Text(user.email ?? '',
                              style: AppTheme.textTheme.bodyMedium?.copyWith(
                                  color: AppTheme.primaryForeground.withAlpha(200))),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Chip(
                                  label: const Text('Premium'),
                                  backgroundColor:
                                      AppTheme.primaryForeground.withAlpha(50),
                                  labelStyle: AppTheme.textTheme.bodySmall
                                      ?.copyWith(color: AppTheme.primaryForeground)),
                              const SizedBox(width: 8),
                              Chip(
                                  label: const Text('Level 47'),
                                  backgroundColor:
                                      AppTheme.primaryForeground.withAlpha(50),
                                  labelStyle: AppTheme.textTheme.bodySmall
                                      ?.copyWith(color: AppTheme.primaryForeground)),
                            ],
                          )
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _showEditNameDialog(context, user),
                    icon: const Icon(LucideIcons.sparkles, size: 16),
                    label: const Text('Edit Profile'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                      backgroundColor: AppTheme.surface.withAlpha(200),
                      foregroundColor: AppTheme.onSurface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            glowColor: AppTheme.primary,
          ),
        );
      },
    );
  }
}

class Stats extends StatelessWidget {
  const Stats({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          const Expanded(
            child: StatCard(value: '47', label: 'Level', color: AppTheme.primary),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: StatCard(value: '15', label: 'Achievements', color: Colors.orange),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: StatCard(value: '8', label: 'Active Goals', color: Colors.green),
          ),
        ],
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const StatCard(
      {required this.value, required this.label, required this.color, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _buildGlowContainer(
      Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                height: 8,
                decoration: BoxDecoration(
                    color: color,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(4),
                    )
                ),
              ),
              const SizedBox(height: 12),
              Text(value, style: AppTheme.textTheme.headlineMedium),
              const SizedBox(height: 4),
              Text(label, style: AppTheme.textTheme.bodyMedium?.copyWith(color: AppTheme.mutedForeground), textAlign: TextAlign.center,),
            ],
          ),
        ),
      ),
      glowColor: color,
    );
  }
}

class Preferences extends StatelessWidget {
  const Preferences({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Preferences',
              style: AppTheme.textTheme.titleMedium
                  ?.copyWith(color: AppTheme.mutedForeground)),
          const SizedBox(height: 8),
          _buildGlowContainer(
            Card(
              child: Column(
                children: [
                  const NotificationToggle(),
                  const DarkModeToggle(),
                  ListTile(
                    leading: const Icon(LucideIcons.globe, color: AppTheme.mutedForeground),
                    title: Text('Language', style: AppTheme.textTheme.bodyLarge),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('English',
                            style: AppTheme.textTheme.bodyMedium
                                ?.copyWith(color: AppTheme.mutedForeground)),
                        const SizedBox(width: 8),
                        const Icon(LucideIcons.chevronRight,
                            color: AppTheme.mutedForeground),
                      ],
                    ),
                    onTap: () {
                        Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LanguageScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
            glowColor: AppTheme.primary,
          ),
        ],
      ),
    );
  }
}

class Account extends StatelessWidget {
  const Account({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Account',
              style: AppTheme.textTheme.titleMedium
                  ?.copyWith(color: AppTheme.mutedForeground)),
          const SizedBox(height: 8),
          _buildGlowContainer(
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(LucideIcons.user, color: AppTheme.mutedForeground),
                    title: Text('Edit Profile', style: AppTheme.textTheme.bodyLarge),
                    trailing: const Icon(LucideIcons.chevronRight,
                        color: AppTheme.mutedForeground),
                    onTap: () {
                      if (user != null) {
                        _showEditNameDialog(context, user);
                      }
                    },
                  ),
                  ListTile(
                    leading: const Icon(LucideIcons.shield, color: AppTheme.mutedForeground),
                    title: Text('Privacy & Security', style: AppTheme.textTheme.bodyLarge),
                    trailing: const Icon(LucideIcons.chevronRight,
                        color: AppTheme.mutedForeground),
                    onTap: () {
                       Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const PrivacySecurityScreen()),
                      );
                    },
                  ),
                   ListTile(
                    leading: const Icon(LucideIcons.settings, color: AppTheme.mutedForeground),
                    title: Text('App Settings', style: AppTheme.textTheme.bodyLarge),
                    trailing: const Icon(LucideIcons.chevronRight,
                        color: AppTheme.mutedForeground),
                    onTap: () {
                       Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AppSettingsScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
            glowColor: AppTheme.primary,
          ),
        ],
      ),
    );
  }
}

class Support extends StatelessWidget {
  const Support({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Support',
              style: AppTheme.textTheme.titleMedium
                  ?.copyWith(color: AppTheme.mutedForeground)),
          const SizedBox(height: 8),
          _buildGlowContainer(
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(LucideIcons.helpCircle, color: AppTheme.mutedForeground),
                    title: Text('Help & FAQ', style: AppTheme.textTheme.bodyLarge),
                    trailing: const Icon(LucideIcons.chevronRight, color: AppTheme.mutedForeground),
                    onTap: () {
                       Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const HelpFaqScreen()),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(LucideIcons.logOut, color: AppTheme.chart5),
                    title: Text('Sign Out', style: AppTheme.textTheme.bodyLarge?.copyWith(color: AppTheme.chart5)),
                    trailing: const Icon(LucideIcons.chevronRight, color: AppTheme.chart5),
                    onTap: () async {
                      await FirebaseAuth.instance.signOut();
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => const AuthScreen()),
                            (Route<dynamic> route) => false,
                      );
                    },
                  ),
                ],
              ),
            ),
            glowColor: AppTheme.primary,
          ),
        ],
      ),
    );
  }
}


class NotificationToggle extends StatefulWidget {
  const NotificationToggle({Key? key}) : super(key: key);

  @override
  _NotificationToggleState createState() => _NotificationToggleState();
}

class _NotificationToggleState extends State<NotificationToggle> {
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(LucideIcons.bell, color: AppTheme.mutedForeground),
      title: Text('Notifications', style: AppTheme.textTheme.bodyLarge),
      trailing: Switch(
        value: _notificationsEnabled,
        onChanged: (value) {
          setState(() {
            _notificationsEnabled = value;
          });
        },
        thumbColor: WidgetStateProperty.all(AppTheme.primary),
        trackColor: WidgetStateProperty.all(AppTheme.primary.withAlpha(128)),
      ),
    );
  }
}

class DarkModeToggle extends StatefulWidget {
  const DarkModeToggle({Key? key}) : super(key: key);

  @override
  _DarkModeToggleState createState() => _DarkModeToggleState();
}

class _DarkModeToggleState extends State<DarkModeToggle> {
  bool _isDarkMode = true;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(LucideIcons.moon, color: AppTheme.mutedForeground),
      title: Text('Dark Mode', style: AppTheme.textTheme.bodyLarge),
      trailing: Switch(
        value: _isDarkMode,
        onChanged: (value) {
          setState(() {
            _isDarkMode = value;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Theme switching is a work in progress!')),
            );
          });
        },
        thumbColor: WidgetStateProperty.all(AppTheme.primary),
        trackColor: WidgetStateProperty.all(AppTheme.primary.withAlpha(128)),
      ),
    );
  }
}

class PremiumCard extends StatelessWidget {
  const PremiumCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: _buildGlowContainer(
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [Colors.pinkAccent, Colors.purpleAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(LucideIcons.zap, color: Colors.white, size: 32),
              const SizedBox(height: 16),
              Text('Upgrade to Premium', style: AppTheme.textTheme.headlineSmall?.copyWith(color: Colors.white)),
              const SizedBox(height: 8),
              Text('Unlock advanced features, unlimited goals, and detailed analytics', style: AppTheme.textTheme.bodyMedium?.copyWith(color: Colors.white.withAlpha(200))),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                   Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const PremiumScreen()),
                  );
                },
                child: const Text('Learn More'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  backgroundColor: Colors.white,
                  foregroundColor: AppTheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
        glowColor: Colors.pinkAccent,
      ),
    );
  }
}
