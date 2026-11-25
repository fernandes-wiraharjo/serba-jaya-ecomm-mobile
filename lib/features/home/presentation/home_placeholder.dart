import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:serba_jaya_mobile/features/auth/presentation/session_controller.dart';
import 'package:serba_jaya_mobile/l10n/generated/app_localizations.dart';
import 'package:serba_jaya_mobile/shared/widgets/feedback_panel.dart';

class HomePlaceholder extends ConsumerWidget {
  const HomePlaceholder({super.key, required this.onNotificationsRequested});

  final VoidCallback onNotificationsRequested;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    if (ref.watch(sessionProvider) case SessionGuest(clearFailed: true)) {
      return FeedbackPanel(
        message: strings.logoutError,
        onRetry: () => ref.read(sessionProvider.notifier).logout(),
      );
    }
    return SafeArea(
      child: Center(
        child: TextButton(
          onPressed: onNotificationsRequested,
          child: Text(strings.notifications),
        ),
      ),
    );
  }
}
