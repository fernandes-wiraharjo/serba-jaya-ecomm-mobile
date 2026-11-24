import 'dart:async';

import 'package:serba_jaya_mobile/core/storage/secure_store.dart';
import 'package:serba_jaya_mobile/features/auth/domain/app_session.dart';
import 'package:serba_jaya_mobile/features/auth/domain/session_repository.dart';

class MemorySecureStore implements SecureStore {
  final values = <String, String>{};

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async {
    values[key] = value;
  }

  @override
  Future<void> delete(String key) async => values.remove(key);
}

class FakeSessionRepository implements SessionRepository {
  AppSession? session;
  Completer<AppSession?>? pendingRead;
  Completer<void>? pendingClear;
  bool failRead = false;
  bool failClear = false;
  int clearCount = 0;

  @override
  Future<AppSession?> read() async {
    if (failRead) throw Exception('Storage unavailable');
    final pending = pendingRead;
    return pending == null ? session : await pending.future;
  }

  @override
  Future<void> write(AppSession value) async => session = value;

  @override
  Future<void> clear() async {
    clearCount++;
    await pendingClear?.future;
    if (failClear) throw Exception('Storage unavailable');
    session = null;
  }
}
