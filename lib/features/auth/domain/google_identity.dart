/// Profile fields available for mapping a newly authenticated Google account
/// into the application's registration flow.
final class GoogleRegistrationData {
  const GoogleRegistrationData({
    required this.googleUserId,
    required this.displayName,
    required this.email,
    required this.photoUrl,
    this.givenName,
    this.familyName,
    this.emailVerified,
    this.unverifiedClaims = const {},
  });

  final String googleUserId;
  final String? displayName;
  final String email;
  final String? photoUrl;
  final String? givenName;
  final String? familyName;
  final bool? emailVerified;
  final Map<String, Object?> unverifiedClaims;
}

/// Short-lived result from the Google identity provider.
///
/// [idToken] is for a future backend exchange only. It must not be used as an
/// application session or included in logs.
final class GoogleIdentity {
  const GoogleIdentity({required this.registrationData, this.idToken});

  final GoogleRegistrationData registrationData;
  final String? idToken;
}

typedef RequestGoogleIdentity = Future<GoogleIdentity> Function();

/// Hands the ID token to the backend auth flow for HTTPS exchange. The
/// implementation must drive registration or app session activation from the
/// validated backend result and must never store the Google token as a session.
typedef ExchangeGoogleIdentity = Future<void> Function(String idToken);
