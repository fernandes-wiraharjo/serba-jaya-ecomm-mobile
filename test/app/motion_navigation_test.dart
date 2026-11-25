import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:serba_jaya_mobile/app/app.dart';
import 'package:serba_jaya_mobile/app/config/app_config.dart';
import 'package:serba_jaya_mobile/app/router/app_router.dart';
import 'package:serba_jaya_mobile/app/shell/main_shell.dart';
import 'package:serba_jaya_mobile/features/auth/domain/app_session.dart';
import 'package:serba_jaya_mobile/features/auth/presentation/pages/login_page.dart';
import 'package:serba_jaya_mobile/features/auth/presentation/pages/registration_page.dart';
import 'package:serba_jaya_mobile/features/auth/presentation/session_controller.dart';
import 'package:serba_jaya_mobile/features/auth/presentation/widgets/login_required_dialog.dart';
import 'package:serba_jaya_mobile/features/home/presentation/home_placeholder.dart';

import '../support/fakes.dart';

void main() {
  testWidgets('tabs fade only the body and retain the Home element', (
    tester,
  ) async {
    await _mount(tester);
    final home = tester.element(find.byType(HomePlaceholder));
    final shell = tester.element(find.byType(MainShell));
    await tester.tap(find.text('Chat'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 90));
    expect(find.byType(HomePlaceholder), findsOneWidget);
    expect(find.textContaining('Kontak WhatsApp'), findsOneWidget);
    expect(tester.element(find.byType(MainShell)), same(shell));
    await tester.pumpAndSettle();
    expect(find.byType(HomePlaceholder), findsNothing);

    await tester.tap(find.text('Beranda'));
    await tester.pumpAndSettle();
    expect(tester.element(find.byType(HomePlaceholder)), same(home));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'notifications retains its branch stack and Android Back pops it',
    (tester) async {
      final container = await _mount(tester, authenticated: true);
      final router = container.read(appRouterProvider);
      await tester.tap(find.widgetWithText(TextButton, 'Notifikasi'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 90));
      expect(find.byType(HomePlaceholder), findsOneWidget);
      expect(tester.getTopLeft(find.byType(HomePlaceholder)).dx, lessThan(0));
      await tester.pumpAndSettle();
      expect(router.state.uri.path, '/notifications');

      await tester.tap(find.text('Chat'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Beranda'));
      await tester.pumpAndSettle();
      expect(router.state.uri.path, '/notifications');

      expect(await tester.binding.handlePopRoute(), isTrue);
      await tester.pumpAndSettle();
      expect(router.state.uri.path, '/');
      expect(find.byType(HomePlaceholder), findsOneWidget);
    },
  );

  testWidgets(
    'login slides over Chat and iOS swipe pops registration once',
    (tester) async {
      final container = await _mount(tester);
      final router = container.read(appRouterProvider);
      await tester.tap(find.text('Chat'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Keranjang'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Masuk'));
      for (
        var frame = 0;
        frame < 30 && find.byType(LoginPage).evaluate().isEmpty;
        frame++
      ) {
        await tester.pump(const Duration(milliseconds: 16));
      }
      expect(find.byType(LoginRequiredDialog), findsNothing);
      expect(tester.getTopLeft(find.byType(LoginPage)).dy, greaterThan(0));
      expect(find.textContaining('Kontak WhatsApp'), findsOneWidget);
      await tester.pumpAndSettle();

      final register = find.widgetWithText(
        TextButton,
        'Belum memiliki akun? Daftar',
      );
      final action = tester.widget<TextButton>(register).onPressed!;
      action();
      action();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 80));
      expect(
        tester.getTopLeft(find.byType(RegistrationPage)).dx,
        greaterThan(0),
      );
      expect(tester.getTopLeft(find.byType(LoginPage)).dx, lessThan(0));
      await tester.pumpAndSettle();
      expect(router.state.uri.path, '/login/register');
      expect(router.state.uri.queryParameters['from'], '/cart');

      await tester.dragFrom(const Offset(3, 240), const Offset(620, 0));
      await tester.pumpAndSettle();
      expect(router.state.uri.path, '/login');
      expect(router.state.uri.queryParameters['from'], '/cart');
      await tester.tap(find.byTooltip('Tutup'));
      await tester.pumpAndSettle();
      expect(router.state.uri.path, '/chat');
      expect(find.textContaining('Kontak WhatsApp'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.iOS),
  );

  testWidgets(
    'Android predictive back previews and pops a branch route',
    (tester) async {
      final container = await _mount(tester, authenticated: true);
      final router = container.read(appRouterProvider);
      router.go('/notifications');
      await tester.pumpAndSettle();
      expect(await _backGesture(tester, 'startBackGesture', .05), isTrue);
      await _backGesture(tester, 'updateBackGestureProgress', .5);
      await tester.pump();
      expect(find.byType(HomePlaceholder), findsOneWidget);

      await _backGesture(tester, 'cancelBackGesture');
      await tester.pumpAndSettle();
      expect(router.state.uri.path, '/notifications');

      expect(await _backGesture(tester, 'startBackGesture', .05), isTrue);
      await _backGesture(tester, 'updateBackGestureProgress', .55);
      await _backGesture(tester, 'commitBackGesture');
      await tester.pumpAndSettle();
      expect(router.state.uri.path, '/');
    },
    variant: TargetPlatformVariant.only(TargetPlatform.android),
  );

  testWidgets('session refresh resumes a pushed login destination', (
    tester,
  ) async {
    final container = await _mount(tester);
    final router = container.read(appRouterProvider);
    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Masuk'));
    await tester.pumpAndSettle();
    expect(router.state.uri.path, '/login');
    expect(router.state.uri.queryParameters['from'], '/profile');

    await container.read(sessionRepositoryProvider).write(_testSession());
    container.invalidate(sessionProvider);
    await tester.pumpAndSettle();
    expect(router.state.uri.path, '/profile');
    expect(find.byType(LoginPage), findsNothing);
    expect(find.text('Keluar'), findsOneWidget);

    await tester.tap(find.text('Chat'));
    await tester.pumpAndSettle();
    await container.read(sessionProvider.notifier).logout();
    await tester.pumpAndSettle();
    expect(find.text('Keluar', skipOffstage: false), findsNothing);
    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();
    expect(find.byType(LoginRequiredDialog), findsOneWidget);
  });
}

Future<ProviderContainer> _mount(
  WidgetTester tester, {
  bool authenticated = false,
}) async {
  final repository = FakeSessionRepository();
  if (authenticated) repository.session = _testSession();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appConfigProvider.overrideWithValue(
          AppConfig.parse(environment: 'dev'),
        ),
        sessionRepositoryProvider.overrideWithValue(repository),
        sessionValidatorProvider.overrideWithValue((_) async => true),
        sessionClockProvider.overrideWithValue(() => DateTime.utc(2026)),
      ],
      child: const SerbaJayaApp(),
    ),
  );
  await tester.pumpAndSettle();
  return ProviderScope.containerOf(tester.element(find.byType(SerbaJayaApp)));
}

AppSession _testSession() =>
    AppSession(accessToken: 'session-fixture', expiresAt: DateTime.utc(2027));

Future<Object?> _backGesture(
  WidgetTester tester,
  String method, [
  double? progress,
]) async {
  final channel = SystemChannels.backGesture;
  final response = Completer<ByteData?>();
  await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
    channel.name,
    channel.codec.encodeMethodCall(
      MethodCall(
        method,
        progress == null
            ? null
            : {
                'progress': progress,
                'touchOffset': [3.0, 240.0],
                'swipeEdge': 0,
              },
      ),
    ),
    response.complete,
  );
  final bytes = await response.future;
  return bytes == null ? null : channel.codec.decodeEnvelope(bytes);
}
