typedef RequestGoogleIdToken = Future<String> Function();

/// Hands the ID token to the backend auth flow for HTTPS exchange. The
/// implementation must drive registration or app session activation from the
/// validated backend result and must never store the Google token as a session.
typedef ExchangeGoogleIdentity = Future<void> Function(String idToken);
