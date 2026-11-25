import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:serba_jaya_mobile/core/errors/app_failure.dart';
import 'package:serba_jaya_mobile/features/auth/data/google_identity_source.dart';
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
    expect(await identity.requestIdToken(), 'id-token-fixture');
    expect(await identity.requestIdToken(), 'id-token-fixture');
    expect(sdk.initializations, [(null, _serverId)]);
    expect(sdk.authentications, 2);
  });

  test('missing or malformed server client prevents SDK use', () async {
    for (final value in [null, 'invalid']) {
      await expectLater(
        source(serverClientId: value).requestIdToken(),
        throwsA(SignInUnavailable.configuration),
      );
    }
    expect(sdk.initializations, isEmpty);
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
        identity.requestIdToken(),
        throwsA(SignInUnavailable.configuration),
      );
      expect(sdk.initializations, isEmpty);
      expect(sdk.authentications, 0);

      registered = true;
      expect(await identity.requestIdToken(), 'id-token-fixture');
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
        identity.requestIdToken(),
        throwsA(
          isA<AppFailure>().having((failure) => failure.kind, 'kind', kind),
        ),
      );
    }
    sdk.failure = const GoogleSignInException(
      code: GoogleSignInExceptionCode.clientConfigurationError,
    );
    await expectLater(
      identity.requestIdToken(),
      throwsA(SignInUnavailable.configuration),
    );
    sdk.failure = null;
    sdk.idToken = null;
    await expectLater(
      identity.requestIdToken(),
      throwsA(
        isA<AppFailure>().having(
          (failure) => failure.kind,
          'kind',
          FailureKind.invalidResponse,
        ),
      ),
    );
    sdk.idToken = 'id-token-fixture';
    expect(await identity.requestIdToken(), 'id-token-fixture');
    expect(sdk.initializations, [(null, _serverId)]);
  });

  test(
    'sign-in action sends one token per request and can be retried',
    () async {
      var pending = Completer<String>();
      var requests = 0;
      final exchanged = <String>[];
      final container = ProviderContainer.test(
        overrides: [
          requestGoogleIdTokenProvider.overrideWithValue(() {
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
      pending.complete('id-token-fixture');

      await Future.wait([first, second]);
      expect(requests, 1);
      expect(exchanged, ['id-token-fixture']);

      pending = Completer<String>()..complete('retry-fixture');
      await action(AuthSignInMethod.google);
      expect(requests, 2);
      expect(exchanged, ['id-token-fixture', 'retry-fixture']);
    },
  );
}

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
  GoogleSignInAuthentication get authentication =>
      GoogleSignInAuthentication(idToken: idToken);
}
