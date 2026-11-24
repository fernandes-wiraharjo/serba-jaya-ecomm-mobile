import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:serba_jaya_mobile/features/auth/data/secure_session_repository.dart';
import 'package:serba_jaya_mobile/features/auth/domain/app_session.dart';
import 'package:serba_jaya_mobile/features/auth/presentation/session_controller.dart';

import '../support/fakes.dart';

void main() {
  late DateTime now;
  late AppSession session;
  late FakeSessionRepository repository;

  setUp(() {
    now = DateTime.utc(2026, 1);
    session = AppSession(
      accessToken: 'test-token',
      refreshToken: 'test-refresh',
      expiresAt: now.add(const Duration(minutes: 5)),
    );
    repository = FakeSessionRepository()..session = session;
  });

  ProviderContainer container({bool? validate}) {
    final value = ProviderContainer(
      overrides: [
        sessionRepositoryProvider.overrideWithValue(repository),
        sessionClockProvider.overrideWithValue(() => now),
        if (validate != null)
          sessionValidatorProvider.overrideWithValue((_) async => validate),
      ],
    );
    addTearDown(value.dispose);
    expect(value.read(sessionProvider), isA<SessionInitializing>());
    return value;
  }

  test(
    'secure store round trip, cleanup of corrupt data, and logout',
    () async {
      final store = MemorySecureStore();
      final local = SecureSessionRepository(store);
      await local.write(session);
      final restored = await local.read();
      expect(restored?.accessToken, session.accessToken);
      expect(restored?.refreshToken, session.refreshToken);
      expect(restored?.expiresAt, session.expiresAt);
      await local.clear();
      expect(await local.read(), isNull);
      await store.write(SecureSessionRepository.storageKey, '{');
      expect(await local.read(), isNull);
      expect(store.values, isEmpty);
    },
  );

  test('default validator does not accept a stored token', () async {
    final value = container();
    await Future<void>.delayed(Duration.zero);
    expect(value.read(sessionProvider), isA<SessionGuest>());
    expect(repository.session, isNull);
    expect(value.read(sessionProvider.notifier).accessToken, isNull);
  });

  testWidgets('restores after validation and expires with the timer', (
    tester,
  ) async {
    final value = container(validate: true);
    await tester.pump();
    expect(value.read(sessionProvider), isA<SessionAuthenticated>());
    expect(value.read(sessionProvider.notifier).accessToken, 'test-token');
    now = session.expiresAt;
    await tester.pump(const Duration(minutes: 5));
    expect(value.read(sessionProvider), isA<SessionGuest>());
    expect(repository.clearCount, 1);
  });

  test('expired sessions are removed without opening access', () async {
    now = session.expiresAt;
    final value = container(validate: true);
    await Future<void>.delayed(Duration.zero);
    expect(value.read(sessionProvider), isA<SessionGuest>());
    expect(repository.clearCount, 1);
  });

  test('logout wins against an in-flight restoration', () async {
    repository.pendingRead = Completer<AppSession?>();
    final value = container(validate: true);
    final controller = value.read(sessionProvider.notifier);
    await Future<void>.delayed(Duration.zero);
    await controller.logout();
    repository.pendingRead?.complete(session);
    await Future<void>.delayed(Duration.zero);
    expect(value.read(sessionProvider), isA<SessionGuest>());
    expect(controller.accessToken, isNull);
    expect(repository.session, isNull);
  });

  test(
    'logout remains revoked while deletion and provider rebuild overlap',
    () async {
      final value = container(validate: true);
      await Future<void>.delayed(Duration.zero);
      expect(value.read(sessionProvider), isA<SessionAuthenticated>());

      final deletion = Completer<void>();
      repository.pendingClear = deletion;
      final controller = value.read(sessionProvider.notifier);
      final firstLogout = controller.logout();
      final secondLogout = controller.logout();
      value.invalidate(sessionProvider);
      value.read(sessionProvider);
      await Future<void>.delayed(Duration.zero);

      final stateDuringDeletion = value.read(sessionProvider);
      final tokenDuringDeletion = value
          .read(sessionProvider.notifier)
          .accessToken;
      deletion.complete();
      await Future.wait([firstLogout, secondLogout]);

      expect(stateDuringDeletion, isA<SessionGuest>());
      expect(tokenDuringDeletion, isNull);
      expect(repository.clearCount, 1);
      expect(repository.session, isNull);
    },
  );

  test('a failed logout stays signed out across provider rebuilds', () async {
    final value = container(validate: true);
    await Future<void>.delayed(Duration.zero);
    repository.failClear = true;
    await value.read(sessionProvider.notifier).logout();
    expect(repository.session, isNotNull);

    value.invalidate(sessionProvider);
    value.read(sessionProvider);
    await Future<void>.delayed(Duration.zero);
    expect(
      value.read(sessionProvider),
      isA<SessionGuest>().having(
        (state) => state.clearFailed,
        'clearFailed',
        isTrue,
      ),
    );
    expect(value.read(sessionProvider.notifier).accessToken, isNull);
  });

  test('unavailable secure storage leads to guest without a token', () async {
    repository.failRead = true;
    final value = container(validate: true);
    await Future<void>.delayed(Duration.zero);
    expect(value.read(sessionProvider), isA<SessionGuest>());
    expect(value.read(sessionProvider.notifier).accessToken, isNull);
  });

  test('failed local deletion revokes access and supports retry', () async {
    final value = container(validate: true);
    await Future<void>.delayed(Duration.zero);
    final controller = value.read(sessionProvider.notifier);
    repository.failClear = true;
    await controller.logout();
    expect(
      value.read(sessionProvider),
      isA<SessionGuest>().having(
        (state) => state.clearFailed,
        'clearFailed',
        isTrue,
      ),
    );
    expect(controller.accessToken, isNull);
    repository.failClear = false;
    await controller.logout();
    expect(repository.session, isNull);
  });
}
