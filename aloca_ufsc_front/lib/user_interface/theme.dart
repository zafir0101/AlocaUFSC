import 'package:flutter/material.dart';

class AppColors {
    AppColors._();

    static const mainBlue = Color(0xFF1565C0);
    static const secondaryBlue = Color(0xFFE8F1FB);

    static const background = Color(0xFFFAFAF8);
    static const surface = Color(0xFFFFFFFF);
    static const surfaceAlt = Color(0xFFF2F4F2);
    static const border = Color(0xFFE7EAE7);

    static const textPrimary = Color(0xFF20261F);
    static const textSecondary = Color(0xFF8B928A);
}

ThemeData buildTheme() {
    final base = ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.mainBlue).copyWith(surface: AppColors.background),
        scaffoldBackgroundColor: AppColors.background
    );

    return base.copyWith(
    textTheme: base.textTheme.apply(
      bodyColor: AppColors.textPrimary,
      displayColor: AppColors.textPrimary,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      foregroundColor: AppColors.textPrimary,
    ),
  );
}
