import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:serba_jaya_mobile/app/config/app_config.dart';

void main() {
  test('dev can start with networking disabled', () {
    final config = AppConfig.parse(environment: 'dev');
    expect(config.environment, AppEnvironment.dev);
    expect(config.apiBaseUrl, isNull);
    expect(config.googleServerClientId, isNull);
    expect(config.googleIosClientId, isNull);
  });

  test('reads Google client IDs only from the supplied environment', () {
    final dev = AppConfig.parse(
      environment: 'dev',
      googleServerClientId: '  dev-web.apps.googleusercontent.com  ',
      googleIosClientId: 'dev-ios.apps.googleusercontent.com',
    );
    expect(dev.googleServerClientId, 'dev-web.apps.googleusercontent.com');
    expect(dev.googleIosClientId, 'dev-ios.apps.googleusercontent.com');
    for (final environment in ['staging', 'prod']) {
      final config = AppConfig.parse(environment: environment);
      expect(config.googleServerClientId, isNull);
      expect(config.googleIosClientId, isNull);
    }
  });

  test('Maps keys are optional, validated independently and trimmed', () {
    final key = 'AIza${'A' * 35}';
    final config = AppConfig.parse(
      environment: 'dev',
      nativeFlavor: 'dev',
      googleMapsAndroidApiKey: '  $key  ',
      googleMapsIosApiKey: 'invalid.apps.googleusercontent.com',
    );
    expect(config.googleMapsAndroidApiKey, key);
    expect(config.googleMapsIosApiKey, isNull);
    expect(
      AppConfig.parse(environment: 'prod').googleMapsAndroidApiKey,
      isNull,
    );
  });

  test('production forces logging off and normalizes the base path', () {
    final config = AppConfig.parse(
      environment: 'prod',
      apiBaseUrl: 'https://api.example.test/service',
      debugLogging: 'true',
    );
    expect(config.apiBaseUrl.toString(), 'https://api.example.test/service/');
    expect(config.debugLogging, isFalse);
  });

  test('unknown environments and invalid logging values fail validation', () {
    expect(() => AppConfig.parse(environment: 'qa'), throwsFormatException);
    expect(
      () => AppConfig.parse(environment: 'dev', debugLogging: '1'),
      throwsFormatException,
    );
  });

  test('rejects a missing, unsupported, or mismatched native flavor', () {
    for (final nativeFlavor in ['', 'unknown', 'staging', 'prod']) {
      expect(
        () => AppConfig.parse(environment: 'dev', nativeFlavor: nativeFlavor),
        throwsFormatException,
      );
    }
    expect(
      () => AppConfig.parse(environment: '', nativeFlavor: 'dev'),
      throwsFormatException,
    );
    expect(
      () => AppConfig.parse(
        environment: 'dev',
        nativeFlavor: 'dev',
        displayName: 'Serba Jaya',
      ),
      throwsFormatException,
    );
  });

  test('VS Code launches each native flavor with its own example config', () {
    const labels = {
      'dev': ('Development', 'Serba Jaya DEV'),
      'staging': ('Staging', 'Serba Jaya STG'),
      'prod': ('Production', 'Serba Jaya'),
    };
    final launch =
        jsonDecode(File('.vscode/launch.json').readAsStringSync())
            as Map<String, Object?>;
    final profiles = (launch['configurations'] as List<Object?>)
        .cast<Map<String, Object?>>();
    for (final entry in labels.entries) {
      final env = entry.key;
      final (profileName, displayName) = entry.value;
      final path = 'config/$env.example.json';
      final data =
          (jsonDecode(File(path).readAsStringSync()) as Map<String, Object?>)
              .cast<String, String>();
      final profile = profiles.singleWhere(
        (value) => value['name'] == 'Serba Jaya — $profileName',
      );
      expect(profile['toolArgs'], [
        '--flavor',
        env,
        '--dart-define-from-file=$path',
      ]);
      final config = AppConfig.parse(
        environment: data['APP_ENV']!,
        nativeFlavor: env,
        displayName: data['APP_DISPLAY_NAME']!,
        apiBaseUrl: data['API_BASE_URL']!,
        debugLogging: data['ENABLE_DEBUG_LOGGING']!,
        googleServerClientId: data['GOOGLE_SERVER_CLIENT_ID']!,
        googleIosClientId: data['GOOGLE_IOS_CLIENT_ID']!,
        googleMapsAndroidApiKey: data['GOOGLE_MAPS_ANDROID_API_KEY']!,
        googleMapsIosApiKey: data['GOOGLE_MAPS_IOS_API_KEY']!,
      );
      expect(config.environment.name, env);
      expect(config.displayName, displayName);
      expect(config.apiBaseUrl, isNull);
      final serverId = data['GOOGLE_SERVER_CLIENT_ID']!.trim();
      expect(
        config.googleServerClientId == (serverId.isEmpty ? null : serverId),
        isTrue,
      );
      expect(config.googleIosClientId, isNull);
      expect(data['GOOGLE_MAPS_ANDROID_API_KEY'], isEmpty);
      expect(data['GOOGLE_MAPS_IOS_API_KEY'], isEmpty);
      expect(config.debugLogging, env == 'dev');
    }
  });

  for (final url in [
    'http://api.example.test',
    'relative',
    'https://user:password@api.example.test',
    'https://api.example.test/?q=1',
    'https://api.example.test/#fragment',
  ]) {
    test('invalid API URL is rejected: $url', () {
      expect(
        () => AppConfig.parse(environment: 'staging', apiBaseUrl: url),
        throwsFormatException,
      );
    });
  }
}
