import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:serba_jaya_mobile/core/errors/app_failure.dart';
import 'package:serba_jaya_mobile/features/auth/domain/sign_in_failure.dart';

final class GoogleIdentitySource {
  GoogleIdentitySource({
    required GoogleSignIn sdk,
    required TargetPlatform platform,
    required String? serverClientId,
    required String? iosClientId,
  }) : _sdk = sdk,
       _platform = platform,
       _serverClientId = serverClientId,
       _iosClientId = iosClientId;

  static final _clientIdPattern = RegExp(
    r'^[a-z0-9-]+\.apps\.googleusercontent\.com$',
  );
  static const _iosConfiguration = MethodChannel(
    'id.serbajaya.ecommerce/google_sign_in_config',
  );

  final GoogleSignIn _sdk;
  final TargetPlatform _platform;
  final String? _serverClientId;
  final String? _iosClientId;
  bool _initialized = false;

  Future<String> requestIdToken() async {
    try {
      if (!_initialized) await _initialize();
      final account = await _sdk.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null || idToken.trim().isEmpty) {
        throw const AppFailure(FailureKind.invalidResponse);
      }
      return idToken;
    } on GoogleSignInException catch (error) {
      throw switch (error.code) {
        GoogleSignInExceptionCode.canceled => const AppFailure(
          FailureKind.cancelled,
        ),
        GoogleSignInExceptionCode.clientConfigurationError ||
        GoogleSignInExceptionCode.providerConfigurationError =>
          SignInUnavailable.configuration,
        _ => const AppFailure(FailureKind.unknown),
      };
    } on SocketException {
      throw const AppFailure(FailureKind.network);
    } on TimeoutException {
      throw const AppFailure(FailureKind.timeout);
    } on MissingPluginException {
      throw SignInUnavailable.configuration;
    } on PlatformException catch (error) {
      // The iOS plugin forwards unclassified NSError domain and code.
      throw switch (error.code) {
        'NSURLErrorDomain: -1001' => const AppFailure(FailureKind.timeout),
        'NSURLErrorDomain: -1003' ||
        'NSURLErrorDomain: -1004' ||
        'NSURLErrorDomain: -1005' ||
        'NSURLErrorDomain: -1006' ||
        'NSURLErrorDomain: -1009' => const AppFailure(FailureKind.network),
        _ => const AppFailure(FailureKind.unknown),
      };
    }
  }

  Future<void> _initialize() async {
    if (_platform != TargetPlatform.android &&
        _platform != TargetPlatform.iOS) {
      throw SignInUnavailable.provider;
    }

    final serverId = _serverClientId;
    if (serverId == null || !_clientIdPattern.hasMatch(serverId)) {
      throw SignInUnavailable.configuration;
    }

    final iosId = _platform == TargetPlatform.iOS ? _iosClientId : null;
    if (_platform == TargetPlatform.iOS) {
      if (iosId == null ||
          iosId == serverId ||
          !_clientIdPattern.hasMatch(iosId)) {
        throw SignInUnavailable.configuration;
      }
      final scheme = iosId.split('.').reversed.join('.');
      final registered = await _iosConfiguration.invokeMethod<bool>(
        'hasUrlScheme',
        scheme,
      );
      if (registered != true) throw SignInUnavailable.configuration;
    }

    await _sdk.initialize(clientId: iosId, serverClientId: serverId);
    if (!_sdk.supportsAuthenticate()) throw SignInUnavailable.provider;
    _initialized = true;
  }
}
