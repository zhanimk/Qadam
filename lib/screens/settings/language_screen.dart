import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:qadam/theme/app_theme.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({Key? key}) : super(key: key);

  @override
  _LanguageScreenState createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  String _selectedLanguage = 'English'; // Default language

  final List<Map<String, String>> _languages = [
    {'name': 'English', 'native': 'English'},
    {'name': 'Русский', 'native': 'Russian'},
    {'name': 'Қазақша', 'native': 'Kazakh'},
    {'name': 'Español', 'native': 'Spanish'},
    {'name': 'Français', 'native': 'French'},
  ];

  Widget _buildGlowContainer(Widget child, {bool isGlowing = false}) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: isGlowing
            ? [
                BoxShadow(
                  color: AppTheme.primary.withAlpha(102),
                  blurRadius: 15,
                  spreadRadius: -5,
                  offset: const Offset(0, 5),
                ),
              ]
            : [],
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
        title: Text('Language', style: AppTheme.textTheme.headlineSmall),
      ),
      body: AnimationLimiter(
        child: ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: _languages.length,
          itemBuilder: (BuildContext context, int index) {
            final language = _languages[index];
            final isSelected = _selectedLanguage == language['name'];

            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 375),
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: _buildGlowContainer(
                    Card(
                      elevation: 0,
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: isSelected
                            ? const BorderSide(color: AppTheme.primary, width: 1.5)
                            : BorderSide.none,
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 12.0, horizontal: 20.0),
                        title: Text(language['name']!,
                            style: AppTheme.textTheme.titleMedium),
                        subtitle: Text(language['native']!,
                            style: AppTheme.textTheme.bodyMedium
                                ?.copyWith(color: AppTheme.mutedForeground)),
                        trailing: isSelected
                            ? const Icon(LucideIcons.checkCircle, color: AppTheme.primary)
                            : null,
                        onTap: () {
                          setState(() {
                            _selectedLanguage = language['name']!;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${language['name']} selected.'),
                              backgroundColor: AppTheme.primary,
                            ),
                          );
                        },
                      ),
                    ),
                    isGlowing: isSelected,
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
