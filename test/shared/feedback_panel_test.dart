import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:serba_jaya_mobile/core/errors/app_failure.dart';
import 'package:serba_jaya_mobile/l10n/generated/app_localizations.dart';
import 'package:serba_jaya_mobile/shared/widgets/feedback_panel.dart';

void main() {
  testWidgets('shows empty state and localized error with working retry', (
    tester,
  ) async {
    Widget wrap(Widget child) => MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    );
    await tester.pumpWidget(wrap(const FeedbackPanel()));
    await tester.pumpAndSettle();
    expect(find.text('Belum ada data.'), findsOneWidget);

    var retries = 0;
    await tester.pumpWidget(
      wrap(
        FeedbackPanel(failure: FailureKind.network, onRetry: () => retries++),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Koneksi jaringan tidak tersedia.'), findsOneWidget);
    await tester.tap(find.text('Coba lagi'));
    expect(retries, 1);
  });
}
