import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart' hide GoogleIdentity;
import 'package:serba_jaya_mobile/core/errors/app_failure.dart';
import 'package:serba_jaya_mobile/features/auth/data/google_identity_source.dart';
import 'package:serba_jaya_mobile/features/auth/domain/google_identity.dart';
import 'package:serba_jaya_mobile/features/auth/domain/sign_in_failure.dart';
import 'package:serba_jaya_mobile/features/auth/presentation/sign_in_action.dart';

const _serverId = 'server-fixture.apps.googleusercontent.com';
const _iosId = 'ios-fixture.apps.googleusercontent.com';

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  const iosConfig = MethodChannel(
    'id.serbajaya.ecommerce/google_sign_in_config',
  );
  late _FakeGoogleSignIn sdk;

  setUp(() => sdk = _FakeGoogleSignIn());
  tearDown(
    () => binding.defaultBinaryMessenger.setMockMethodCallHandler(
      iosConfig,
      null,
    ),
  );

  GoogleIdentitySource source({
    TargetPlatform platform = TargetPlatform.android,
    String? serverClientId = _serverId,
    String? iosClientId,
  }) => GoogleIdentitySource(
    sdk: sdk,
    platform: platform,
    serverClientId: serverClientId,
    iosClientId: iosClientId,
  );

  test('Android uses the server client and initializes only once', () async {
    final identity = source(iosClientId: _iosId);
    final result = await identity.requestIdentity();
    expect(result.idToken, 'id-token-fixture');
    expect(result.registrationData.googleUserId, 'google-user-fixture');
    expect(result.registrationData.displayName, 'Google User');
    expect(result.registrationData.email, 'google@example.test');
    expect(result.registrationData.photoUrl, 'https://example.test/photo');
    expect((await identity.requestIdentity()).idToken, result.idToken);
    expect(sdk.initializations, [(null, _serverId)]);
    expect(sdk.authentications, 2);
  });

  test('Android can retrieve profile without a server client ID', () async {
    final identity = await source(serverClientId: null).requestIdentity();
    expect(identity.registrationData.googleUserId, 'google-user-fixture');
    expect(identity.idToken, 'id-token-fixture');
    expect(sdk.initializations, [(null, null)]);
    sdk = _FakeGoogleSignIn();
    await expectLater(
      source(serverClientId: 'invalid').requestIdentity(),
      throwsA(SignInUnavailable.configuration),
    );
    expect(sdk.authentications, 0);
  });

  test(
    'iOS requires a matching reversed client ID in the app bundle',
    () async {
      var registered = false;
      binding.defaultBinaryMessenger.setMockMethodCallHandler(iosConfig, (
        call,
      ) async {
        expect(call.method, 'hasUrlScheme');
        expect(call.arguments, 'com.googleusercontent.apps.ios-fixture');
        return registered;
      });
      final identity = source(
        platform: TargetPlatform.iOS,
        iosClientId: _iosId,
      );

      await expectLater(
        identity.requestIdentity(),
        throwsA(SignInUnavailable.configuration),
      );
      expect(sdk.initializations, isEmpty);
      expect(sdk.authentications, 0);

      registered = true;
      expect((await identity.requestIdentity()).idToken, 'id-token-fixture');
      expect(sdk.initializations, [(_iosId, _serverId)]);
    },
  );

  test('SDK errors are reduced to safe categories and permit retry', () async {
    final identity = source();
    for (final (error, kind) in [
      (
        const GoogleSignInException(code: GoogleSignInExceptionCode.canceled),
        FailureKind.cancelled,
      ),
      (const SocketException('fixture'), FailureKind.network),
      (PlatformException(code: 'NSURLErrorDomain: -1009'), FailureKind.network),
      (TimeoutException('fixture'), FailureKind.timeout),
      (
        const GoogleSignInException(
          code: GoogleSignInExceptionCode.unknownError,
          description: 'sensitive-fixture',
        ),
        FailureKind.unknown,
      ),
    ]) {
      sdk.failure = error;
      await expectLater(
        identity.requestIdentity(),
        throwsA(
          isA<AppFailure>().having((failure) => failure.kind, 'kind', kind),
        ),
      );
    }
    sdk.failure = const GoogleSignInException(
      code: GoogleSignInExceptionCode.clientConfigurationError,
    );
    await expectLater(
      identity.requestIdentity(),
      throwsA(SignInUnavailable.configuration),
    );
    sdk.failure = null;
    sdk.idToken = null;
    expect((await identity.requestIdentity()).idToken, isNull);
    sdk.idToken = 'id-token-fixture';
    expect((await identity.requestIdentity()).idToken, 'id-token-fixture');
    expect(sdk.initializations, [(null, _serverId)]);
  });

  test(
    'sign-in action sends one token per request and can be retried',
    () async {
      var pending = Completer<GoogleIdentity>();
      var requests = 0;
      final exchanged = <String>[];
      final container = ProviderContainer.test(
        overrides: [
          requestGoogleIdentityProvider.overrideWithValue(() {
            requests++;
            return pending.future;
          }),
          exchangeGoogleIdentityProvider.overrideWithValue((idToken) async {
            exchanged.add(idToken);
          }),
        ],
      );
      final action = container.read(signInActionProvider);
      final first = action(AuthSignInMethod.google);
      final second = action(AuthSignInMethod.google);
      pending.complete(_identity('id-token-fixture'));

      await Future.wait([first, second]);
      expect(requests, 1);
      expect(exchanged, ['id-token-fixture']);

      pending = Completer<GoogleIdentity>()
        ..complete(_identity('retry-fixture'));
      await action(AuthSignInMethod.google);
      expect(requests, 2);
      expect(exchanged, ['id-token-fixture', 'retry-fixture']);
    },
  );
}

GoogleIdentity _identity(String idToken) => GoogleIdentity(
  registrationData: const GoogleRegistrationData(
    googleUserId: 'google-user-fixture',
    displayName: 'Google User',
    email: 'google@example.test',
    photoUrl: 'https://example.test/photo',
  ),
  idToken: idToken,
);

class _FakeGoogleSignIn extends Fake implements GoogleSignIn {
  final initializations = <(String?, String?)>[];
  var authentications = 0;
  String? idToken = 'id-token-fixture';
  Exception? failure;

  @override
  Future<void> initialize({
    String? clientId,
    String? serverClientId,
    String? nonce,
    String? hostedDomain,
  }) async => initializations.add((clientId, serverClientId));

  @override
  bool supportsAuthenticate() => true;

  @override
  Future<GoogleSignInAccount> authenticate({
    List<String> scopeHint = const [],
  }) async {
    authentications++;
    if (failure case final error?) throw error;
    return _FakeGoogleAccount(idToken);
  }
}

class _FakeGoogleAccount extends Fake implements GoogleSignInAccount {
  _FakeGoogleAccount(this.idToken);

  final String? idToken;

  @override
  String get id => 'google-user-fixture';

  @override
  String? get displayName => 'Google User';

  @override
  String get email => 'google@example.test';

  @override
  String? get photoUrl => 'https://example.test/photo';

  @override
  GoogleSignInAuthentication get authentication =>
      GoogleSignInAuthentication(idToken: idToken);
}
