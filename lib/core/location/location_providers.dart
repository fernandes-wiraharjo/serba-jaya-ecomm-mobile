import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:serba_jaya_mobile/core/location/location_services.dart';

class MapConfiguration {
  const MapConfiguration({
    this.androidKey,
    this.iosKey,
    this.showSetupHint = false,
  });
  final String? androidKey, iosKey;
  final bool showSetupHint;

  String? keyFor(TargetPlatform platform) => switch (platform) {
    TargetPlatform.android => androidKey,
    TargetPlatform.iOS => iosKey,
    _ => null,
  };
}

final mapConfigurationProvider = Provider<MapConfiguration>(
  (ref) => const MapConfiguration(),
);

final nativeMapReadyProvider = FutureProvider<bool>((ref) async {
  final config = ref.watch(mapConfigurationProvider);
  final platform = defaultTargetPlatform;
  final key = config.keyFor(platform);
  if (kIsWeb || key == null) return false;
  if (platform == TargetPlatform.android) return true;
  try {
    return await const MethodChannel(
          'id.serbajaya.ecommerce/maps_config',
        ).invokeMethod<bool>('initialize', key) ??
        false;
  } on Exception {
    return false;
  }
});

final locationPermissionProvider = Provider<LocationPermissionService>(
  (ref) => const LocationPermissionService(),
);
final locationServiceProvider = Provider<LocationService>(
  (ref) => LocationService(ref.watch(locationPermissionProvider)),
);
final geocodingServiceProvider = Provider<GeocodingService>(
  (ref) => const NativeGeocodingService(),
);
final placesServiceProvider = Provider<PlacesService?>((ref) => null);
