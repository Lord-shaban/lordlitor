import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';


class AppColors {
  // Duolingo-inspired core palette
  static const Color primary = Color(0xFF58CC02);
  static const Color primaryDark = Color(0xFF46A302);
  static const Color primaryShadow = Color(0xFF3B8C01);
  static const Color secondary = Color(0xFF1CB0F6);
  static const Color secondaryDark = Color(0xFF0095D9);
  static const Color secondaryShadow = Color(0xFF0077B3);
  static const Color accent = Color(0xFFFF9600);
  static const Color accentDark = Color(0xFFE08600);
  static const Color error = Color(0xFFFF4B4B);
  static const Color errorDark = Color(0xFFE63E3E);
  static const Color errorLight = Color(0xFFFFE0E0);
  static const Color purple = Color(0xFFCE82FF);
  static const Color purpleDark = Color(0xFFA855F7);
  static const Color purpleShadow = Color(0xFF8B35E0);
  static const Color gold = Color(0xFFFFD900);
  static const Color goldDark = Color(0xFFE6C300);

  // Background colors - softer, more Duolingo-like
  static const Color background = Color(0xFFF0F0F0);
  static const Color surface = Colors.white;
  static const Color cardBg = Colors.white;
  static const Color scaffoldDark = Color(0xFF131F24);

  // Text colors
  static const Color textPrimary = Color(0xFF3C3C3C);
  static const Color textSecondary = Color(0xFF777777);
  static const Color textLight = Color(0xFFAFAFAF);
  static const Color textOnPrimary = Colors.white;

  // Feedback colors
  static const Color correct = Color(0xFF58CC02);
  static const Color correctBg = Color(0xFFD7FFB8);
  static const Color correctBorder = Color(0xFF58CC02);
  static const Color wrong = Color(0xFFFF4B4B);
  static const Color wrongBg = Color(0xFFFFE0E0);
  static const Color wrongBorder = Color(0xFFFF4B4B);

  // Duolingo streak/fire
  static const Color streak = Color(0xFFFF9600);

  // Category colors with shadow pairs
  static const Color multiplicationColor = Color(0xFF58CC02);
  static const Color multiplicationShadow = Color(0xFF3B8C01);
  static const Color additionColor = Color(0xFF1CB0F6);
  static const Color additionShadow = Color(0xFF0077B3);
  static const Color subtractionColor = Color(0xFFFF9600);
  static const Color subtractionShadow = Color(0xFFCC7700);
  static const Color divisionColor = Color(0xFFCE82FF);
  static const Color divisionShadow = Color(0xFF9B50D0);
  static const Color sequenceColor = Color(0xFFFF4B4B);
  static const Color sequenceShadow = Color(0xFFCC2E2E);
  static const Color mentalMathColor = Color(0xFFFFD900);
  static const Color mentalMathShadow = Color(0xFFCCAE00);

  /// Get shadow color for a given color
  static Color getShadow(Color color) {
    if (color == multiplicationColor) return multiplicationShadow;
    if (color == additionColor) return additionShadow;
    if (color == subtractionColor) return subtractionShadow;
    if (color == divisionColor) return divisionShadow;
    if (color == sequenceColor) return sequenceShadow;
    if (color == mentalMathColor) return mentalMathShadow;
    if (color == primary) return primaryShadow;
    if (color == secondary) return secondaryShadow;
    if (color == purple) return purpleShadow;
    if (color == error) return errorDark;
    // Fallback: darken
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness - 0.15).clamp(0, 1)).toColor();
  }
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.background,
      textTheme: GoogleFonts.cairoTextTheme().copyWith(
        displayLarge: GoogleFonts.cairo(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
        ),
        displayMedium: GoogleFonts.cairo(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        headlineLarge: GoogleFonts.cairo(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        headlineMedium: GoogleFonts.cairo(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        titleLarge: GoogleFonts.cairo(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        titleMedium: GoogleFonts.cairo(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
        bodyLarge: GoogleFonts.cairo(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
        ),
        bodyMedium: GoogleFonts.cairo(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
        ),
        labelLarge: GoogleFonts.cairo(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.cairo(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: AppColors.cardBg,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE5E5E5), width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE5E5E5), width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 2.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        hintStyle: GoogleFonts.cairo(
          color: AppColors.textLight,
          fontSize: 18,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.cairo(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
    );
  }
}



