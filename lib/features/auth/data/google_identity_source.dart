import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart' hide GoogleIdentity;
import 'package:serba_jaya_mobile/core/errors/app_failure.dart';
import 'package:serba_jaya_mobile/features/auth/domain/google_identity.dart';
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

  Future<GoogleIdentity> requestIdentity() async {
    try {
      if (!_initialized) await _initialize();
      final account = await _sdk.authenticate();
      final idToken = account.authentication.idToken;
      final claims = _readUnverifiedClaims(idToken);
      return GoogleIdentity(
        registrationData: GoogleRegistrationData(
          googleUserId: account.id,
          displayName: account.displayName ?? _stringClaim(claims, 'name'),
          email: account.email,
          photoUrl: account.photoUrl,
          givenName: _stringClaim(claims, 'given_name'),
          familyName: _stringClaim(claims, 'family_name'),
          emailVerified: claims['email_verified'] is bool
              ? claims['email_verified'] as bool
              : null,
          unverifiedClaims: claims,
        ),
        idToken: idToken,
      );
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

  Map<String, Object?> _readUnverifiedClaims(String? token) {
    if (token == null || token.isEmpty) return const {};
    try {
      final parts = token.split('.');
      if (parts.length != 3) return const {};
      final normalized = base64Url.normalize(parts[1]);
      final value = jsonDecode(utf8.decode(base64Url.decode(normalized)));
      if (value is! Map<String, dynamic>) return const {};
      return Map<String, Object?>.unmodifiable(value);
    } on FormatException {
      return const {};
    }
  }

  String? _stringClaim(Map<String, Object?> claims, String key) =>
      claims[key] is String ? claims[key] as String : null;

  Future<void> _initialize() async {
    if (_platform != TargetPlatform.android &&
        _platform != TargetPlatform.iOS) {
      throw SignInUnavailable.provider;
    }

    final serverId = _serverClientId;
    if (serverId != null && !_clientIdPattern.hasMatch(serverId)) {
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

    if (_platform == TargetPlatform.iOS &&
        (serverId == null || !_clientIdPattern.hasMatch(iosId!))) {
      throw SignInUnavailable.configuration;
    }
    await _sdk.initialize(clientId: iosId, serverClientId: serverId);
    if (!_sdk.supportsAuthenticate()) throw SignInUnavailable.provider;
    _initialized = true;
  }
}
