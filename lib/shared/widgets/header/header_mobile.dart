import 'package:flutter/material.dart';
import 'package:serba_jaya_mobile/app/theme/app_assets.dart';
import 'package:serba_jaya_mobile/app/theme/app_theme.dart';
import 'package:serba_jaya_mobile/shared/widgets/header/header_action_button.dart';

/// Figma `Header Mobile` with the search and menu actions.
class HeaderMobile extends StatelessWidget {
  const HeaderMobile({super.key, this.onSearchTap, this.onMenuTap});

  final VoidCallback? onSearchTap;
  final VoidCallback? onMenuTap;

  @override
  Widget build(BuildContext context) => Container(
    height: AppHeaderSize.height,
    decoration: const BoxDecoration(
      color: AppColors.headerHomeSurface,
      boxShadow: [
        BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.15), blurRadius: 24),
      ],
    ),
    child: LayoutBuilder(
      builder: (context, constraints) => Stack(
        children: [
          const Positioned(
            left: 40,
            top: 7,
            child: Image(
              image: AssetImage(AppAssets.headerLogo),
              width: 43,
              height: 42,
              filterQuality: FilterQuality.high,
            ),
          ),
          Positioned(
            left: constraints.maxWidth - 92,
            top: 12,
            child: HeaderActionButton(
              assetPath: AppAssets.headerSearch,
              semanticLabel: 'Cari produk',
              width: 28,
              height: 28,
              surfaceColor: AppColors.headerHomeSurface,
              onPressed: onSearchTap,
            ),
          ),
          Positioned(
            right: 18,
            top: 14,
            child: HeaderActionButton(
              assetPath: AppAssets.headerMenu,
              semanticLabel: 'Menu',
              width: 24,
              height: 24,
              surfaceColor: AppColors.headerHomeSurface,
              onPressed: onMenuTap,
            ),
          ),
        ],
      ),
    ),
  );
}

/// Figma `Header Mobile` with cart and notification indicators.
class HeaderMobileActions extends StatelessWidget {
  const HeaderMobileActions({
    super.key,
    this.onCartTap,
    this.onNotificationsTap,
    this.cartCount = 0,
    this.notificationCount = 0,
  });

  final VoidCallback? onCartTap;
  final VoidCallback? onNotificationsTap;
  final int cartCount;
  final int notificationCount;

  @override
  Widget build(BuildContext context) => Container(
    height: AppHeaderSize.height,
    color: AppColors.headerHomeSurface,
    child: LayoutBuilder(
      builder: (context, constraints) => Stack(
        children: [
          const Positioned(
            left: 40,
            top: 7,
            child: Image(
              image: AssetImage(AppAssets.headerLogo),
              width: 43,
              height: 42,
              filterQuality: FilterQuality.high,
            ),
          ),
          Positioned(
            left: constraints.maxWidth - 86,
            top: 13,
            child: HeaderActionButton(
              assetPath: AppAssets.headerCartVector,
              semanticLabel: 'Keranjang',
              width: 29,
              height: 24,
              surfaceColor: AppColors.headerHomeSurface,
              isVectorAsset: true,
              assetBounds: const Rect.fromLTWH(0, 6, 22, 20),
              badgeCount: cartCount,
              badgeOffset: const Offset(15, 0),
              maskEmbeddedBadgeWhenZero: false,
              onPressed: onCartTap,
            ),
          ),
          Positioned(
            right: 22,
            top: 13,
            child: HeaderActionButton(
              assetPath: AppAssets.headerNotificationVector,
              semanticLabel: 'Notifikasi',
              width: 23,
              height: 24,
              surfaceColor: AppColors.headerHomeSurface,
              isVectorAsset: true,
              assetBounds: const Rect.fromLTWH(0, 6, 16, 20),
              badgeCount: notificationCount,
              badgeOffset: const Offset(9, 0),
              maskEmbeddedBadgeWhenZero: false,
              onPressed: onNotificationsTap,
            ),
          ),
        ],
      ),
    ),
  );
}
