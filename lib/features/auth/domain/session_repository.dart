import 'package:serba_jaya_mobile/features/auth/domain/app_session.dart';

abstract interface class SessionRepository {
  Future<AppSession?> read();
  Future<void> write(AppSession session);
  Future<void> clear();
}

/// Konfirmasi sesi aplikasi sebelum hasil baca lokal dapat membuka akses.
typedef SessionValidator = Future<bool> Function(AppSession session);
