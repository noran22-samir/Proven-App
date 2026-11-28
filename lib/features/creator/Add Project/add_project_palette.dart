// المسار: lib/features/creator/Add Project/add_project_palette.dart   (ملف جديد)
//
// ده نفس الـ AppColors القديم اللي كان جوه app_theme.dart، بس دلوقتي ألوانه
// متوصلة بألوان التطبيق الرئيسية (core/theme/colors.dart) علشان الشاشة تطلع بنفس الشكل.
// مهم: الكلاس اسمه AppColors زي بتاع core، فمتعملش import للاتنين في نفس الملف.

import 'package:flutter/material.dart';
import 'package:proven/core/theme/colors.dart' as core;

abstract final class AppColors {
  static const background = core.AppColors.tertiary; // 0xFF0D1B29
  static const surface = core.AppColors.tertiaryContainer; // 0xFF23303F
  static const field = Color(0x9923303F); // tertiaryContainer بشفافية 60%
  static const border = Color(0x5973777F); // outline بشفافية 35%
  static const primary = core.AppColors.primaryContainer; // 0xFF003153
  static const primaryBright = core.AppColors.inversePrimary; // 0xFFA5CAF4
  static const text = Colors.white;
  static const muted = core.AppColors.onTertiaryContainer; // 0xFF8A98AA
  static const amber = Color(0xFFF1C65D);
  static const amberSurface = Color(0xFF211E18);
  static const success = Color(0xFF6DE0A2);
}