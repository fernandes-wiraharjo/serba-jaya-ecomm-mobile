import 'package:flutter/material.dart';
import 'package:serba_jaya_mobile/app/theme/app_theme.dart';
import 'package:serba_jaya_mobile/features/auth/presentation/widgets/auth_action_button.dart';
import 'package:serba_jaya_mobile/features/auth/presentation/widgets/auth_graphics.dart';
import 'package:serba_jaya_mobile/features/profile/presentation/profile_components.dart';
import 'package:serba_jaya_mobile/l10n/generated/app_localizations.dart';

class ProfileLogoutDialog extends StatelessWidget {
  const ProfileLogoutDialog({
    super.key,
    required this.onCancel,
    required this.onConfirm,
  });

  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Theme(
      data: AppTheme.authentication(Theme.of(context)),
      child: Dialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        constraints: const BoxConstraints(maxWidth: 334),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 10, 28, 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: Transform.translate(
                  offset: const Offset(19, 0),
                  child: IconButton(
                    onPressed: onCancel,
                    tooltip: strings.authClose,
                    icon: const AuthIcon(AuthAssets.close),
                  ),
                ),
              ),
              const ProfileIcon('door', size: 159),
              const SizedBox(height: 29),
              Text(
                strings.profileLogoutTitle,
                style: AppTypography.authTitle.copyWith(
                  fontSize: 24,
                  color: AppColors.authText,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                strings.profileLogoutHint,
                style: AppTypography.authCaption.copyWith(fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 42),
              Row(
                spacing: 5,
                children: [
                  Expanded(
                    child: AuthActionButton(
                      label: strings.profileCancel,
                      filled: false,
                      onPressed: onCancel,
                    ),
                  ),
                  Expanded(
                    child: AuthActionButton(
                      label: strings.profileLogoutConfirm,
                      onPressed: onConfirm,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
