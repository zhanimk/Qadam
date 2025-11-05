
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Defines the visual style of the [Alert] widget.
enum AlertVariant {
  /// The default style for informational alerts.
  defaults,
  
  /// The style for alerts that indicate a destructive or critical action.
  destructive,
}

/// A custom alert widget to display important messages.
///
/// This widget is a Flutter implementation of the provided React alert component.
/// It displays an optional icon, a title, and a description, with support
/// for different visual variants.
class Alert extends StatelessWidget {
  /// An optional icon to display on the left side of the alert.
  final Widget? icon;
  
  /// The main title of the alert.
  final Widget title;
  
  /// The detailed description or content of the alert.
  final Widget description;
  
  /// The visual style of the alert.
  final AlertVariant variant;

  const Alert({
    Key? key,
    this.icon,
    required this.title,
    required this.description,
    this.variant = AlertVariant.defaults,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color titleColor;
    final Color descriptionColor;
    final Color? iconColor;

    switch (variant) {
      case AlertVariant.destructive:
        titleColor = AppTheme.destructive;
        descriptionColor = AppTheme.destructive.withAlpha(230);
        iconColor = AppTheme.destructive;
        break;
      case AlertVariant.defaults:
        titleColor = AppTheme.cardForeground;
        descriptionColor = AppTheme.mutedForeground;
        iconColor = AppTheme.cardForeground;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16.0), // Corrected: Using the value from the theme
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null)
            Padding(
              padding: const EdgeInsets.only(right: 12.0, top: 2.0),
              child: IconTheme(
                data: IconThemeData(color: iconColor, size: 18),
                child: icon!,
              ),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DefaultTextStyle(
                  style: AppTheme.textTheme.titleMedium!.copyWith(
                    color: titleColor,
                    fontWeight: FontWeight.w500,
                  ),
                  child: title,
                ),
                const SizedBox(height: 4),
                DefaultTextStyle(
                  style: AppTheme.textTheme.bodyMedium!.copyWith(
                    color: descriptionColor,
                  ),
                  child: description,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
