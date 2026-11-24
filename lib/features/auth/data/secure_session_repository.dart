import 'dart:convert';

import 'package:serba_jaya_mobile/core/storage/secure_store.dart';
import 'package:serba_jaya_mobile/features/auth/domain/app_session.dart';
import 'package:serba_jaya_mobile/features/auth/domain/session_repository.dart';

/// Format penyimpanan lokal berversi, independen dari kontrak API.
class SecureSessionRepository implements SessionRepository {
  const SecureSessionRepository(this._store);

  static const storageKey = 'app_session_v1';
  final SecureStore _store;

  @override
  Future<AppSession?> read() async {
    final raw = await _store.read(storageKey);
    if (raw == null) return null;
    try {
      final value = jsonDecode(raw);
      if (value case {
        'accessToken': final String accessToken,
        'expiresAt': final String expiresAt,
        'refreshToken': final String? refreshToken,
      }) {
        final expiry = DateTime.tryParse(expiresAt);
        if (expiry != null && accessToken.isNotEmpty) {
          return AppSession(
            accessToken: accessToken,
            expiresAt: expiry.toUtc(),
            refreshToken: refreshToken,
          );
        }
      }
    } on FormatException {
      // Bersihkan payload lokal yang rusak di bawah.
    }
    await clear();
    return null;
  }

  @override
  Future<void> write(AppSession session) => _store.write(
    storageKey,
    jsonEncode({
      'accessToken': session.accessToken,
      'expiresAt': session.expiresAt.toUtc().toIso8601String(),
      'refreshToken': session.refreshToken,
    }),
  );

  @override
  Future<void> clear() => _store.delete(storageKey);
}
