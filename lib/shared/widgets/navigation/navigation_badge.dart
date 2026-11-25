import 'package:flutter/material.dart';
import 'package:serba_jaya_mobile/app/theme/app_theme.dart';

class NavigationBadge extends StatelessWidget {
  const NavigationBadge({super.key, required this.count, this.fontSize = 8});

  final int count;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();

    final label = count > 99 ? '99+' : '$count';
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.navigationPrimary,
        shape: BoxShape.circle,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: AppNavigationSize.badge,
          minHeight: AppNavigationSize.badge,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Center(
            child: Text(
              label,
              maxLines: 1,
              style:
                  (fontSize == 8
                          ? AppTypography.navigationBadge
                          : AppTypography.headerBadge)
                      .copyWith(color: AppColors.navigationBadgeText),
            ),
          ),
        ),
      ),
    );
  }
}
