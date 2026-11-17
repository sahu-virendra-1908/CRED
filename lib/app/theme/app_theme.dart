import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.canvasTop,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.inkPrimary,
        surface: AppColors.surfaceWhite,
        primary: AppColors.inkPrimary,
        error: AppColors.alertCoral,
      ),
      splashFactory: InkRipple.splashFactory,
      dividerTheme: const DividerThemeData(
        color: AppColors.borderSubtle,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
