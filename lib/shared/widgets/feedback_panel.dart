import 'package:flutter/material.dart';
import 'package:serba_jaya_mobile/app/theme/app_theme.dart';
import 'package:serba_jaya_mobile/core/errors/app_failure.dart';
import 'package:serba_jaya_mobile/l10n/generated/app_localizations.dart';

class FeedbackPanel extends StatelessWidget {
  const FeedbackPanel({
    super.key,
    this.message,
    this.loading = false,
    this.failure,
    this.onRetry,
  });

  final String? message;
  final bool loading;
  final FailureKind? failure;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final label =
        message ??
        (loading ? strings.sessionLoading : _failureLabel(strings, failure));

    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.page),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (loading) ...[
                  CircularProgressIndicator(semanticsLabel: label),
                  const SizedBox(height: AppSpacing.large),
                ],
                Text(
                  label,
                  style: AppTypography.of(context).bodyLarge,
                  textAlign: TextAlign.center,
                ),
                if (onRetry case final retry?) ...[
                  const SizedBox(height: AppSpacing.page),
                  FilledButton(onPressed: retry, child: Text(strings.retry)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _failureLabel(AppLocalizations strings, FailureKind? kind) =>
    switch (kind) {
      FailureKind.network => strings.offline,
      FailureKind.timeout => strings.timeout,
      FailureKind.cancelled => strings.cancelled,
      FailureKind.unauthorized => strings.unauthorized,
      FailureKind.forbidden => strings.forbidden,
      FailureKind.server => strings.serverError,
      FailureKind.invalidResponse => strings.invalidResponse,
      FailureKind.apiDisabled => strings.apiDisabled,
      FailureKind.unknown => strings.unknownError,
      null => strings.empty,
    };
