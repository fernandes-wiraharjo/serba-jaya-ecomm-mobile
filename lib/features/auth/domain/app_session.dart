/// Token dari sesi aplikasi yang diterbitkan oleh backend.
final class AppSession {
  const AppSession({
    required this.accessToken,
    required this.expiresAt,
    this.refreshToken,
  });

  final String accessToken;
  final String? refreshToken;
  final DateTime expiresAt;

  bool isUsableAt(DateTime now) =>
      accessToken.isNotEmpty && expiresAt.isAfter(now);
}
