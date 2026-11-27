import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:serba_jaya_mobile/app/app.dart';
import 'package:serba_jaya_mobile/app/config/app_config.dart';
import 'package:serba_jaya_mobile/app/config/auth_provider.dart';
import 'package:serba_jaya_mobile/app/router/app_destination.dart';
import 'package:serba_jaya_mobile/app/router/app_router.dart';
import 'package:serba_jaya_mobile/app/shell/main_shell.dart';
import 'package:serba_jaya_mobile/features/auth/presentation/widgets/login_required_dialog.dart';
import 'package:serba_jaya_mobile/l10n/generated/app_localizations.dart';
import 'package:serba_jaya_mobile/shared/widgets/navigation/app_bottom_nav_bar.dart';
import 'package:serba_jaya_mobile/features/auth/domain/app_session.dart';
import 'package:serba_jaya_mobile/features/auth/domain/session_repository.dart';
import 'package:serba_jaya_mobile/features/auth/domain/google_identity.dart';
import 'package:serba_jaya_mobile/features/auth/presentation/pages/auth_onboarding_page.dart';
import 'package:serba_jaya_mobile/features/auth/presentation/pages/registration_page.dart';
import 'package:serba_jaya_mobile/features/auth/presentation/session_controller.dart';
import 'package:serba_jaya_mobile/features/auth/presentation/sign_in_action.dart';
import 'package:serba_jaya_mobile/shared/widgets/header/header_mobile.dart';
import 'package:serba_jaya_mobile/shared/widgets/header/header_action_button.dart';

import '../support/fakes.dart';

