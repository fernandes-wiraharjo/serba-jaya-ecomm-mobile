import 'package:flutter/material.dart';
import 'package:serba_jaya_mobile/app/router/app_destination.dart';
import 'package:serba_jaya_mobile/app/theme/app_theme.dart';
import 'package:serba_jaya_mobile/shared/widgets/header/app_header.dart';
import 'package:serba_jaya_mobile/shared/widgets/navigation/app_bottom_nav_bar.dart';

typedef AppHeaderBuilder =
    Widget? Function(
      BuildContext context,
      AppDestination? destination,
      Map<AppDestination, int> badgeCounts,
    );

class MainShell extends StatelessWidget {
  const MainShell({
    super.key,
    required this.destination,
    required this.child,
    required this.onDestinationSelected,
    this.headerBuilder,
    this.headerSurfaceColor = AppColors.headerSurface,
    this.badgeCounts = const {},
  });

  final AppDestination? destination;
  final Widget child;
  final ValueChanged<AppDestination> onDestinationSelected;
  final AppHeaderBuilder? headerBuilder;
  final Color headerSurfaceColor;
  final Map<AppDestination, int> badgeCounts;

  @override
  Widget build(BuildContext context) {
    final headerContent = headerBuilder?.call(
      context,
      destination,
      badgeCounts,
    );
    return Scaffold(
      body: Column(
        children: [
          if (headerContent != null)
            AppHeader(surfaceColor: headerSurfaceColor, child: headerContent),
          Expanded(
            child: headerContent == null
                ? child
                : MediaQuery.removePadding(
                    context: context,
                    removeTop: true,
                    child: child,
                  ),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentDestination: destination,
        badgeCounts: badgeCounts,
        onDestinationSelected: onDestinationSelected,
      ),
    );
  }
}
