
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Shows a custom alert dialog styled according to the application's theme.
///
/// This function displays a dialog with a title, description, and a set of actions.
/// It is a Flutter implementation of the provided React alert-dialog component.
///
/// - [context]: The build context from which to show the dialog.
/// - [title]: The main title of the dialog (typically a Text widget).
/// - [description]: The detailed message or description (typically a Text widget).
/// - [actions]: A list of widgets, typically buttons, for user interaction.
Future<T?> showAlertDialog<T>({
  required BuildContext context,
  required Widget title,
  required Widget description,
  List<Widget> actions = const [],
}) {
  return showDialog<T>(
    context: context,
    barrierColor: Colors.black.withAlpha(128),
    builder: (BuildContext context) {
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2), // Frosted glass effect
        child: Dialog(
          backgroundColor: AppTheme.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0), // Corrected: Using the value from the theme
            side: const BorderSide(color: AppTheme.border),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // AlertDialogHeader
                DefaultTextStyle(
                  style: AppTheme.textTheme.headlineSmall!,
                  child: title, // AlertDialogTitle
                ),
                const SizedBox(height: 8),
                DefaultTextStyle(
                  style: AppTheme.textTheme.bodyMedium!.copyWith(color: AppTheme.mutedForeground),
                  child: description, // AlertDialogDescription
                ),
                const SizedBox(height: 24),
                // AlertDialogFooter
                if (actions.isNotEmpty)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: actions.map((action) => Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: action,
                    )).toList(),
                  ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

/// A default cancel action button for the [showAlertDialog].
/// Corresponds to [AlertDialogCancel]
class AlertDialogCancelAction extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  const AlertDialogCancelAction({
    Key? key,
    this.text = 'Cancel',
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed ?? () => Navigator.of(context).pop(),
      child: Text(text),
    );
  }
}

/// A default primary action button for the [showAlertDialog].
/// Corresponds to [AlertDialogAction]
class AlertDialogPrimaryAction extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isDestructive;

  const AlertDialogPrimaryAction({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isDestructive = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: isDestructive
          ? ElevatedButton.styleFrom(
              backgroundColor: AppTheme.destructive,
              foregroundColor: AppTheme.primaryForeground, // Corrected: Using a valid color from the theme
            )
          : null,
      onPressed: onPressed,
      child: Text(text),
    );
  }
}
