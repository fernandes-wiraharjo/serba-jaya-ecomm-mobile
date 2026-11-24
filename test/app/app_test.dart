import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:serba_jaya_mobile/app/app.dart';
import 'package:serba_jaya_mobile/app/config/app_config.dart';
import 'package:serba_jaya_mobile/app/router/app_router.dart';
import 'package:serba_jaya_mobile/features/auth/domain/app_session.dart';
import 'package:serba_jaya_mobile/features/auth/presentation/session_controller.dart';

import '../support/fakes.dart';

void main() {
  Future<ProviderContainer> mount(
    WidgetTester tester,
    FakeSessionRepository repository,
  ) async {
    final container = ProviderContainer(
      overrides: [
        appConfigProvider.overrideWithValue(
          AppConfig.parse(environment: 'dev'),
        ),
        sessionRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const SerbaJayaApp(),
      ),
    );
    return container;
  }

  testWidgets('starts in Indonesian and navigates to public Chat', (
    tester,
  ) async {
    await mount(tester, FakeSessionRepository());
    await tester.pumpAndSettle();
    expect(find.text('Notifikasi'), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, 'Chat'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Kontak WhatsApp'), findsOneWidget);
  });

  testWidgets('deep link waits on initialization and redirects the guest', (
    tester,
  ) async {
    final pending = Completer<AppSession?>();
    final container = await mount(
      tester,
      FakeSessionRepository()..pendingRead = pending,
    );
    container.read(appRouterProvider).go('/orders');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(
      find.text('Halaman sementara untuk pengujian navigasi.'),
      findsNothing,
    );
    expect(
      container.read(appRouterProvider).routeInformationProvider.value.uri.path,
      '/session',
    );

    pending.complete(null);
    await tester.pumpAndSettle();
    expect(find.textContaining('Silakan masuk'), findsOneWidget);
    await tester.tap(find.text('Kembali ke beranda'));
    await tester.pumpAndSettle();
    expect(find.text('Notifikasi'), findsOneWidget);
    await tester.tap(find.text('Notifikasi'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Silakan masuk'), findsOneWidget);
  });

  test('expired credentials cannot open a protected route or resume it', () {
    final now = DateTime.utc(2026, 1);
    final state = SessionAuthenticated(
      AppSession(accessToken: 'expired-fixture', expiresAt: now),
    );
    String? redirect(String path) =>
        sessionRedirect(Uri.parse(path), state, now: now);
    final gate = redirect('/cart');
    expect(Uri.parse(gate!).path, '/login');
    expect(Uri.parse(gate).queryParameters['from'], '/cart');
    expect(redirect(gate), isNull);
  });

  test('redirect resumes only a known protected destination', () {
    final now = DateTime.utc(2026, 1);
    final session = SessionAuthenticated(
      AppSession(accessToken: 'fake', expiresAt: DateTime.utc(2026, 2)),
    );
    String? redirect(String url) =>
        sessionRedirect(Uri.parse(url), session, now: now);
    expect(redirect('/login?from=/cart'), '/cart');
    expect(redirect('/login?from=//outside.example.test'), '/');
    expect(redirect('/login?from=/orders%3Funexpected%3Dtrue'), '/');
  });
}
