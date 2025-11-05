
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Primary Palette
  static const Color primary = Color(0xFF8B5CF6);
  static const Color primaryForeground = Color(0xFFFFFFFF);
  static const Color secondary = Color(0xFF312E81);
  static const Color secondaryForeground = Color(0xFFF1F5F9);
  static const Color accent = Color(0xFF6366F1);
  static const Color accentForeground = Color(0xFFFFFFFF);

  // Background & Surface
  static const Color surface = Color(0xFF13112A); // Adjusted from 0F172A to match app
  static const Color onSurface = Color(0xFFF1F5F9);
  static const Color card = Color(0xFF1E293B);
  static const Color cardForeground = Color(0xFFF1F5F9);
  static const Color popover = Color(0xFF1E293B);

  // Muted & Borders
  static const Color muted = Color(0xFF1E293B);
  static const Color mutedForeground = Color(0xFF94A3B8);
  static const Color border = Color.fromRGBO(139, 92, 246, 0.2);
  
  // Input & Destructive
  static const Color input = Color.fromRGBO(139, 92, 246, 0.1);
  static const Color inputBackground = Color(0xFF1E293B);
  static const Color destructive = Color(0xFFEF4444);

  // Chart Colors
  static const Color chart1 = Color(0xFF8B5CF6);
  static const Color chart2 = Color(0xFF6366F1);
  static const Color chart3 = Color(0xFFA78BFA);
  static const Color chart4 = Color(0xFFC084FC);
  static const Color chart5 = Color(0xFFE879F9);

  // Base Text Theme
  static final TextTheme _baseTextTheme = GoogleFonts.interTextTheme(
    const TextTheme(
      displayLarge: TextStyle(fontWeight: FontWeight.w800),
      displayMedium: TextStyle(fontWeight: FontWeight.w700),
      displaySmall: TextStyle(fontWeight: FontWeight.w700),
      headlineLarge: TextStyle(fontWeight: FontWeight.w800),
      headlineMedium: TextStyle(fontWeight: FontWeight.w700),
      headlineSmall: TextStyle(fontWeight: FontWeight.w700),
      titleLarge: TextStyle(fontWeight: FontWeight.w600),
      titleMedium: TextStyle(fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(fontWeight: FontWeight.w400),
      bodyMedium: TextStyle(fontWeight: FontWeight.w400),
      labelLarge: TextStyle(fontWeight: FontWeight.w500),
    ).apply(
      bodyColor: onSurface,
      displayColor: onSurface,
    ),
  );

  // Apply Playfair Display to headlines
  static final TextTheme textTheme = _baseTextTheme.copyWith(
    displayLarge: GoogleFonts.playfairDisplayTextTheme(_baseTextTheme).displayLarge,
    displayMedium: GoogleFonts.playfairDisplayTextTheme(_baseTextTheme).displayMedium,
    displaySmall: GoogleFonts.playfairDisplayTextTheme(_baseTextTheme).displaySmall,
    headlineLarge: GoogleFonts.playfairDisplayTextTheme(_baseTextTheme).headlineLarge,
    headlineMedium: GoogleFonts.playfairDisplayTextTheme(_baseTextTheme).headlineMedium,
    headlineSmall: GoogleFonts.playfairDisplayTextTheme(_baseTextTheme).headlineSmall,
  );

  static ThemeData get themeData {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: surface,
      primaryColor: primary,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: accent,
        surface: surface,
        onPrimary: primaryForeground,
        onSecondary: accentForeground,
        onSurface: onSurface,
        error: destructive,
        onError: primaryForeground,
      ),
      textTheme: textTheme,
      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0), // --radius: 1rem
          side: BorderSide(color: border, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputBackground,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        hintStyle: TextStyle(color: mutedForeground),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primary,
        linearTrackColor: muted.withAlpha(128),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: primaryForeground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0)
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: textTheme.labelLarge,
        )
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: onSurface,
          side: BorderSide(color: border),
           shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0)
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: textTheme.labelLarge,
        )
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        elevation: 0,
        titleTextStyle: textTheme.headlineSmall,
        iconTheme: const IconThemeData(color: onSurface),
      ),
    );
  }
}
