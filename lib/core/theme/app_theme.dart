import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proven/core/theme/colors.dart';

abstract final class AppTheme {
  static ThemeData get dark {
    final base = ThemeData(brightness: Brightness.dark, useMaterial3: true);

    OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: c, width: w),
        );

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.tertiary,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.inversePrimary,
        onPrimary: AppColors.primary,
        secondary: AppColors.secondaryContainer,
        surface: AppColors.tertiary,
        error: Color(0xFFFF8A80),
      ),
      textTheme: GoogleFonts.ibmPlexSansTextTheme(base.textTheme)
          .apply(bodyColor: Colors.white, displayColor: Colors.white),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.tertiary,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.tertiaryContainer,
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.tertiaryContainer.withValues(alpha: 0.6),
        hintStyle: const TextStyle(color: AppColors.onTertiaryContainer),
        labelStyle: const TextStyle(color: AppColors.onTertiaryContainer),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        border: border(AppColors.outline.withValues(alpha: 0.35)),
        enabledBorder: border(AppColors.outline.withValues(alpha: 0.35)),
        focusedBorder: border(AppColors.inversePrimary, 1.5),
        errorBorder: border(const Color(0xFFFF8A80)),
        focusedErrorBorder: border(const Color(0xFFFF8A80), 1.5),
      ),
    );
  }
}