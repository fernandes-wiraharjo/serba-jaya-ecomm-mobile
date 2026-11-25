import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:serba_jaya_mobile/shared/motion/app_motion.dart';

/// Animates a Material control's visual bounds without shrinking its hit area.
class AppPressFeedback extends StatefulWidget {
  const AppPressFeedback({super.key, required this.builder});

  final Widget Function(BuildContext, WidgetStatesController) builder;

  @override
  State<AppPressFeedback> createState() => _AppPressFeedbackState();
}

class _AppPressFeedbackState extends State<AppPressFeedback> {
  final _states = WidgetStatesController();
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _states.addListener(_handleStates);
  }

  void _handleStates() {
    final scheduler = SchedulerBinding.instance;
    if (scheduler.schedulerPhase == SchedulerPhase.persistentCallbacks) {
      // Material also updates the controller while rebuilding disabled buttons.
      scheduler.addPostFrameCallback((_) => _updatePressed());
    } else {
      _updatePressed();
    }
  }

  void _updatePressed() {
    if (!mounted) return;
    final states = _states.value;
    final pressed =
        states.contains(WidgetState.pressed) &&
        !states.contains(WidgetState.disabled);
    if (pressed != _pressed) setState(() => _pressed = pressed);
  }

  @override
  void dispose() {
    _states.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduced = AppMotion.reduced(context);
    return TweenAnimationBuilder<double>(
      tween: Tween(end: !reduced && _pressed ? AppMotion.pressedScale : 1),
      duration: reduced ? Duration.zero : AppMotion.press,
      curve: AppMotion.enter,
      child: widget.builder(context, _states),
      builder: (_, scale, child) =>
          Transform.scale(scale: scale, transformHitTests: false, child: child),
    );
  }
}
