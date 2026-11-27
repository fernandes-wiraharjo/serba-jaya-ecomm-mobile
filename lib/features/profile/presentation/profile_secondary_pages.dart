import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:serba_jaya_mobile/app/theme/app_theme.dart';
import 'package:serba_jaya_mobile/features/auth/presentation/widgets/auth_action_button.dart';
import 'package:serba_jaya_mobile/features/profile/presentation/profile_components.dart';
import 'package:serba_jaya_mobile/features/profile/presentation/profile_field.dart';
import 'package:serba_jaya_mobile/l10n/generated/app_localizations.dart';
import 'package:serba_jaya_mobile/shared/motion/app_overlays.dart';

class ProfileDeletePage extends StatefulWidget {
  const ProfileDeletePage({super.key});

  @override
  State<ProfileDeletePage> createState() => _ProfileDeletePageState();
}

class _ProfileDeletePageState extends State<ProfileDeletePage> {
  bool _consent = false;
  bool _showWarning = true;
  String _confirmation = '';

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);
    return ProfileScreen(
      title: s.profileDelete,
      children: [
        if (_showWarning) ...[
          DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0x1AFF8D28)),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                spacing: 6,
                children: [
                  const ProfileIcon('warning', size: 16),
                  Expanded(
                    child: Text(
                      s.profileDeleteWarning,
                      style: AppTypography.authCaption.copyWith(
                        color: const Color(0xFFFF8D28),
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: s.authClose,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 24,
                      minHeight: 38,
                    ),
                    onPressed: () => setState(() => _showWarning = false),
                    icon: const ProfileIcon('warning-close', size: 16),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
        Text(
          s.profileDeleteTitle,
          style: AppTypography.authTitle.copyWith(color: AppColors.authText),
        ),
        const SizedBox(height: 20),
        Text(
          s.profileDeleteIntro,
          style: AppTypography.authCaption.copyWith(
            fontSize: 14,
            color: const Color(0xFF687078),
          ),
        ),
        const SizedBox(height: 20),
        ProfileSurface(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 16,
            children: [
              for (final (label, description) in [
                (s.profileDeleteData, s.profileDeleteDataHint),
                (s.profileDeleteRewards, s.profileDeleteRewardsHint),
                (s.profileDeleteTransactions, s.profileDeleteTransactionsHint),
              ])
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 4,
                  children: [
                    Text(
                      label,
                      style: AppTypography.authTitle.copyWith(
                        fontSize: 15,
                        color: AppColors.authText,
                      ),
                    ),
                    Text(
                      description,
                      style: AppTypography.authCaption.copyWith(
                        fontSize: 13,
                        color: const Color(0xFF687078),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          s.profileDeleteIrreversible,
          style: AppTypography.authCaption.copyWith(
            color: const Color(0xFF687078),
          ),
        ),
        const SizedBox(height: 20),
        ProfileField(
          label: s.profileDeleteType,
          hint: s.profileConfirmWord,
          onChanged: (value) => setState(() => _confirmation = value.trim()),
        ),
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          value: _consent,
          title: Text(
            s.profileDeleteConsent,
            style: AppTypography.authCaption.copyWith(
              color: const Color(0xFF687078),
            ),
          ),
          onChanged: (value) => setState(() => _consent = value ?? false),
        ),
        AuthActionButton(
          label: s.profileKeepAccount,
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/profile'),
        ),
        const SizedBox(height: 20),
        AuthActionButton(
          label: s.profileDeletePermanent,
          filled: false,
          onPressed: !_consent || _confirmation != s.profileConfirmWord
              ? null
              : () async {
                  await showAppDialog<void>(
                    context: context,
                    builder: (dialog) => AlertDialog(
                      title: Text(s.profileDeleteConfirm),
                      content: Text(s.profileFeatureUnavailable),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialog),
                          child: Text(s.profileCancel),
                        ),
                      ],
                    ),
                  );
                },
        ),
      ],
    );
  }
}

enum ProfileRewardsView { points, vouchers, history }

class ProfileRewardsPage extends StatelessWidget {
  const ProfileRewardsPage({super.key, required this.view});

  final ProfileRewardsView view;

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);
    final history = view == ProfileRewardsView.history;
    final vouchers = view == ProfileRewardsView.vouchers;
    return ProfileScreen(
      title: history ? s.profilePointsHistory : s.profileRewards,
      headerBottom: history
          ? null
          : Material(
              color: Colors.white,
              child: Row(
                children: [
                  for (final (label, selected, route) in [
                    (s.profilePointsTab, !vouchers, 'profile-rewards'),
                    (s.profileVouchersTab, vouchers, 'profile-vouchers'),
                  ])
                    Expanded(
                      child: Semantics(
                        selected: selected,
                        button: true,
                        child: InkWell(
                          onTap: () {
                            if (!selected) context.replaceNamed(route);
                          },
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(minHeight: 50),
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    width: 4,
                                    color: selected
                                        ? AppColors.authPrimary
                                        : Colors.transparent,
                                  ),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 12,
                                ),
                                child: Center(
                                  child: Text(
                                    label,
                                    textAlign: TextAlign.center,
                                    style: AppTypography.authCaption.copyWith(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: selected
                                          ? AppColors.authPrimary
                                          : AppColors.authSecondary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
      children: [
        ProfileSurface(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 12,
            children: [
              if (history)
                const Center(child: ProfileIcon('points-empty', size: 72))
              else
                ProfileIcon(vouchers ? 'voucher' : 'points', size: 24),
              Text(
                vouchers ? s.profileVouchersTab : s.profilePointsHistory,
                style: AppTypography.authHeading,
              ),
              Text(s.profileFeatureUnavailable),
              if (view == ProfileRewardsView.points)
                AuthActionButton(
                  label: s.profilePointsHistory,
                  filled: false,
                  onPressed: () => context.pushNamed('profile-points-history'),
                ),
              if (!vouchers)
                AuthActionButton(
                  label: s.profileStartShopping,
                  onPressed: () => context.go('/'),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class ProfileMembershipPage extends StatelessWidget {
  const ProfileMembershipPage({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);
    return ProfileScreen(
      title: s.profileMembershipTitle,
      children: [
        Row(
          children: [
            for (final (index, step) in [
              s.profileUploadId,
              s.profileVerification,
              s.profileMembershipActive,
            ].indexed)
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: index == 2 ? 0 : 6),
                  child: Column(
                    spacing: 4,
                    children: [
                      Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: index == 0
                              ? const Color(0xFF00970E)
                              : const Color(0xFFCCCCCC),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      Text(
                        step,
                        textAlign: TextAlign.center,
                        style: AppTypography.authCaption,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 22),
        ProfileSurface(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12,
            children: [
              const Center(child: ProfileIcon('membership-upload')),
              Text(s.profileUploadId, style: AppTypography.authHeading),
              Text(s.profileFeatureUnavailable),
            ],
          ),
        ),
      ],
    );
  }
}
