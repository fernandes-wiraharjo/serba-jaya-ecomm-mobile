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
    this.googleAndroidClientId,
    this.googleServerClientId,
    this.googleIosClientId,
    this.googleMapsAndroidApiKey,
    this.googleMapsIosApiKey,
  });

  factory AppConfig.fromDefines() => AppConfig.parse(
    environment: const String.fromEnvironment('APP_ENV'),
    nativeFlavor: appFlavor ?? '',
    displayName: const String.fromEnvironment('APP_DISPLAY_NAME'),
    apiBaseUrl: const String.fromEnvironment('API_BASE_URL'),
    googleAndroidClientId: const String.fromEnvironment(
      'GOOGLE_ANDROID_CLIENT_ID',
    ),
    googleServerClientId: const String.fromEnvironment(
      'GOOGLE_SERVER_CLIENT_ID',
    ),
    googleIosClientId: const String.fromEnvironment('GOOGLE_IOS_CLIENT_ID'),
    googleMapsAndroidApiKey: const String.fromEnvironment(
      'GOOGLE_MAPS_ANDROID_API_KEY',
    ),
    googleMapsIosApiKey: const String.fromEnvironment(
      'GOOGLE_MAPS_IOS_API_KEY',
    ),
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
    String googleAndroidClientId = '',
    String googleServerClientId = '',
    String googleIosClientId = '',
    String googleMapsAndroidApiKey = '',
    String googleMapsIosApiKey = '',
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
      googleAndroidClientId: _optionalDefine(googleAndroidClientId),
      googleServerClientId: _optionalDefine(googleServerClientId),
      googleIosClientId: _optionalDefine(googleIosClientId),
      googleMapsAndroidApiKey: _mapsKey(googleMapsAndroidApiKey),
      googleMapsIosApiKey: _mapsKey(googleMapsIosApiKey),
    );
  }

  final AppEnvironment environment;
  final String displayName;
  final Uri? apiBaseUrl;
  final bool debugLogging;
  final String? googleAndroidClientId;
  final String? googleServerClientId;
  final String? googleIosClientId;
  final String? googleMapsAndroidApiKey;
  final String? googleMapsIosApiKey;
}

String? _optionalDefine(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

// A missing or invalid Maps key only disables the map for that platform.
String? _mapsKey(String value) {
  final key = value.trim();
  return RegExp(r'^AIza[A-Za-z0-9_-]{35}$').hasMatch(key) ? key : null;
}

final appConfigProvider = Provider<AppConfig>((ref) {
  throw StateError('AppConfig must be supplied by bootstrap.');
});
