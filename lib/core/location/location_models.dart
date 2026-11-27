typedef LocationCoordinate = ({double latitude, double longitude});

class LocationAddress {
  const LocationAddress({
    required this.coordinate,
    this.placeId,
    this.formattedAddress,
    this.street,
    this.streetNumber,
    this.village,
    this.district,
    this.city,
    this.province,
    this.postalCode,
    this.country,
    this.countryCode,
  });

  final LocationCoordinate coordinate;
  final String? placeId,
      formattedAddress,
      street,
      streetNumber,
      village,
      district,
      city,
      province,
      postalCode,
      country,
      countryCode;
}

class LocationSearchResult {
  const LocationSearchResult({required this.placeId, required this.label});

  final String placeId;
  final String label;
}

enum LocationIssue { denied, deniedForever, disabled, timeout, unavailable }

sealed class LocationResult {
  const LocationResult();
}

class LocationFix extends LocationResult {
  const LocationFix(this.coordinate, {required this.approximate});

  final LocationCoordinate coordinate;
  final bool approximate;
}

class LocationFailure extends LocationResult {
  const LocationFailure(this.issue);
  final LocationIssue issue;
}
