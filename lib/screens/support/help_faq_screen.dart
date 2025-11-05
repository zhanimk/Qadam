import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:qadam/theme/app_theme.dart';

class HelpFaqScreen extends StatefulWidget {
  const HelpFaqScreen({Key? key}) : super(key: key);

  @override
  _HelpFaqScreenState createState() => _HelpFaqScreenState();
}

class _HelpFaqScreenState extends State<HelpFaqScreen> {
  final List<Map<String, String>> _faqs = [
    {
      'question': 'How do I reset my password?',
      'answer':
          'You can reset your password from the login screen. Tap on \"Forgot Password\" and follow the instructions sent to your email address.',
    },
    {
      'question': 'How do I change my profile picture?',
      'answer':
          'Navigate to the profile screen and tap on your current profile picture. You will be prompted to select a new image from your gallery or take a new photo.',
    },
    {
      'question': 'What is the Premium subscription?',
      'answer':
          'Our Premium subscription unlocks advanced features, including detailed analytics, unlimited goal tracking, and exclusive content. You can learn more on the Premium screen.',
    },
    {
      'question': 'How is my development score calculated?',
      'answer':
          'Your development score is a composite metric based on your activity across different categories like health, finance, and intellect. Completing goals, maintaining streaks, and earning XP all contribute to your score.',
    },
     {
      'question': 'Can I use the app offline?',
      'answer':
          'Basic features like viewing your goals and progress are available offline. However, for syncing data and accessing real-time updates, an internet connection is required.',
    },
  ];

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
        title: Text('Help & FAQ', style: AppTheme.textTheme.headlineSmall),
      ),
      body: AnimationLimiter(
        child: ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: _faqs.length,
          itemBuilder: (BuildContext context, int index) {
            final faq = _faqs[index];
            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 375),
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: Card(
                     margin: const EdgeInsets.symmetric(vertical: 8.0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: ExpansionTile(
                      iconColor: AppTheme.primary,
                      collapsedIconColor: AppTheme.mutedForeground,
                      childrenPadding: const EdgeInsets.all(16.0),
                      title: Text(faq['question']!, style: AppTheme.textTheme.titleMedium),
                      children: <Widget>[
                        Text(
                          faq['answer']!,
                          style: AppTheme.textTheme.bodyMedium?.copyWith(color: AppTheme.mutedForeground, height: 1.5),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
