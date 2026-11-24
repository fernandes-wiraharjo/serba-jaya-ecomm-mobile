import 'package:flutter_test/flutter_test.dart';
import 'package:serba_jaya_mobile/app/config/app_config.dart';

void main() {
  test('dev can start with networking disabled', () {
    final config = AppConfig.parse(environment: 'dev');
    expect(config.environment, AppEnvironment.dev);
    expect(config.apiBaseUrl, isNull);
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
