import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:serba_jaya_mobile/app/theme/app_theme.dart';
import 'package:serba_jaya_mobile/shared/widgets/header/app_header.dart';
import 'package:serba_jaya_mobile/shared/widgets/header/header_action_button.dart';
import 'package:serba_jaya_mobile/app/theme/app_assets.dart';
import 'package:serba_jaya_mobile/l10n/generated/app_localizations.dart';

const profileBackground = Color(0xFFF7F7F9);

class ProfileSurface extends StatelessWidget {
  const ProfileSurface({
    super.key,
    required this.child,
    this.color = Colors.white,
    this.padding = const EdgeInsets.all(18),
  });

  final Widget child;
  final Color color;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Padding(padding: padding, child: child),
  );
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    super.key,
    required this.title,
    required this.children,
    this.headerBottom,
  });

  final String title;
  final List<Widget> children;
  final Widget? headerBottom;

  @override
  Widget build(BuildContext context) => Theme(
    data: AppTheme.authentication(Theme.of(context)),
    child: Scaffold(
      backgroundColor: profileBackground,
      body: Column(
        children: [
          AppHeader(
            child: Material(
              elevation: 3,
              color: AppColors.headerSurface,
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  HeaderActionButton(
                    assetPath: AppAssets.headerBack,
                    semanticLabel: AppLocalizations.of(context).authBack,
                    width: 24,
                    height: 24,
                    surfaceColor: AppColors.headerSurface,
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/profile');
                      }
                    },
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.headerTitle,
                    ),
                  ),
                ],
              ),
            ),
          ),
          ?headerBottom,
          Expanded(
            child: SafeArea(
              top: false,
              child: ListView(
                primary: false,
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(22, 24, 22, 24),
                children: children,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class ProfileIcon extends StatelessWidget {
  const ProfileIcon(this.name, {super.key, this.size = 22});

  final String name;
  final double size;

  @override
  Widget build(BuildContext context) => Image.asset(
    'assets/auth/profile-$name.webp',
    width: size,
    height: size,
    excludeFromSemantics: true,
  );
}
