import 'package:flutter/material.dart';

abstract final class AppColors {
  // Seed netral untuk pengujian; tidak mewakili palet merek.
  static const neutralSeed = Color(0xFF666666);
}

abstract final class AppTypography {
  static TextTheme of(BuildContext context) => Theme.of(context).textTheme;
}

abstract final class AppSpacing {
  static const small = 8.0;
  static const page = 16.0;
  static const large = 24.0;
}

abstract final class AppRadius {
  static const control = 8.0;
}

abstract final class AppTheme {
  static ThemeData get light => ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.neutralSeed),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.control),
        ),
      ),
    ),
  );
}
