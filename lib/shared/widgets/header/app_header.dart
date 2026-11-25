import 'package:flutter/material.dart';
import 'package:serba_jaya_mobile/app/theme/app_theme.dart';

/// Shared status-bar boundary for the verified 55 px Header variants.
class AppHeader extends StatelessWidget {
  const AppHeader({
    super.key,
    required this.child,
    this.surfaceColor = AppColors.headerSurface,
  });

  final Widget child;
  final Color surfaceColor;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: surfaceColor,
    child: SafeArea(
      top: true,
      bottom: false,
      child: SizedBox(
        width: double.infinity,
        height: AppHeaderSize.height,
        child: child,
      ),
    ),
  );
}