void main() {
  Future<ProviderContainer> mount(
    WidgetTester tester,
    FakeSessionRepository repository, {
    RequestSignIn? signIn,
    SessionValidator? validateSession,
    RequestGoogleIdentity? requestGoogleIdentity,
  }) async {
    final container = ProviderContainer(
      overrides: [
        appConfigProvider.overrideWithValue(
          AppConfig.parse(environment: 'dev'),
        ),
        sessionRepositoryProvider.overrideWithValue(repository),
        if (validateSession != null)
          sessionValidatorProvider.overrideWithValue(validateSession),
        requestGoogleIdentityProvider.overrideWith(
          (ref) => requestGoogleIdentity ?? ref.watch(googleIdentityProvider),
        ),
        if (signIn != null) signInActionProvider.overrideWithValue(signIn),
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
    await tester.tap(find.text('Chat'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Kontak WhatsApp'), findsOneWidget);
  });

  testWidgets(
    'Cart dialog overlays the active shell and Android back closes it',
    (tester) async {
      final container = await mount(tester, FakeSessionRepository());
      final router = container.read(appRouterProvider);
      await tester.pumpAndSettle();
      expect(find.byType(AppBottomNavBar), findsOneWidget);
      expect(find.byType(HeaderMobileActions), findsOneWidget);

      await tester.tap(find.text('Keranjang'));
      await tester.pumpAndSettle();

      expect(find.text('Kamu Harus Masuk'), findsOneWidget);
      expect(find.text('Notifikasi'), findsOneWidget);
      expect(find.byType(HeaderMobileActions), findsOneWidget);
      expect(find.byType(AppBottomNavBar), findsOneWidget);
      expect(find.byType(LoginRequiredDialog), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is ModalBarrier &&
              widget.color == Colors.black.withValues(alpha: 0.4),
        ),
        findsOneWidget,
      );
      expect(router.routeInformationProvider.value.uri.path, '/');

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('Kamu Harus Masuk'), findsNothing);
      expect(find.byType(AppBottomNavBar), findsOneWidget);
      expect(find.text('Notifikasi'), findsOneWidget);

      await tester.tap(find.text('Keranjang'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Tutup'));
      await tester.pumpAndSettle();
      expect(find.text('Kamu Harus Masuk'), findsNothing);
      expect(find.byType(AppBottomNavBar), findsOneWidget);
    },
  );

  testWidgets('all protected direct routes return to the safe home shell', (
    tester,
  ) async {
    final container = await mount(tester, FakeSessionRepository());
    await tester.pumpAndSettle();
    final router = container.read(appRouterProvider);

    for (final path in ['/cart', '/orders', '/notifications']) {
      router.go(path);
      await tester.pumpAndSettle();
      expect(find.text('Kamu Harus Masuk'), findsNothing, reason: path);
      expect(find.byType(AppBottomNavBar), findsOneWidget, reason: path);
      expect(find.text('Notifikasi'), findsOneWidget, reason: path);
      expect(find.byType(LoginRequiredDialog), findsNothing, reason: path);
      expect(router.routeInformationProvider.value.uri.path, '/');
    }
  });

  testWidgets('guest can open Profile and its subroutes without login', (
    tester,
  ) async {
    final container = await mount(tester, FakeSessionRepository());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();
    expect(find.text('Edit profil'), findsOneWidget);
    expect(find.byType(LoginRequiredDialog), findsNothing);
    await tester.tap(find.text('Edit profil'));
    await tester.pumpAndSettle();
    expect(find.text('Edit Profil'), findsOneWidget);

    final router = container.read(appRouterProvider);
    router.go('/profile/addresses/new');
    await tester.pumpAndSettle();
    expect(find.text('Tambah Alamat'), findsOneWidget);
    expect(router.state.uri.path, '/profile/addresses/new');
    expect(container.read(sessionProvider), isA<SessionGuest>());
  });

  testWidgets(
    'Profile scrolls as one page and retains offset across tabs and routes',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 640));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await mount(tester, FakeSessionRepository());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Profil'));
      await tester.pumpAndSettle();

      final page = find.byKey(const PageStorageKey<String>('profile-content'));
      final scrollable = find.descendant(
        of: page,
        matching: find.byType(Scrollable),
      );
      final position = tester.state<ScrollableState>(scrollable).position;
      final navbar = find.byType(AppBottomNavBar);
      final navbarRect = tester.getRect(navbar);

      expect(scrollable, findsOneWidget);
      expect(position.physics, isA<BouncingScrollPhysics>());
      expect(position.pixels, 0);
      await tester.drag(page, const Offset(0, -380));
      await tester.pumpAndSettle();
      final scrolledOffset = position.pixels;
      expect(scrolledOffset, greaterThan(100));
      expect(tester.getRect(navbar), navbarRect);

      await tester.tap(find.text('Chat'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Profil'));
      await tester.pumpAndSettle();
      expect(
        tester.state<ScrollableState>(scrollable).position.pixels,
        closeTo(scrolledOffset, 0.01),
      );

      final address = find.text('Alamat saya');
      await tester.ensureVisible(address);
      await tester.pumpAndSettle();
      final beforeOpening = position.pixels;
      await tester.tap(address);
      await tester.pumpAndSettle();
      expect(find.text('Alamat Saya'), findsOneWidget);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(
        tester.state<ScrollableState>(scrollable).position.pixels,
        closeTo(beforeOpening, 0.01),
      );
    },
  );

  testWidgets(
    'home Header keeps protected cart and notification actions guarded',
    (tester) async {
      await mount(tester, FakeSessionRepository());
      await tester.pumpAndSettle();

      for (final actionIndex in [0, 1]) {
        await tester.tap(
          find
              .descendant(
                of: find.byType(HeaderMobileActions),
                matching: find.byType(HeaderActionButton),
              )
              .at(actionIndex),
        );
        await tester.pumpAndSettle();
        expect(find.byType(LoginRequiredDialog), findsOneWidget);
        expect(find.byType(HeaderMobileActions), findsOneWidget);
        expect(find.byType(AppBottomNavBar), findsOneWidget);
        await tester.tap(find.byTooltip('Tutup'));
        await tester.pumpAndSettle();
        expect(find.byType(LoginRequiredDialog), findsNothing);
      }
    },
  );

  testWidgets(
    'protected navigation tabs show one overlay without changing route',
    (tester) async {
      final container = await mount(tester, FakeSessionRepository());
      await tester.pumpAndSettle();
      final router = container.read(appRouterProvider);

      for (final label in ['Keranjang', 'Pesanan']) {
        await tester.tap(find.text(label));
        await tester.pumpAndSettle();
        expect(find.byType(LoginRequiredDialog), findsOneWidget, reason: label);
        expect(find.byType(AppBottomNavBar), findsOneWidget, reason: label);
        expect(find.text('Notifikasi'), findsOneWidget, reason: label);
        expect(
          find.byWidgetPredicate(
            (widget) =>
                widget is ModalBarrier &&
                widget.color == Colors.black.withValues(alpha: 0.4),
          ),
          findsOneWidget,
          reason: label,
        );
        expect(
          router.routeInformationProvider.value.uri.path,
          '/',
          reason: label,
        );
        await tester.tap(find.byTooltip('Tutup'));
        await tester.pumpAndSettle();
        expect(find.byType(LoginRequiredDialog), findsNothing, reason: label);
      }
    },
  );

  testWidgets('optional shell header stays mounted behind the login dialog', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MainShell(
          destination: AppDestination.home,
          child: const Center(child: Text('Halaman sebelumnya')),
          onDestinationSelected: (_) => unawaited(
            showLoginRequiredDialog(tester.element(find.byType(MainShell))),
          ),
          headerBuilder: (_, _, _) => const Text('Header sebelumnya'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Keranjang'));
    await tester.pumpAndSettle();

    expect(find.text('Header sebelumnya'), findsOneWidget);
    expect(find.text('Halaman sebelumnya'), findsOneWidget);
    expect(find.byType(AppBottomNavBar), findsOneWidget);
    expect(find.text('Kamu Harus Masuk'), findsOneWidget);
    await tester.tap(find.byTooltip('Tutup'));
    await tester.pumpAndSettle();
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
    expect(find.byType(AuthOnboardingPage), findsOneWidget);
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
    expect(find.text('Kamu Harus Masuk'), findsNothing);
    expect(find.byType(AppBottomNavBar), findsOneWidget);
    expect(find.text('Notifikasi'), findsOneWidget);
    await tester.tap(find.text('Notifikasi'));
    await tester.pumpAndSettle();
    expect(find.text('Kamu Harus Masuk'), findsOneWidget);
    expect(find.byType(AppBottomNavBar), findsOneWidget);
  });

  testWidgets(
    'login actions do not create a session and registration keeps its return path',
    (tester) async {
      final container = await mount(tester, FakeSessionRepository());
      await tester.pumpAndSettle();
      final router = container.read(appRouterProvider);
      await tester.tap(find.text('Keranjang'));
      await tester.pumpAndSettle();
      expect(find.byType(LoginRequiredDialog), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'Masuk'));
      await tester.pumpAndSettle();
      expect(find.byType(AppBottomNavBar), findsNothing);

      final google = find.widgetWithText(OutlinedButton, 'Masuk Dengan Google');
      final apple = find.widgetWithText(FilledButton, 'Masuk Dengan Apple');
      for (final (button, notice) in [
        (google, 'Konfigurasi masuk dengan Google belum siap.'),
        (apple, 'Masuk dengan penyedia ini belum tersedia.'),
      ]) {
        await tester.tap(button);
        await tester.pumpAndSettle();
        expect(find.text(notice), findsOneWidget);
        expect(container.read(sessionProvider), isA<SessionGuest>());
        expect(container.read(sessionProvider.notifier).accessToken, isNull);
      }
      expect(router.state.uri.queryParameters['from'], '/cart');

      final register = find.text(
        'Belum memiliki akun? Daftar',
        findRichText: true,
      );
      await tester.ensureVisible(register);
      await tester.tap(register);
      await tester.pumpAndSettle();
      expect(find.byType(RegistrationPage), findsOneWidget);
      expect(router.state.uri.path, '/login/register');
      expect(router.state.uri.queryParameters['from'], '/cart');

      final submit = find.widgetWithText(FilledButton, 'Buat akun');
      await tester.ensureVisible(submit);
      await tester.tap(submit);
      await tester.pumpAndSettle();
      expect(find.text('Isi nama lengkap.'), findsOneWidget);
      expect(find.text('Isi nomor telepon.'), findsOneWidget);
      expect(find.text('Isi alamat email.'), findsOneWidget);
      expect(
        find.text('Centang persetujuan untuk melanjutkan.'),
        findsOneWidget,
      );

      for (final entry in {
        'name': 'Pengguna Uji',
        'phone': '81234567890',
        'email': 'user@example.test',
      }.entries) {
        final field = find.byKey(ValueKey('registration-${entry.key}'));
        await tester.ensureVisible(field);
        await tester.enterText(field, entry.value);
        await tester.pump();
      }
      final consent = find.textContaining('Dengan mendaftar');
      await tester.ensureVisible(consent);
      await tester.tap(consent);
      await tester.pumpAndSettle();
      await tester.ensureVisible(submit);
      await tester.tap(submit);
      await tester.pumpAndSettle();
      expect(
        find.text('Data belum dikirim. Pendaftaran akun belum tersedia.'),
        findsOneWidget,
      );
      expect(container.read(sessionProvider), isA<SessionGuest>());

      final cancel = find.widgetWithText(OutlinedButton, 'Batal');
      await tester.ensureVisible(cancel);
      await tester.tap(cancel);
      await tester.pumpAndSettle();
      expect(router.state.uri.path, '/login');
      expect(router.state.uri.queryParameters['from'], '/cart');
    },
    variant: TargetPlatformVariant.only(TargetPlatform.iOS),
  );

  testWidgets(
    'provider handoff blocks duplicate actions and reports errors without granting access',
    (tester) async {
      final pending = Completer<GoogleIdentity?>();
      final methods = <AuthSignInMethod>[];
      final container = await mount(
        tester,
        FakeSessionRepository(),
        signIn: (method) {
          methods.add(method);
          return pending.future;
        },
      );
      final router = container.read(appRouterProvider);
      router.go('/login?from=/cart');
      await tester.pumpAndSettle();

      final google = find.widgetWithText(OutlinedButton, 'Masuk Dengan Google');
      await tester.tap(google);
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(tester.widget<OutlinedButton>(google).onPressed, isNull);
      expect(methods, [AuthSignInMethod.google]);

      pending.completeError(Exception('fixture'));
      await tester.pumpAndSettle();
      expect(
        find.text('Tidak dapat memulai proses masuk. Coba lagi.'),
        findsOneWidget,
      );
      expect(tester.widget<OutlinedButton>(google).onPressed, isNotNull);
      expect(container.read(sessionProvider), isA<SessionGuest>());
    },
  );

  testWidgets('Google identity opens the dev preview and remains a guest', (
    tester,
  ) async {
    final repository = FakeSessionRepository();
    final container = await mount(
      tester,
      repository,
      requestGoogleIdentity: () async => const GoogleIdentity(
        registrationData: GoogleRegistrationData(
          googleUserId: 'google-user-fixture',
          displayName: 'Google User',
          email: 'google@example.test',
          photoUrl: null,
        ),
        idToken: 'id-token-fixture',
      ),
    );
    final router = container.read(appRouterProvider);
    router.go('/login?from=/cart');
    await tester.pumpAndSettle();

    await tester.tap(
      find.widgetWithText(OutlinedButton, 'Masuk Dengan Google'),
    );
    await tester.pumpAndSettle();

    expect(find.text('Google Account Preview'), findsOneWidget);
    expect(find.text('google-user-fixture'), findsOneWidget);
    expect(find.text('Google User'), findsOneWidget);
    expect(find.text('google@example.test'), findsOneWidget);
    expect(container.read(sessionProvider), isA<SessionGuest>());
    expect(await repository.read(), isNull);
    expect(find.text('Google Account Preview'), findsOneWidget);

    router.go('/cart');
    await tester.pumpAndSettle();
    expect(router.routeInformationProvider.value.uri.path, '/');
  });

  testWidgets(
    'authenticated Profile can edit a local name and cancel or confirm logout',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final repository = FakeSessionRepository()
        ..session = AppSession(
          accessToken: 'test-session',
          expiresAt: DateTime.now().add(const Duration(hours: 1)),
        );
      final container = await mount(
        tester,
        repository,
        validateSession: (_) async => true,
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Profil'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Edit profil'));
      await tester.pumpAndSettle();

      final save = find.text('Simpan perubahan');
      await tester.ensureVisible(save);
      await tester.pumpAndSettle();
      await tester.tap(save);
      await tester.pumpAndSettle();
      expect(find.text('Isi nama lengkap.'), findsOneWidget);

      final name = find.descendant(
        of: find.byKey(const ValueKey('profile-name')),
        matching: find.byType(TextFormField),
      );
      await tester.ensureVisible(name);
      await tester.pumpAndSettle();
      await tester.enterText(name, 'Pelanggan Uji');
      await tester.ensureVisible(save);
      await tester.pumpAndSettle();
      await tester.tap(save);
      await tester.pumpAndSettle();
      expect(find.text('Pelanggan Uji'), findsOneWidget);

      final logout = find.text('Keluar dari akun');
      await tester.scrollUntilVisible(logout, 180);
      await tester.ensureVisible(logout);
      await tester.pumpAndSettle();
      await tester.tap(logout);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Batal'));
      await tester.pumpAndSettle();
      expect(repository.clearCount, 0);

      await tester.tap(logout);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ya, keluar'));
      await tester.pumpAndSettle();
      expect(repository.clearCount, 1);
      expect(container.read(sessionProvider), isA<SessionGuest>());
      expect(container.read(appRouterProvider).state.uri.path, '/');
    },
  );

  test('expired credentials cannot open a protected route or resume it', () {
    final now = DateTime.utc(2026, 1);
    final state = SessionAuthenticated(
      AppSession(accessToken: 'expired-fixture', expiresAt: now),
    );
    String? redirect(String path) =>
        sessionRedirect(Uri.parse(path), state, now: now);
    final gate = redirect('/cart');
    expect(gate, '/');
    expect(redirect(gate!), isNull);
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
    final guestRedirect = sessionRedirect(
      Uri.parse('/session?from=/cart&next=https://outside.example.test'),
      const SessionGuest(),
      now: now,
    );
    expect(guestRedirect, '/');
  });
}
