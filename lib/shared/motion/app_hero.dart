import 'package:flutter/material.dart';
import 'package:serba_jaya_mobile/shared/motion/app_motion.dart';

/// Match both values on the destination. [source] must identify the occurrence
/// within a route (including the section if the same item appears twice).
typedef AppHeroTag = ({String source, Object itemId});

class AppHero extends StatelessWidget {
  const AppHero({super.key, required this.tag, required this.child});

  final AppHeroTag tag;
  final Widget child;

  @override
  Widget build(BuildContext context) => HeroMode(
    enabled: !AppMotion.reduced(context),
    child: Hero(tag: tag, child: child),
  );
}
