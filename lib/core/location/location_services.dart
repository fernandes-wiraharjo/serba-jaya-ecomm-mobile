import 'dart:async';

import 'package:dio/dio.dart';
import 'package:geocoding/geocoding.dart' as native;
import 'package:geolocator/geolocator.dart';
import 'package:serba_jaya_mobile/core/location/location_models.dart';

class LocationPermissionService {
  const LocationPermissionService();

  Future<LocationIssue?> requestForeground() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return LocationIssue.disabled;
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return switch (permission) {
      LocationPermission.deniedForever => LocationIssue.deniedForever,
      LocationPermission.denied => LocationIssue.denied,
      LocationPermission.whileInUse || LocationPermission.always => null,
      LocationPermission.unableToDetermine => LocationIssue.unavailable,
    };
  }

  Future<bool> openSettings(LocationIssue issue) async {
    try {
      return await (issue == LocationIssue.disabled
          ? Geolocator.openLocationSettings()
          : Geolocator.openAppSettings());
    } on Exception {
      return false;
    }
  }
}

class LocationService {
  const LocationService(this.permissions);

  final LocationPermissionService permissions;

  Future<LocationResult> current() async {
    try {
      final issue = await permissions.requestForeground();
      if (issue != null) return LocationFailure(issue);
      final fix = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
      final accuracy = await Geolocator.getLocationAccuracy();
      return LocationFix((
        latitude: fix.latitude,
        longitude: fix.longitude,
      ), approximate: accuracy == LocationAccuracyStatus.reduced);
    } on TimeoutException {
      return const LocationFailure(LocationIssue.timeout);
    } on LocationServiceDisabledException {
      return const LocationFailure(LocationIssue.disabled);
    } on PermissionDeniedException {
      return const LocationFailure(LocationIssue.denied);
    } on Exception {
      return const LocationFailure(LocationIssue.unavailable);
    }
  }
}

abstract interface class GeocodingService {
  Future<LocationAddress?> reverse(
    LocationCoordinate coordinate,
    CancelToken cancel,
  );
}

/// Uses the OS geocoder. Administrative levels are not consistent across OSes.
class NativeGeocodingService implements GeocodingService {
  const NativeGeocodingService();

  @override
  Future<LocationAddress?> reverse(
    LocationCoordinate coordinate,
    CancelToken cancel,
  ) async {
    final places = await native
        .placemarkFromCoordinates(coordinate.latitude, coordinate.longitude)
        .timeout(const Duration(seconds: 8));
    if (cancel.isCancelled || places.isEmpty) return null;
    final place = places.first;
    String? clean(String? value) {
      final text = value?.trim();
      return text == null || text.isEmpty ? null : text;
    }

    final parts = <String>{
      ?clean(place.street),
      ?clean(place.subLocality),
      ?clean(place.locality),
      ?clean(place.administrativeArea),
      ?clean(place.postalCode),
    };
    return LocationAddress(
      coordinate: coordinate,
      formattedAddress: parts.isEmpty ? null : parts.join(', '),
      street: clean(place.thoroughfare),
      streetNumber: clean(place.subThoroughfare),
      city: clean(place.locality),
      province: clean(place.administrativeArea),
      postalCode: clean(place.postalCode),
      country: clean(place.country),
      countryCode: clean(place.isoCountryCode),
    );
  }
}

/// Implement via the application's backend when Places is available.
abstract interface class PlacesService {
  Future<List<LocationSearchResult>> autocomplete(
    String query, {
    required String sessionToken,
    required CancelToken cancel,
  });

  Future<LocationAddress> details(
    String placeId, {
    required String sessionToken,
    required CancelToken cancel,
  });
}
