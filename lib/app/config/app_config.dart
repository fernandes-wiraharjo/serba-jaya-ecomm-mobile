import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppEnvironment {
  dev('Serba Jaya DEV'),
  staging('Serba Jaya STG'),
  prod('Serba Jaya');

  const AppEnvironment(this.displayName);

  final String displayName;
}

@immutable
class AppConfig {
  const AppConfig._({
    required this.environment,
    required this.displayName,
    this.apiBaseUrl,
    this.debugLogging = false,
  });

  factory AppConfig.fromDefines() => AppConfig.parse(
    environment: const String.fromEnvironment('APP_ENV'),
    nativeFlavor: appFlavor ?? '',
    displayName: const String.fromEnvironment('APP_DISPLAY_NAME'),
    apiBaseUrl: const String.fromEnvironment('API_BASE_URL'),
    debugLogging: const String.fromEnvironment(
      'ENABLE_DEBUG_LOGGING',
      defaultValue: 'false',
    ),
  );

  factory AppConfig.parse({
    required String environment,
    String? nativeFlavor,
    String displayName = '',
    String apiBaseUrl = '',
    String debugLogging = 'false',
  }) {
    final env = AppEnvironment.values.asNameMap()[environment];
    if (env == null) throw const FormatException('APP_ENV');
    if (nativeFlavor != null && nativeFlavor != env.name) {
      throw const FormatException('APP_ENV must match the native flavor');
    }
    final label = displayName.trim();
    if (label.isNotEmpty && label != env.displayName) {
      throw const FormatException('APP_DISPLAY_NAME must match APP_ENV');
    }
    if (debugLogging != 'true' && debugLogging != 'false') {
      throw const FormatException('ENABLE_DEBUG_LOGGING');
    }

    final rawUrl = apiBaseUrl.trim();
    final uri = rawUrl.isEmpty ? null : Uri.tryParse(rawUrl);
    if (rawUrl.isNotEmpty &&
        (uri == null ||
            uri.scheme != 'https' ||
            uri.host.isEmpty ||
            uri.userInfo.isNotEmpty ||
            uri.hasQuery ||
            uri.hasFragment)) {
      throw const FormatException('API_BASE_URL');
    }

    return AppConfig._(
      environment: env,
      displayName: env.displayName,
      apiBaseUrl: uri?.replace(
        path: uri.path.endsWith('/') ? uri.path : '${uri.path}/',
      ),
      debugLogging: env != AppEnvironment.prod && debugLogging == 'true',
    );
  }

  final AppEnvironment environment;
  final String displayName;
  final Uri? apiBaseUrl;
  final bool debugLogging;
}

final appConfigProvider = Provider<AppConfig>((ref) {
  throw StateError('AppConfig must be supplied by bootstrap.');
});
