import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:serba_jaya_mobile/app/router/app_destination.dart';
import 'package:serba_jaya_mobile/app/theme/app_theme.dart';
import 'package:serba_jaya_mobile/l10n/generated/app_localizations.dart';

class LoginGate extends StatelessWidget {
  const LoginGate({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(strings.login)),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.page),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(strings.loginRequired, textAlign: TextAlign.center),
                const SizedBox(height: AppSpacing.page),
                TextButton(
                  onPressed: () => context.go(AppDestination.home.path),
                  child: Text(strings.backHome),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
