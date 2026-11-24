import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:serba_jaya_mobile/core/storage/secure_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

final secureStoreProvider = Provider<SecureStore>((ref) {
  return const PlatformSecureStore(
    FlutterSecureStorage(
      iOptions: IOSOptions(
        accessibility: KeychainAccessibility.unlocked_this_device,
      ),
    ),
  );
});

/// Preferensi non-sensitif, diakses hanya jika fitur membutuhkannya.
final preferencesProvider = Provider<SharedPreferencesAsync>(
  (ref) => SharedPreferencesAsync(),
);
