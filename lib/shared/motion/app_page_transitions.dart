import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:serba_jaya_mobile/shared/motion/app_motion.dart';

enum AppPageMotion { standard, modal }

/// Uses Flutter's Cupertino parallax and iOS swipe with the app's route timing.
class AppTransitionPage<T> extends Page<T> {
  const AppTransitionPage({
    super.key,
    super.name,
    required this.child,
    this.motion = AppPageMotion.standard,
  });

  final Widget child;
  final AppPageMotion motion;

  @override
  Route<T> createRoute(BuildContext context) =>
      _AppPageRoute<T>(this, reduced: AppMotion.reduced(context));
}

class _AppPageRoute<T> extends PageRoute<T>
    with CupertinoRouteTransitionMixin<T> {
  _AppPageRoute(AppTransitionPage<T> page, {required this.reduced})
    : super(settings: page);

  static final _modalSlide = Tween(begin: const Offset(0, 1), end: Offset.zero);
  final bool reduced;

  AppTransitionPage<T> get _page => settings as AppTransitionPage<T>;
  bool get _vertical => _page.motion == AppPageMotion.modal;

  @override
  String? get title => null;

  @override
  bool get maintainState => true;

  @override
  Color? get barrierColor => null;

  @override
  Duration get transitionDuration => reduced ? Duration.zero : AppMotion.page;

  @override
  Duration get reverseTransitionDuration => reduced
      ? Duration.zero
      : _vertical
      ? AppMotion.page
      : AppMotion.pageReverse;

  @override
  bool canTransitionFrom(TransitionRoute<dynamic> previousRoute) =>
      !_vertical && super.canTransitionFrom(previousRoute);

  @override
  Widget buildContent(BuildContext context) => _page.child;

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final platform = defaultTargetPlatform;
    final disableMotion = reduced || AppMotion.reduced(context);
    final Widget transition;
    if (disableMotion) {
      transition = child;
    } else if (_vertical) {
      transition = SlideTransition(
        position: animation
            .drive(
              CurveTween(
                curve: popGestureInProgress ? Curves.linear : AppMotion.enter,
              ),
            )
            .drive(_modalSlide),
        child: CupertinoPageTransition(
          primaryRouteAnimation: kAlwaysCompleteAnimation,
          secondaryRouteAnimation: secondaryAnimation,
          linearTransition: popGestureInProgress,
          child: child,
        ),
      );
    } else if (platform == TargetPlatform.iOS) {
      transition = super.buildTransitions(
        context,
        animation,
        secondaryAnimation,
        child,
      );
    } else {
      transition = CupertinoPageTransition(
        primaryRouteAnimation: animation,
        secondaryRouteAnimation: secondaryAnimation,
        linearTransition: popGestureInProgress,
        child: child,
      );
    }
    return platform == TargetPlatform.android
        ? _AndroidBackGesture(route: this, child: transition)
        : transition;
  }
}

/// Forwards Android's gesture to Flutter's route controller without installing
/// a Cupertino edge recognizer on Android.
class _AndroidBackGesture extends StatefulWidget {
  const _AndroidBackGesture({required this.route, required this.child});

  final PageRoute<dynamic> route;
  final Widget child;

  @override
  State<_AndroidBackGesture> createState() => _AndroidBackGestureState();
}

class _AndroidBackGestureState extends State<_AndroidBackGesture>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  bool handleStartBackGesture(PredictiveBackEvent event) {
    final route = widget.route;
    if (event.isButtonEvent ||
        !route.isCurrent ||
        !route.popGestureEnabled ||
        !TickerMode.valuesOf(context).enabled) {
      return false;
    }
    // A current route inside a branch can still be covered by a root modal.
    var navigator = route.navigator;
    while (navigator != null) {
      final parentRoute = ModalRoute.of(navigator.context);
      if (parentRoute == null) break;
      if (!parentRoute.isCurrent) return false;
      navigator = parentRoute.navigator;
    }
    route.handleStartBackGesture(progress: 1 - event.progress);
    return true;
  }

  @override
  void handleUpdateBackGestureProgress(PredictiveBackEvent event) => widget
      .route
      .handleUpdateBackGestureProgress(progress: 1 - event.progress);

  @override
  void handleCancelBackGesture() => widget.route.handleCancelBackGesture();

  @override
  void handleCommitBackGesture() => widget.route.handleCommitBackGesture();

  @override
  Widget build(BuildContext context) => widget.child;
}
