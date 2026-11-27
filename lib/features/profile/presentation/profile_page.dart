import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:serba_jaya_mobile/app/theme/app_theme.dart';
import 'package:serba_jaya_mobile/features/auth/presentation/session_controller.dart';
import 'package:serba_jaya_mobile/features/auth/presentation/widgets/auth_action_button.dart';
import 'package:serba_jaya_mobile/features/auth/presentation/widgets/auth_graphics.dart';
import 'package:serba_jaya_mobile/features/profile/presentation/profile_components.dart';
import 'package:serba_jaya_mobile/features/profile/presentation/profile_controller.dart';
import 'package:serba_jaya_mobile/features/profile/presentation/profile_logout_dialog.dart';
import 'package:serba_jaya_mobile/l10n/generated/app_localizations.dart';
import 'package:serba_jaya_mobile/shared/motion/app_overlays.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = AppLocalizations.of(context);
    final profile = ref.watch(profileControllerProvider);
    final sessionState = ref.watch(sessionProvider);
    final signedIn =
        sessionState is SessionAuthenticated &&
        sessionState.session.isUsableAt(ref.read(sessionClockProvider)());

    void open(String screen) => context.pushNamed(screen);

    return Theme(
      data: AppTheme.authentication(Theme.of(context)),
      child: ColoredBox(
        color: profileBackground,
        child: SafeArea(
          bottom: false,
          child: ListView(
            primary: false,
            key: const PageStorageKey<String>('profile-content'),
            padding: const EdgeInsets.fromLTRB(22, 24, 22, 28),
            children: [
              Text(
                s.profile,
                style: AppTypography.authTitle.copyWith(
                  fontSize: 26,
                  color: AppColors.authText,
                ),
              ),
              const SizedBox(height: 20),
              ProfileSurface(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 14,
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 32,
                          backgroundColor: profileBackground,
                          child: AuthIcon(AuthAssets.photo, size: 40),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            profile.name.isEmpty
                                ? s.profileNoData
                                : profile.name,
                            style: AppTypography.authHeading.copyWith(
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 4,
                      children: [
                        Text(
                          profile.email.isEmpty
                              ? s.profileNoData
                              : profile.email,
                          style: AppTypography.authCaption.copyWith(
                            fontSize: 14,
                            color: AppColors.authText,
                          ),
                        ),
                        Text(
                          profile.phone.isEmpty
                              ? s.profileNoData
                              : profile.phone,
                          style: AppTypography.authCaption.copyWith(
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    AuthActionButton(
                      label: s.profileEditAction,
                      filled: false,
                      onPressed: () => open('profile-edit'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _Benefit(
                      icon: 'points',
                      label: s.profilePoints,
                      onTap: () => open('profile-rewards'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _Benefit(
                      icon: 'voucher',
                      label: s.profileVoucher,
                      onTap: () => open('profile-vouchers'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ProfileSurface(
                color: const Color(0xFFFFF5EC),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 10,
                  children: [
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          child: Text(
                            s.profileMembership,
                            style: AppTypography.authCaption.copyWith(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFFFF8D28),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Text(
                      s.profileJoinTitle,
                      style: AppTypography.authTitle.copyWith(
                        fontSize: 20,
                        color: AppColors.authText,
                      ),
                    ),
                    Text(
                      s.profileJoinHint,
                      style: AppTypography.authCaption.copyWith(fontSize: 13),
                    ),
                    AuthActionButton(
                      label: s.profileJoin,
                      filledColor: const Color(0xFFFF8D28),
                      onPressed: () => open('profile-membership'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                s.profilePreferences,
                style: AppTypography.authTitle.copyWith(
                  fontSize: 16,
                  color: AppColors.authText,
                ),
              ),
              const SizedBox(height: 20),
              ProfileSurface(
                child: Column(
                  spacing: 22,
                  children: [
                    _MenuItem(
                      icon: 'address',
                      title: s.profileAddressMenu,
                      subtitle: s.profileAddressHint,
                      onTap: () => open('profile-addresses'),
                    ),
                    _MenuItem(
                      icon: 'gift',
                      title: s.profileRewardsMenu,
                      subtitle: s.profileRewardsHint,
                      onTap: () => open('profile-rewards'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ProfileSurface(
                child: Column(
                  spacing: 22,
                  children: [
                    if (signedIn)
                      _MenuItem(
                        icon: 'logout',
                        title: s.profileLogout,
                        onTap: () => _logout(context, ref),
                      ),
                    _MenuItem(
                      icon: 'delete',
                      title: s.profileDeleteAction,
                      destructive: true,
                      onTap: () => open('profile-delete'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  s.profileFooter(
                    const String.fromEnvironment(
                      'APP_DISPLAY_VERSION',
                      defaultValue: '0.1.0',
                    ),
                  ),
                  style: AppTypography.authCaption.copyWith(
                    fontSize: 11,
                    color: const Color(0xFF687078),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showAppDialog<bool>(
      context: context,
      builder: (dialog) => ProfileLogoutDialog(
        onCancel: () => Navigator.pop(dialog, false),
        onConfirm: () => Navigator.pop(dialog, true),
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final controller = ref.read(sessionProvider.notifier);
    context.go('/');
    await controller.logout();
  }
}

class _Benefit extends StatelessWidget {
  const _Benefit({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final String icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    child: InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: ProfileSurface(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 4,
          children: [
            ProfileIcon(icon, size: 24),
            ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 31),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  AppLocalizations.of(context).profileNoData,
                  style: AppTypography.authCaption.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.authText,
                  ),
                ),
              ),
            ),
            Text(label, style: AppTypography.authCaption),
          ],
        ),
      ),
    ),
  );
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.destructive = false,
  });

  final String icon;
  final String title;
  final String? subtitle;
  final bool destructive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: onTap,
      child: Row(
        spacing: 10,
        children: [
          ProfileIcon(icon),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: [
                Text(
                  title,
                  style: AppTypography.authCaption.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: destructive
                        ? AppColors.authPrimary
                        : AppColors.authText,
                  ),
                ),
                if (subtitle case final description?)
                  Text(description, style: AppTypography.authCaption),
              ],
            ),
          ),
          const ProfileIcon('chevron'),
        ],
      ),
    ),
  );
}
