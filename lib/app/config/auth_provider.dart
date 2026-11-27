import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart' hide GoogleIdentity;
import 'package:serba_jaya_mobile/app/config/app_config.dart';
import 'package:serba_jaya_mobile/features/auth/data/google_identity_source.dart';
import 'package:serba_jaya_mobile/features/auth/domain/google_identity.dart';

final googleIdentityProvider = Provider<RequestGoogleIdentity>((ref) {
  final config = ref.watch(appConfigProvider);
  return GoogleIdentitySource(
    sdk: GoogleSignIn.instance,
    platform: defaultTargetPlatform,
    serverClientId: config.googleServerClientId,
    iosClientId: config.googleIosClientId,
  ).requestIdentity;
});
