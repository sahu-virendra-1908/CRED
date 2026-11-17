import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTypography {
  static const TextStyle overlineCaps = TextStyle(
    fontSize: 10.5,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.4,
    color: AppColors.inkSecondary,
  );

  static const TextStyle heroAmountMajor = TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.8,
    color: AppColors.inkPrimary,
    height: 1.1,
  );

  static const TextStyle heroAmountMinor = TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.w300,
    letterSpacing: -0.6,
    color: AppColors.inkPrimary,
    height: 1.1,
  );

  static const TextStyle cardHolderName = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.5,
    color: Colors.white,
  );

  static const TextStyle cardDigits = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.4,
    color: Colors.white,
  );

  static const TextStyle actionLabel = TextStyle(
    fontSize: 11.5,
    fontWeight: FontWeight.w600,
    height: 1.25,
    color: AppColors.inkPrimary,
  );
}
