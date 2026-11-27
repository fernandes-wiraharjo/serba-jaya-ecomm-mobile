import 'package:flutter/material.dart';
import 'package:serba_jaya_mobile/app/theme/app_assets.dart';
import 'package:serba_jaya_mobile/app/theme/app_theme.dart';
import 'package:serba_jaya_mobile/shared/widgets/header/app_search_field.dart';
import 'package:serba_jaya_mobile/shared/widgets/header/header_action_button.dart';

class HeaderSearch extends StatelessWidget {
  const HeaderSearch({
    super.key,
    this.query = '',
    this.onBack,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.onCartTap,
    this.cartCount = 0,
  });

  final String query;
  final VoidCallback? onBack;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
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
            right: 59,
            top: 9,
            child: AppSearchField(
              query: query,
              onChanged: onChanged,
              onSubmitted: onSubmitted,
              onClear: onClear,
            ),
          ),
          Positioned(
            right: 20,
            top: 14,
            child: HeaderActionButton(
              assetPath: AppAssets.headerPageCart,
              semanticLabel: 'Keranjang',
              width: 28,
              height: 23,
              surfaceColor: AppColors.headerSurface,
              badgeCount: cartCount,
              assetBounds: const Rect.fromLTWH(0, 4.25, 21.75, 19.75),
              badgeOffset: const Offset(14, 0),
              maskEmbeddedBadgeWhenZero: false,
              onPressed: onCartTap,
            ),
          ),
        ],
      ),
    ),
  );
}
