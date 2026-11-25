import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:serba_jaya_mobile/app/theme/app_theme.dart';
import 'package:serba_jaya_mobile/features/auth/presentation/pages/login_page.dart';
import 'package:serba_jaya_mobile/features/auth/presentation/pages/registration_page.dart';
import 'package:serba_jaya_mobile/features/auth/presentation/widgets/auth_action_button.dart';
import 'package:serba_jaya_mobile/l10n/generated/app_localizations.dart';

void main() {
  testWidgets(
    'login shows only platform actions with no unused button space',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(320, 568);
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: const TextScaler.linear(1.4)),
              child: child!,
            ),
            home: LoginPage(onClose: () {}, onRegister: () {}),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final strings = AppLocalizations.of(
        tester.element(find.byType(LoginPage)),
      );
      final description = find.text(strings.authDescription);
      final google = find.widgetWithText(OutlinedButton, strings.authGoogle);
      final apple = find.widgetWithText(FilledButton, strings.authApple);
      final actions = find.byType(AuthActionButton, skipOffstage: false);
      expect(google, findsOneWidget);
      await tester.ensureVisible(google);
      await tester.pumpAndSettle();

      final descriptionEnd = tester.getBottomLeft(description).dy;
      final googleStart = tester.getTopLeft(google).dy;
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        expect(apple, findsOneWidget);
        expect(actions, findsNWidgets(2));
        expect(
          tester.getTopLeft(apple).dy - descriptionEnd,
          moreOrLessEquals(AppSpacing.authSectionGap),
        );
        expect(
          googleStart - tester.getBottomLeft(apple).dy,
          moreOrLessEquals(AppSpacing.authControlGap),
        );
      } else {
        expect(apple, findsNothing);
        expect(actions, findsOneWidget);
        expect(
          googleStart - descriptionEnd,
          moreOrLessEquals(AppSpacing.authSectionGap),
        );
      }
      expect(tester.takeException(), isNull);
    },
    variant: TargetPlatformVariant.all(),
  );

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
