import 'package:flutter/material.dart';
import 'package:serba_jaya_mobile/features/auth/presentation/widgets/auth_graphics.dart';
import 'package:serba_jaya_mobile/l10n/generated/app_localizations.dart';

class AuthOnboardingPage extends StatelessWidget {
  const AuthOnboardingPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    body: SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: AuthLogo(
            size: const Size(217, 220),
            label: AppLocalizations.of(context).sessionLoading,
          ),
        ),
      ),
    ),
  );
}
