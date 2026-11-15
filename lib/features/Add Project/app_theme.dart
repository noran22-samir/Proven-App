import 'package:flutter/material.dart';

abstract final class AppColors {
  static const background = Color(0xFF1A1B24);
  static const surface = Color(0xFF0C253A);
  static const field = Color(0xFF102D42);
  static const border = Color(0xFF2A536E);
  static const primary = Color(0xFF0C79B9);
  static const primaryBright = Color(0xFF58B4E8);
  static const text = Color.fromARGB(204, 245, 247, 250);
  static const muted = Color(0xFF98AFC1);
  static const amber = Color(0xFFF1C65D);
  static const amberSurface = Color(0xFF211E18);
  static const success = Color(0xFF6DE0A2);
}

ThemeData buildClinicFlowTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.background,
    fontFamily: 'Roboto',
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      surface: AppColors.surface,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.field,
      hintStyle: const TextStyle(color: AppColors.muted),
      labelStyle: const TextStyle(color: AppColors.text),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
      ),
    ),
  );
}
