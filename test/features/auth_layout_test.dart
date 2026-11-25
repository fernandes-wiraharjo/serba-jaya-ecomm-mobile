import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:serba_jaya_mobile/features/auth/presentation/pages/registration_page.dart';
import 'package:serba_jaya_mobile/l10n/generated/app_localizations.dart';

void main() {
  testWidgets('linked-email registration scrolls at larger text sizes', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 568);
    addTearDown(tester.view.reset);
    var cancelled = false;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(1.4)),
          child: child!,
        ),
        home: RegistrationPage(
          onCancel: () => cancelled = true,
          providerEmail: 'linked@example.test',
        ),
      ),
    );
    await tester.pumpAndSettle();

    final linkedEmail = find.text('linked@example.test');
    await tester.ensureVisible(linkedEmail);
    expect(linkedEmail, findsOneWidget);
    expect(find.byKey(const ValueKey('registration-email')), findsNothing);

    final cancel = find.widgetWithText(OutlinedButton, 'Batal');
    await tester.ensureVisible(cancel);
    await tester.pumpAndSettle();
    await tester.tap(cancel);
    expect(cancelled, isTrue);
    expect(tester.takeException(), isNull);
  });
}
