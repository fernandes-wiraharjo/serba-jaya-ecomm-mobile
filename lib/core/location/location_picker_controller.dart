import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:serba_jaya_mobile/core/location/location_models.dart';
import 'package:serba_jaya_mobile/core/location/location_providers.dart';

class LocationPickerState {
  const LocationPickerState({
    this.selection,
    this.locating = false,
    this.moving = false,
    this.resolving = false,
    this.approximate = false,
    this.geocodeFailed = false,
    this.issue,
  });

  final LocationAddress? selection;
  final bool locating, moving, resolving, approximate, geocodeFailed;
  final LocationIssue? issue;

  bool get canSave => selection != null && !moving && !locating && !resolving;
}

final locationPickerProvider = NotifierProvider.autoDispose
    .family<LocationPickerController, LocationPickerState, LocationAddress?>(
      LocationPickerController.new,
    );

class LocationPickerController extends Notifier<LocationPickerState> {
  LocationPickerController(this.initial);
  final LocationAddress? initial;

  Timer? _debounce;
  CancelToken? _reverse;
  int _lookupVersion = 0;

  @override
  LocationPickerState build() {
    ref.onDispose(_cancelReverse);
    return LocationPickerState(selection: initial);
  }

  void _cancelReverse() {
    _lookupVersion++;
    _debounce?.cancel();
    _reverse?.cancel();
  }

  Future<void> useGps() async {
    if (state.locating) return;
    _cancelReverse();
    state = LocationPickerState(selection: state.selection, locating: true);
    final result = await ref.read(locationServiceProvider).current();
    if (!ref.mounted) return;
    switch (result) {
      case LocationFix(:final coordinate, :final approximate):
        _resolve(coordinate, approximate: approximate);
      case LocationFailure(:final issue):
        state = LocationPickerState(selection: state.selection, issue: issue);
    }
  }

  void beginMove() {
    if (state.locating) return;
    _cancelReverse();
    state = LocationPickerState(selection: state.selection, moving: true);
  }

  void cameraIdle(LocationCoordinate coordinate) {
    if (state.locating) return;
    if (state.selection?.coordinate == coordinate && !state.moving) return;
    if (state.selection?.coordinate == coordinate &&
        state.selection?.formattedAddress != null) {
      state = LocationPickerState(
        selection: state.selection,
        approximate: state.approximate,
      );
      return;
    }
    _resolve(coordinate);
  }

  void choosePlace(LocationAddress place) {
    if (state.locating) return;
    _cancelReverse();
    state = LocationPickerState(selection: place);
  }

  void _resolve(LocationCoordinate coordinate, {bool approximate = false}) {
    _cancelReverse();
    final version = _lookupVersion;
    final candidate = LocationAddress(coordinate: coordinate);
    state = LocationPickerState(
      selection: candidate,
      resolving: true,
      approximate: approximate,
    );
    _debounce = Timer(const Duration(milliseconds: 350), () async {
      final token = _reverse = CancelToken();
      LocationAddress? address;
      try {
        address = await ref
            .read(geocodingServiceProvider)
            .reverse(coordinate, token);
      } on Exception {
        // Coordinate remains selectable if reverse geocoding fails.
      }
      if (!ref.mounted || token.isCancelled || _lookupVersion != version) {
        return;
      }
      state = LocationPickerState(
        selection: address ?? candidate,
        approximate: approximate,
        geocodeFailed: address?.formattedAddress == null,
      );
    });
  }
}
