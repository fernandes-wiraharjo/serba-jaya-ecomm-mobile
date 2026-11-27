import 'package:flutter/material.dart';

/// Applies Flutter's native bounce to all app scrollables.
class AppScrollBehavior extends MaterialScrollBehavior {
  const AppScrollBehavior({this.alwaysScrollable = false});

  /// Enable for surfaces that need a drag even when their content fits, such
  /// as a short list with pull-to-refresh.
  final bool alwaysScrollable;

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) => alwaysScrollable
      ? const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics())
      : const BouncingScrollPhysics();

  @override
  bool shouldNotify(covariant AppScrollBehavior oldDelegate) =>
      alwaysScrollable != oldDelegate.alwaysScrollable;

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) => child;
}
