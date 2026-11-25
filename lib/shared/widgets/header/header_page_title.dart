import 'package:flutter/material.dart';
import 'package:serba_jaya_mobile/app/theme/app_assets.dart';
import 'package:serba_jaya_mobile/app/theme/app_theme.dart';
import 'package:serba_jaya_mobile/shared/widgets/header/header_action_button.dart';

class HeaderPageTitle extends StatelessWidget {
  const HeaderPageTitle({
    super.key,
    required this.title,
    this.onBack,
    this.onCartTap,
    this.cartCount = 0,
  });

  final String title;
  final VoidCallback? onBack;
  final VoidCallback? onCartTap;
  final int cartCount;

  @override
  Widget build(BuildContext context) => Container(
    height: AppHeaderSize.height,
    decoration: const BoxDecoration(
      color: AppColors.headerSurface,
      boxShadow: [
        BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.15), blurRadius: 24),
      ],
    ),
    child: LayoutBuilder(
      builder: (context, _) => Stack(
        children: [
          Positioned(
            left: 16,
            top: 15,
            child: HeaderActionButton(
              assetPath: AppAssets.headerBack,
              semanticLabel: 'Kembali',
              width: 24,
              height: 24,
              surfaceColor: AppColors.headerSurface,
              onPressed: onBack,
            ),
          ),
          Positioned(
            left: 44,
            top: 17,
            right: 58,
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.headerTitle,
            ),
          ),
          Positioned(
            right: 18,
            top: 14,
            child: HeaderActionButton(
              assetPath: AppAssets.headerPageCart,
              semanticLabel: 'Keranjang',
              width: 28,
              height: 23,
              surfaceColor: AppColors.headerSurface,
              badgeCount: cartCount,
              badgeOffset: const Offset(14, 0),
              onPressed: onCartTap,
            ),
          ),
        ],
      ),
    ),
  );
}
