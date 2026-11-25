import 'package:flutter/material.dart';
import 'package:serba_jaya_mobile/shared/motion/app_motion.dart';

/// Keeps each visited Navigator mounted and fades the new branch over the old.
class AppTabTransition extends StatefulWidget {
  const AppTabTransition({
    super.key,
    required this.index,
    required this.children,
  });

  final int index;
  final List<Widget> children;

  @override
  State<AppTabTransition> createState() => _AppTabTransitionState();
}

class _AppTabTransitionState extends State<AppTabTransition>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: AppMotion.tabs,
    value: 1,
  )..addStatusListener(_onStatus);
  late final _opacity = _controller.drive(CurveTween(curve: AppMotion.fade));
  int? _previous;

  void _onStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && _previous != null) {
      setState(() => _previous = null);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (AppMotion.reduced(context)) _controller.value = 1;
  }

  @override
  void didUpdateWidget(covariant AppTabTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.index == oldWidget.index || AppMotion.reduced(context)) return;
    _previous = oldWidget.index;
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final previous = _previous;
    final active = widget.index;
    return Stack(
      fit: StackFit.expand,
      children: [
        for (var index = 0; index < widget.children.length; index++)
          if (index != active && index != previous) _branch(index),
        if (previous != null) _branch(previous),
        _branch(active),
      ],
    );
  }

  Widget _branch(int index) {
    final active = index == widget.index;
    return Offstage(
      key: ValueKey(index),
      offstage: !active && index != _previous,
      child: TickerMode(
        enabled: active,
        child: ExcludeFocus(
          excluding: !active,
          child: ExcludeSemantics(
            excluding: !active,
            child: IgnorePointer(
              ignoring: !active,
              child: FadeTransition(
                opacity: active ? _opacity : kAlwaysCompleteAnimation,
                child: ColoredBox(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: widget.children[index],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
