import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AuthSignInMethod { google, apple }

typedef RequestSignIn = Future<void> Function(AuthSignInMethod method);

/// Provider integration is supplied later. The UI does not issue app sessions.
final signInActionProvider = Provider<RequestSignIn?>((ref) => null);
