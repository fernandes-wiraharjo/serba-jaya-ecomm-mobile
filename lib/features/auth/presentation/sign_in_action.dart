import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:serba_jaya_mobile/app/config/app_config.dart';
import 'package:serba_jaya_mobile/features/auth/domain/google_identity.dart';
import 'package:serba_jaya_mobile/features/auth/domain/sign_in_failure.dart';

enum AuthSignInMethod { google, apple }

typedef RequestSignIn =
    Future<GoogleIdentity?> Function(AuthSignInMethod method);

final requestGoogleIdentityProvider = Provider<RequestGoogleIdentity>((ref) {
  throw StateError('Google identity source must be supplied by bootstrap.');
});

// Override when the Serba Jaya backend contract is implemented.
final exchangeGoogleIdentityProvider = Provider<ExchangeGoogleIdentity?>(
  (ref) => null,
);

final signInActionProvider = Provider<RequestSignIn>((ref) {
  Future<GoogleIdentity?>? inFlight;

  Future<GoogleIdentity?> signInWithGoogle() async {
    final requestIdentity = ref.read(requestGoogleIdentityProvider);
    final exchange = ref.read(exchangeGoogleIdentityProvider);
    final identity = await requestIdentity();
    if (exchange != null && identity.idToken != null) {
      await exchange(identity.idToken!);
      return null;
    }
    if (ref.read(appConfigProvider).environment != AppEnvironment.dev) {
      throw SignInUnavailable.backend;
    }
    return identity;
  }

  return (method) async {
    if (method == AuthSignInMethod.apple) throw SignInUnavailable.provider;
    if (inFlight case final pending?) return pending;

    final request = inFlight = signInWithGoogle();
    try {
      return await request;
    } finally {
      inFlight = null;
    }
  };
});
