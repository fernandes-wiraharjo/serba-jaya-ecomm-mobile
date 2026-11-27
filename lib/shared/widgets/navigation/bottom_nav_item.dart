import 'package:flutter/material.dart';
import 'package:serba_jaya_mobile/app/theme/app_assets.dart';
import 'package:serba_jaya_mobile/app/theme/app_theme.dart';
import 'package:serba_jaya_mobile/shared/widgets/navigation/navigation_badge.dart';

class BottomNavItem extends StatelessWidget {
  const BottomNavItem({
    super.key,
    required this.label,
    required this.semanticsLabel,
    required this.width,
    required this.inactiveIconAsset,
    required this.activeIconAsset,
    required this.selected,
    required this.onTap,
    this.badgeCount = 0,
    this.isCenterAction = false,
    this.useWideIcon = false,
    this.isHome = false,
  });

  final String label;
  final String semanticsLabel;
  final double width;
  final String? inactiveIconAsset;
  final String? activeIconAsset;
  final bool selected;
  final VoidCallback onTap;
  final int badgeCount;
  final bool isCenterAction;
  final bool useWideIcon;
  final bool isHome;

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? AppColors.navigationPrimary
        : AppColors.navigationInactive;

    return Semantics(
      button: true,
      selected: selected,
      label: semanticsLabel,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            width: width,
            height: AppNavigationSize.barHeight,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topCenter,
              children: [
                if (isCenterAction)
                  Positioned(
                    left: (width - AppNavigationSize.chatButton) / 2,
                    top: -AppNavigationSize.chatLift,
                    child: _chatButton,
                  )
                else
                  Positioned(
                    left: (width - AppNavigationSize.icon) / 2,
                    top: AppNavigationSize.iconTop - (useWideIcon ? 3 : 0),
                    child: _icon,
                  ),
                Positioned(
                  top: AppNavigationSize.labelTop,
                  left: 0,
                  right: 0,
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: AppTypography.navigationLabel.copyWith(
                      color: color,
                      fontWeight: selected && isHome
                          ? FontWeight.w600
                          : FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget get _icon {
    final frameWidth = useWideIcon
        ? AppNavigationSize.cartImage
        : AppNavigationSize.icon;

    return SizedBox(
      width: useWideIcon ? AppNavigationSize.cartImage : AppNavigationSize.icon,
      height: useWideIcon
          ? AppNavigationSize.cartImage
          : AppNavigationSize.icon,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            top: 0,
            width: frameWidth,
            height: frameWidth,
            child: Image.asset(
              selected ? activeIconAsset! : inactiveIconAsset!,
              fit: BoxFit.fill,
              filterQuality: FilterQuality.high,
            ),
          ),
          if (useWideIcon && badgeCount > 0)
            Positioned(
              top: 0,
              left: 15,
              child: ExcludeSemantics(
                child: NavigationBadge(count: badgeCount),
              ),
            )
          else if (badgeCount > 0)
            Positioned(
              top: -5,
              right: -7,
              child: ExcludeSemantics(
                child: NavigationBadge(count: badgeCount),
              ),
            ),
        ],
      ),
    );
  }

  Widget get _chatButton => Container(
    width: AppNavigationSize.chatButton,
    height: AppNavigationSize.chatButton,
    decoration: BoxDecoration(
      color: AppColors.navigationPrimary,
      shape: BoxShape.circle,
      boxShadow: [
        BoxShadow(
          color: AppColors.chatButtonShadow,
          offset: const Offset(0, 5),
          blurRadius: 10,
        ),
      ],
    ),
    alignment: Alignment.center,
    child: Image.asset(
      AppAssets.navigationChatBranding,
      width: AppNavigationSize.chatBrandingIcon,
      height: AppNavigationSize.chatBrandingIcon,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
    ),
  );
}
