import 'package:flutter/material.dart';

/// Centralized application theme and styling tokens.
class AppTheme {
  AppTheme._();

  // Primary palette (Teal / Medical Blue)
  static const Color primaryTeal = Color(0xFF00796B);
  static const Color primaryLight = Color(0xFF009688);
  static const Color primaryDark = Color(0xFF004D40);
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color cardLight = Colors.white;
  static const Color textDark = Color(0xFF1E293B);
  static const Color textMuted = Color(0xFF64748B);
  static const Color borderLight = Color(0xFFE2E8F0);

  // Dark palette
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color cardDark = Color(0xFF1E293B);
  static const Color textLight = Color(0xFFF1F5F9);
  static const Color textMutedDark = Color(0xFF94A3B8);
  static const Color borderDark = Color(0xFF334155);

  // Curated color options for medicines
  static const List<Color> medicineColors = [
    Color(0xFF00796B), // Teal
    Color(0xFF0284C7), // Sky Blue
    Color(0xFF6366F1), // Indigo
    Color(0xFF8B5CF6), // Purple
    Color(0xFFEC4899), // Pink
    Color(0xFFF97316), // Orange
    Color(0xFF10B981), // Emerald
    Color(0xFF64748B), // Slate
  ];

  // Curated icons for medicine forms
  static const List<IconData> medicineIcons = [
    Icons.medication_outlined,
    Icons.medical_services_outlined,
    Icons.water_drop_outlined,
    Icons.vaccines_outlined,
    Icons.healing_outlined,
    Icons.health_and_safety_outlined,
    Icons.alarm,
    Icons.favorite_outline,
  ];

  /// Material 3 Light Theme configuration
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryTeal,
      brightness: Brightness.light,
      surface: backgroundLight,
      onSurface: textDark,
      primary: primaryTeal,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: backgroundLight,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: textDark,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textDark,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
      ),
      cardTheme: CardTheme(
        color: cardLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: borderLight, width: 1),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryTeal,
        foregroundColor: Colors.white,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryTeal, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
      ),
    );
  }

  /// Material 3 Dark Theme configuration
  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryTeal,
      brightness: Brightness.dark,
      surface: backgroundDark,
      onSurface: textLight,
      primary: const Color(0xFF2DD4BF),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: backgroundDark,
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceDark,
        foregroundColor: textLight,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textLight,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
      ),
      cardTheme: CardTheme(
        color: cardDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: borderDark, width: 1),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: const Color(0xFF2DD4BF),
        foregroundColor: Colors.black,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceDark,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2DD4BF), width: 1.8),
        ),
      ),
    );
  }
}
