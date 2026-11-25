import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:serba_jaya_mobile/features/auth/domain/google_identity.dart';
import 'package:serba_jaya_mobile/features/auth/domain/sign_in_failure.dart';

enum AuthSignInMethod { google, apple }

typedef RequestSignIn = Future<void> Function(AuthSignInMethod method);

final requestGoogleIdTokenProvider = Provider<RequestGoogleIdToken>((ref) {
  throw StateError('Google identity source must be supplied by bootstrap.');
});

// Override when the Serba Jaya backend contract is implemented.
final exchangeGoogleIdentityProvider = Provider<ExchangeGoogleIdentity?>(
  (ref) => null,
);

final signInActionProvider = Provider<RequestSignIn>((ref) {
  Future<void>? inFlight;

  Future<void> signInWithGoogle() async {
    final requestToken = ref.read(requestGoogleIdTokenProvider);
    final exchange = ref.read(exchangeGoogleIdentityProvider);
    final idToken = await requestToken();
    if (exchange == null) throw SignInUnavailable.backend;
    await exchange(idToken);
  }

  return (method) async {
    if (method == AuthSignInMethod.apple) throw SignInUnavailable.provider;
    if (inFlight case final pending?) return pending;

    final request = inFlight = signInWithGoogle();
    try {
      await request;
    } finally {
      inFlight = null;
    }
  };
});
