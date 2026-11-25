import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:serba_jaya_mobile/app/router/app_destination.dart';
import 'package:serba_jaya_mobile/app/theme/app_assets.dart';
import 'package:serba_jaya_mobile/app/theme/app_theme.dart';
import 'package:serba_jaya_mobile/l10n/generated/app_localizations.dart';
import 'package:serba_jaya_mobile/shared/widgets/navigation/bottom_nav_item.dart';

class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    super.key,
    required this.currentDestination,
    required this.onDestinationSelected,
    this.badgeCounts = const {},
  });

  final AppDestination? currentDestination;
  final ValueChanged<AppDestination> onDestinationSelected;
  final Map<AppDestination, int> badgeCounts;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);

    return ColoredBox(
      color: AppColors.navigationSurface,
      child: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final slotWidth = math.min(
              AppNavigationSize.slotWidth,
              width * 0.18,
            );

            return Container(
              height: AppNavigationSize.barHeight,
              decoration: BoxDecoration(
                color: AppColors.navigationSurface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppRadius.navigationTop),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.navigationShadow,
                    offset: const Offset(0, -4),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: (width - AppNavigationSize.chatCradle) / 2,
                    top: -27,
                    // The light Figma cradle forms the rim around the button.
                    child: const DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.navigationCradle,
                        shape: BoxShape.circle,
                      ),
                      child: SizedBox.square(
                        dimension: AppNavigationSize.chatCradle,
                      ),
                    ),
                  ),
                  for (
                    var index = 0;
                    index < AppDestination.navigationTabs.length;
                    index++
                  )
                    _positionedItem(
                      context,
                      destination: AppDestination.navigationTabs[index],
                      slotWidth: slotWidth,
                      width: width,
                      strings: strings,
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _positionedItem(
    BuildContext context, {
    required AppDestination destination,
    required double slotWidth,
    required double width,
    required AppLocalizations strings,
  }) {
    final center = _centerFor(destination) * width;
    final selected = destination == currentDestination;
    final count = badgeCounts[destination] ?? 0;

    return Positioned(
      left: center - slotWidth / 2,
      top: 0,
      child: BottomNavItem(
        label: destination.label(strings),
        semanticsLabel: _semanticsLabel(strings, destination, count),
        width: slotWidth,
        inactiveIconAsset: _iconAsset(destination, selected: false),
        activeIconAsset: _iconAsset(destination, selected: true),
        selected: selected,
        badgeCount: count,
        isCenterAction: destination == AppDestination.chat,
        useWideIcon: destination == AppDestination.cart,
        isHome: destination == AppDestination.home,
        onTap: () => onDestinationSelected(destination),
      ),
    );
  }

  double _centerFor(AppDestination destination) => switch (destination) {
    AppDestination.home => 40 / 390,
    AppDestination.cart => 114 / 390,
    AppDestination.chat => 195 / 390,
    AppDestination.orders => 276 / 390,
    AppDestination.profile => 350 / 390,
    AppDestination.notifications => 0.5,
  };

  String? _iconAsset(AppDestination destination, {required bool selected}) =>
      switch ((destination, selected)) {
        (AppDestination.home, true) => AppAssets.navigationHomeActive,
        (AppDestination.home, false) => AppAssets.navigationHomeInactive,
        (AppDestination.cart, true) => AppAssets.navigationCartActive,
        (AppDestination.cart, false) => AppAssets.navigationCartInactive,
        (AppDestination.orders, true) => AppAssets.navigationOrdersActive,
        (AppDestination.orders, false) => AppAssets.navigationOrdersInactive,
        (AppDestination.profile, true) => AppAssets.navigationProfileActive,
        (AppDestination.profile, false) => AppAssets.navigationProfileInactive,
        (AppDestination.chat, _) => null,
        (AppDestination.notifications, _) => null,
      };

  String _semanticsLabel(
    AppLocalizations strings,
    AppDestination destination,
    int count,
  ) => count > 0
      ? strings.navigationBadgeSemantics(
          destination.label(strings),
          count > 99 ? '99+' : '$count',
        )
      : destination.label(strings);
}
