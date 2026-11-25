import 'package:flutter/material.dart';
import 'package:serba_jaya_mobile/app/theme/app_theme.dart';
import 'package:serba_jaya_mobile/features/auth/presentation/widgets/auth_action_button.dart';
import 'package:serba_jaya_mobile/features/auth/presentation/widgets/auth_graphics.dart';
import 'package:serba_jaya_mobile/l10n/generated/app_localizations.dart';

Future<bool?> showLoginRequiredDialog(BuildContext context) => showDialog<bool>(
  context: context,
  useRootNavigator: true,
  barrierDismissible: true,
  barrierColor: Colors.black.withValues(alpha: 0.4),
  builder: (dialogContext) => LoginRequiredDialog(
    onClose: () => Navigator.of(dialogContext, rootNavigator: true).pop(false),
    onLogin: () => Navigator.of(dialogContext, rootNavigator: true).pop(true),
  ),
);

class LoginRequiredDialog extends StatelessWidget {
  const LoginRequiredDialog({
    super.key,
    required this.onClose,
    required this.onLogin,
  });

  final VoidCallback onClose;
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Theme(
      data: AppTheme.authentication(Theme.of(context)),
      child: Dialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        alignment: const Alignment(0, -.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.authDialog),
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        constraints: const BoxConstraints(maxWidth: 334),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(15, 9, 15, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: Transform.translate(
                  offset: const Offset(6, 0),
                  child: IconButton(
                    onPressed: onClose,
                    tooltip: strings.authClose,
                    icon: const AuthIcon(AuthAssets.close),
                  ),
                ),
              ),
              Image.asset(
                AuthAssets.alert,
                width: 159,
                height: 159,
                excludeFromSemantics: true,
              ),
              const SizedBox(height: AppSpacing.authLogoGap),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Column(
                  children: [
                    Text(
                      strings.authRequiredTitle,
                      style: AppTypography.authTitle,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.small),
                    Text(
                      strings.authDescription,
                      style: AppTypography.authDescription,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 35),
              AuthActionButton(label: strings.login, onPressed: onLogin),
            ],
          ),
        ),
      ),
    );
  }
}
