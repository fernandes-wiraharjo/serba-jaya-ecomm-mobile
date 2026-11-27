import 'package:flutter/material.dart';
import 'package:serba_jaya_mobile/app/theme/app_theme.dart';
import 'package:serba_jaya_mobile/shared/widgets/navigation/navigation_badge.dart';

class HeaderActionButton extends StatelessWidget {
  const HeaderActionButton({
    super.key,
    required this.assetPath,
    required this.semanticLabel,
    required this.width,
    required this.height,
    required this.surfaceColor,
    this.assetBounds,
    this.onPressed,
    this.badgeCount,
    this.badgeOffset,
    this.maskEmbeddedBadgeWhenZero = true,
    this.badgeFontSize = 10,
  });

  final String assetPath;
  final String semanticLabel;
  final double width;
  final double height;
  final Color surfaceColor;
  final Rect? assetBounds;
  final VoidCallback? onPressed;
  final int? badgeCount;
  final Offset? badgeOffset;
  final bool maskEmbeddedBadgeWhenZero;
  final double badgeFontSize;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: onPressed != null,
      label: semanticLabel,
      child: Material(
        color: Colors.transparent,
        child: InkResponse(
          onTap: onPressed,
          containedInkWell: true,
          highlightShape: BoxShape.circle,
          child: SizedBox(
            width: width,
            height: height,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fromRect(
                  rect: assetBounds ?? (Offset.zero & Size(width, height)),
                  child: Image.asset(
                    assetPath,
                    fit: BoxFit.fill,
                    filterQuality: FilterQuality.high,
                  ),
                ),
                if (badgeOffset case final offset?
                    when (badgeCount ?? 0) > 0 || maskEmbeddedBadgeWhenZero)
                  _positionedBadge(offset),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _positionedBadge(Offset offset) {
    final hasCount = badgeCount != null && badgeCount! > 0;
    final maskInset = hasCount ? 0.0 : 1.0;
    final diameter = AppHeaderSize.actionBadge + (hasCount ? 0 : 2);

    return Positioned(
      left: offset.dx - maskInset,
      top: offset.dy - maskInset,
      child: SizedBox.square(
        dimension: diameter,
        child: hasCount
            ? ExcludeSemantics(
                child: NavigationBadge(
                  count: badgeCount!,
                  fontSize: badgeFontSize,
                ),
              )
            : DecoratedBox(
                decoration: BoxDecoration(
                  color: surfaceColor,
                  shape: BoxShape.circle,
                ),
              ),
      ),
    );
  }
}
