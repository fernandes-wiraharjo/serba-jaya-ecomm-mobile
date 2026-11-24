import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:serba_jaya_mobile/features/auth/domain/app_session.dart';
import 'package:serba_jaya_mobile/features/auth/domain/session_repository.dart';

sealed class SessionState {
  const SessionState();
}

final class SessionInitializing extends SessionState {
  const SessionInitializing();
}

final class SessionGuest extends SessionState {
  const SessionGuest({this.clearFailed = false});

  final bool clearFailed;
}

final class SessionAuthenticated extends SessionState {
  const SessionAuthenticated(this.session);

  final AppSession session;
}

final sessionRepositoryProvider = Provider<SessionRepository>((ref) {
  throw StateError('SessionRepository must be supplied by bootstrap.');
});

final sessionValidatorProvider = Provider<SessionValidator>(
  (ref) =>
      (_) async => false,
);

final sessionClockProvider = Provider<DateTime Function()>(
  (ref) => DateTime.now,
);

final sessionProvider = NotifierProvider<SessionController, SessionState>(
  SessionController.new,
);

class SessionController extends Notifier<SessionState> {
  Timer? _expiration;
  int _generation = 0;
  bool _restoreBlocked = false;
  bool _clearFailed = false;
  Future<void>? _logoutInFlight;

  DateTime _now() => ref.read(sessionClockProvider)();

  @override
  SessionState build() {
    final repository = ref.watch(sessionRepositoryProvider);
    final validate = ref.watch(sessionValidatorProvider);
    final generation = ++_generation;
    ref.onDispose(() {
      ++_generation;
      _expiration?.cancel();
    });
    if (_restoreBlocked) return SessionGuest(clearFailed: _clearFailed);
    scheduleMicrotask(() => _restore(generation, repository, validate));
    return const SessionInitializing();
  }

  Future<void> _restore(
    int generation,
    SessionRepository repository,
    SessionValidator validate,
  ) async {
    if (generation != _generation) return;
    try {
      final session = await repository.read();
      if (generation != _generation) return;
      if (session == null) {
        state = const SessionGuest();
        return;
      }
      final valid = session.isUsableAt(_now()) && await validate(session);
      if (generation != _generation) return;
      if (!valid || !session.isUsableAt(_now())) {
        await logout();
        return;
      }
      _expiration = Timer(
        session.expiresAt.difference(_now()),
        checkExpiration,
      );
      state = SessionAuthenticated(session);
    } on Exception {
      if (generation == _generation) state = const SessionGuest();
    }
  }

  /// Pencabutan akses lokal berlaku segera, termasuk jika penghapusan gagal.
  Future<void> logout() {
    final inFlight = _logoutInFlight;
    if (inFlight != null) return inFlight;

    final repository = ref.read(sessionRepositoryProvider);
    ++_generation;
    _expiration?.cancel();
    // A rebuilt provider must not restore a session being deleted or rejected.
    _restoreBlocked = true;
    _clearFailed = false;
    final deletion = Future<void>.microtask(() => _clearSession(repository));
    _logoutInFlight = deletion;
    state = const SessionGuest();
    return deletion;
  }

  Future<void> _clearSession(SessionRepository repository) async {
    try {
      await repository.clear();
    } on Exception {
      _clearFailed = true;
    } finally {
      _logoutInFlight = null;
    }
    if (_clearFailed && ref.mounted) {
      state = const SessionGuest(clearFailed: true);
    }
  }

  void checkExpiration() {
    if (state case SessionAuthenticated(:final session)) {
      if (!session.isUsableAt(_now())) {
        unawaited(logout());
      } else {
        _expiration?.cancel();
        _expiration = Timer(
          session.expiresAt.difference(_now()),
          checkExpiration,
        );
      }
    }
  }

  String? get accessToken {
    if (state case SessionAuthenticated(
      :final session,
    ) when session.isUsableAt(_now())) {
      return session.accessToken;
    }
    return null;
  }
}
