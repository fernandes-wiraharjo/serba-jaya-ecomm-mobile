import 'package:flutter/material.dart';
import 'package:serba_jaya_mobile/shared/motion/app_motion.dart';

Future<T?> showAppDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
  bool useRootNavigator = true,
}) async {
  final navigator = Navigator.of(context, rootNavigator: useRootNavigator);
  final route = _AppDialogRoute<T>(
    context: context,
    themes: InheritedTheme.capture(from: context, to: navigator.context),
    builder: builder,
    dismissible: barrierDismissible,
  );
  final result = await navigator.push(route);
  // A caller can open a new surface after the outgoing barrier has cleared.
  await route.completed;
  return result;
}

class _AppDialogRoute<T> extends RawDialogRoute<T> {
  _AppDialogRoute({
    required BuildContext context,
    required CapturedThemes themes,
    required WidgetBuilder builder,
    required bool dismissible,
  }) : _reverse = AppMotion.duration(context, AppMotion.dialogReverse),
       super(
         pageBuilder: (context, _, _) =>
             themes.wrap(SafeArea(child: Builder(builder: builder))),
         barrierDismissible: dismissible,
         barrierLabel: MaterialLocalizations.of(
           context,
         ).modalBarrierDismissLabel,
         barrierColor: AppMotion.barrierColor,
         traversalEdgeBehavior: TraversalEdgeBehavior.closedLoop,
         transitionDuration: AppMotion.duration(context, AppMotion.dialog),
         transitionBuilder: _dialogTransition,
       );

  final Duration _reverse;

  @override
  Duration get reverseTransitionDuration => _reverse;

  static final _scale = Tween(begin: AppMotion.dialogStartScale, end: 1.0);

  static Widget _dialogTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (AppMotion.reduced(context)) return child;
    final progress = animation.drive(CurveTween(curve: AppMotion.fade));
    return FadeTransition(
      opacity: progress,
      child: ScaleTransition(scale: progress.drive(_scale), child: child),
    );
  }
}

/// The caller supplies the radius specified for the sheet being presented.
Future<T?> showAppBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  required Radius topRadius,
  bool enableDrag = true,
  bool isDismissible = true,
}) => showModalBottomSheet<T>(
  context: context,
  useRootNavigator: true,
  useSafeArea: true,
  isScrollControlled: true,
  enableDrag: enableDrag,
  isDismissible: isDismissible,
  barrierColor: AppMotion.barrierColor,
  clipBehavior: Clip.antiAlias,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: topRadius),
  ),
  sheetAnimationStyle: AppMotion.reduced(context)
      ? AnimationStyle.noAnimation
      : const AnimationStyle(
          duration: AppMotion.sheet,
          reverseDuration: AppMotion.sheet,
        ),
  builder: (context) => Padding(
    padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
    child: SafeArea(top: false, child: Builder(builder: builder)),
  ),
);
