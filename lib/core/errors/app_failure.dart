enum FailureKind {
  network,
  timeout,
  cancelled,
  unauthorized,
  forbidden,
  server,
  invalidResponse,
  apiDisabled,
  unknown,
}

/// Kesalahan yang aman diteruskan ke view model tanpa payload sensitif.
final class AppFailure implements Exception {
  const AppFailure(this.kind);

  final FailureKind kind;
}
