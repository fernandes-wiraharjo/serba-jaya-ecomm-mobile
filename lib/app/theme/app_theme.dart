import 'package:flutter/material.dart';

abstract final class AppColors {
  // Seed netral untuk pengujian; tidak mewakili palet merek.
  static const neutralSeed = Color(0xFF666666);

  // Figma Authentication (232:5150). These colors are feature scoped.
  static const authPrimary = Color(0xFFFF0000);
  static const authText = Color(0xFF333333);
  static const authSecondary = Color(0xFF858585);
  static const authField = Color(0xFFF8F9FB);
  static const authFieldBorder = Color(0xFFDDE1E6);
  static const authConnected = Color(0xFFEAF9E3);
  static const authConnectedText = Color(0xFF20251F);
  static const authSubtleOutline = Color(0x4DFF0000);

  // Values recorded for the Bottom Navigation Bar at Figma node 232:5152.
  static const navigationPrimary = Color(0xFFFF0000);
  static const navigationInactive = Color(0xFF858585);
  static const navigationSurface = Color(0xFFFFFFFF);
  static const navigationBadgeText = Color(0xFFFFFFFF);
  static const navigationCradle = Color(0xFFFCFBF8);
  static const navigationShadow = Color.fromRGBO(46, 38, 31, 0.07);
  static const chatButtonShadow = Color.fromRGBO(255, 0, 0, 0.23);

  static const headerHomeSurface = Color(0xFFFCFBF8);
  static const headerSurface = Color(0xFFFFFFFF);
  static const headerText = Color(0xFF333333);
  static const headerField = Color(0xFFF8F9FB);
  static const headerFieldBorder = Color(0xFFDDE1E6);
  static const headerClearSurface = Color.fromRGBO(0, 0, 0, 0.3);
}

abstract final class AppTypography {
  static TextTheme of(BuildContext context) => Theme.of(context).textTheme;

  static const _authFont = 'AuthRoboto';

  static const navigationLabel = TextStyle(
    fontFamily: 'SerbaRoboto',
    fontSize: 10,
    fontWeight: FontWeight.w500,
    height: 1.35,
  );

  static const navigationBadge = TextStyle(
    fontFamily: 'SerbaRoboto',
    fontSize: 8,
    fontWeight: FontWeight.w600,
    height: 1,
  );

  static const headerTitle = TextStyle(
    fontFamily: 'SerbaRoboto',
    fontSize: 18,
    fontWeight: FontWeight.w700,
    height: 21 / 18,
    color: AppColors.headerText,
  );

  static const headerSearch = TextStyle(
    fontFamily: 'SerbaRoboto',
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.headerText,
  );

  static const headerSearchHint = TextStyle(
    fontFamily: 'SerbaRoboto',
    fontSize: 16,
    fontWeight: FontWeight.w300,
    color: AppColors.navigationInactive,
  );

  static const headerBadge = TextStyle(
    fontFamily: 'SerbaRoboto',
    fontSize: 10,
    fontWeight: FontWeight.w500,
    height: 1,
    color: AppColors.navigationBadgeText,
  );

  static const authTitle = TextStyle(
    fontFamily: _authFont,
    letterSpacing: 0,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.4,
  );
  static const authHeading = TextStyle(
    fontFamily: _authFont,
    letterSpacing: 0,
    fontSize: 18,
    fontWeight: FontWeight.w700,
  );
  static const authDescription = TextStyle(
    fontFamily: _authFont,
    letterSpacing: 0,
    fontWeight: FontWeight.w400,
    color: AppColors.authSecondary,
    fontSize: 14,
    height: 1.4,
  );
  static const authCaption = TextStyle(
    fontFamily: _authFont,
    letterSpacing: 0,
    fontWeight: FontWeight.w400,
    color: AppColors.authSecondary,
    fontSize: 12,
    height: 1.4,
  );
  static const authLabel = TextStyle(
    fontFamily: _authFont,
    letterSpacing: 0,
    fontSize: 13,
    fontWeight: FontWeight.w700,
    height: 1.4,
  );
  static const authInput = TextStyle(
    fontFamily: _authFont,
    letterSpacing: 0,
    fontWeight: FontWeight.w400,
    fontSize: 16,
  );
  static const authPlaceholder = TextStyle(
    fontFamily: _authFont,
    letterSpacing: 0,
    color: AppColors.authSecondary,
    fontSize: 16,
    fontWeight: FontWeight.w300,
  );
}

abstract final class AppSpacing {
  static const small = 8.0;
  static const page = 16.0;
  static const large = 24.0;
  static const authLoginInset = 22.0;
  static const authFormInset = 20.0;
  static const authLogoGap = 40.0;
  static const authSectionGap = 26.0;
  static const authControlGap = 12.0;
  static const navigationIconLabel = 6.0;
}

abstract final class AppRadius {
  static const control = 8.0;
  static const authField = 12.0;
  static const authDialog = 20.0;
  static const navigationTop = 24.0;
}

abstract final class AppNavigationSize {
  static const barHeight = 90.0;
  static const slotWidth = 60.0;
  static const iconTop = 17.0;
  static const icon = 24.0;
  static const labelTop = iconTop + icon + AppSpacing.navigationIconLabel;
  static const chatButton = 56.0;
  static const chatLift = 20.0;
  static const chatCradle = 70.0;
  static const chatBrandingIcon = 31.0;
  static const cartImage = 30.0;
  static const badge = 14.0;
}

abstract final class AppHeaderSize {
  static const height = 55.0;
  static const actionBadge = 14.0;
  static const actionIcon = 24.0;
}

abstract final class AppTheme {
  static ThemeData authentication(ThemeData base) {
    final scheme = base.colorScheme.copyWith(
      primary: AppColors.authPrimary,
      surface: Colors.white,
      onSurface: AppColors.authText,
    );
    return base.copyWith(
      colorScheme: scheme,
      scaffoldBackgroundColor: Colors.white,
      textTheme: base.textTheme.apply(
        fontFamily: AppTypography._authFont,
        bodyColor: AppColors.authText,
        displayColor: AppColors.authText,
      ),
    );
  }

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
