import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:serba_jaya_mobile/app/theme/app_theme.dart';
import 'package:serba_jaya_mobile/core/location/location_models.dart';
import 'package:serba_jaya_mobile/core/location/location_providers.dart';
import 'package:serba_jaya_mobile/l10n/generated/app_localizations.dart';

class AppMapMarker extends StatelessWidget {
  const AppMapMarker({super.key, this.size = 60});
  final double size;

  @override
  Widget build(BuildContext context) => Image.asset(
    'assets/auth/location-pin.webp',
    height: size,
    width: size,
    fit: BoxFit.contain,
    excludeFromSemantics: true,
  );
}

/// Uses a native map only when configuration and a real coordinate are ready.
class AppGoogleMap extends ConsumerWidget {
  const AppGoogleMap({
    super.key,
    required this.coordinate,
    this.interactive = false,
    this.onMoveStarted,
    this.onIdle,
    this.padding = EdgeInsets.zero,
  });

  final LocationCoordinate? coordinate;
  final bool interactive;
  final VoidCallback? onMoveStarted;
  final ValueChanged<LocationCoordinate>? onIdle;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final ready = ref.watch(nativeMapReadyProvider);
    final point = coordinate;
    if (ready.asData?.value != true || point == null) {
      final showSetupHint = ref.watch(mapConfigurationProvider).showSetupHint;
      return ColoredBox(
        color: AppColors.authFieldBorder.withValues(alpha: 0.45),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: ready.isLoading
                ? const CircularProgressIndicator()
                : Text(
                    ready.asData?.value == true
                        ? l10n.mapsChooseStartingPoint
                        : showSetupHint &&
                              ref
                                      .watch(mapConfigurationProvider)
                                      .keyFor(Theme.of(context).platform) ==
                                  null
                        ? l10n.mapsDevKeyMissing
                        : l10n.mapsUnavailable,
                    textAlign: TextAlign.center,
                    style: AppTypography.authCaption.copyWith(
                      color: AppColors.authText,
                    ),
                  ),
          ),
        ),
      );
    }
    return _NativeMap(
      coordinate: point,
      interactive: interactive,
      onMoveStarted: onMoveStarted,
      onIdle: onIdle,
      padding: padding,
    );
  }
}

class _NativeMap extends StatefulWidget {
  const _NativeMap({
    required this.coordinate,
    required this.interactive,
    required this.onMoveStarted,
    required this.onIdle,
    required this.padding,
  });

  final LocationCoordinate coordinate;
  final bool interactive;
  final VoidCallback? onMoveStarted;
  final ValueChanged<LocationCoordinate>? onIdle;
  final EdgeInsets padding;

  @override
  State<_NativeMap> createState() => _NativeMapState();
}

class _NativeMapState extends State<_NativeMap> {
  GoogleMapController? _controller;
  LocationCoordinate? _programmatic;
  late LocationCoordinate _camera = widget.coordinate;

  LatLng _point(LocationCoordinate point) =>
      LatLng(point.latitude, point.longitude);

  @override
  void didUpdateWidget(_NativeMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.coordinate != oldWidget.coordinate &&
        widget.coordinate != _camera) {
      unawaited(_move(widget.coordinate));
    }
  }

  Future<void> _move(LocationCoordinate point) async {
    final controller = _controller;
    if (controller == null) return;
    _programmatic = point;
    try {
      await controller.moveCamera(CameraUpdate.newLatLng(_point(point)));
    } on Exception {
      _programmatic = null;
      // Native view can disappear while the route is being dismissed.
    }
  }

  @override
  Widget build(BuildContext context) => GoogleMap(
    initialCameraPosition: CameraPosition(
      target: _point(widget.coordinate),
      zoom: 16,
    ),
    onMapCreated: (controller) {
      _controller = controller;
      if (_camera != widget.coordinate) unawaited(_move(widget.coordinate));
    },
    padding: widget.padding,
    trafficEnabled: false,
    myLocationButtonEnabled: false,
    mapToolbarEnabled: false,
    scrollGesturesEnabled: widget.interactive,
    zoomGesturesEnabled: widget.interactive,
    zoomControlsEnabled: false,
    rotateGesturesEnabled: false,
    tiltGesturesEnabled: false,
    onCameraMoveStarted: () {
      if (_programmatic == null) widget.onMoveStarted?.call();
    },
    onCameraMove: (camera) {
      _camera = (
        latitude: camera.target.latitude,
        longitude: camera.target.longitude,
      );
    },
    onCameraIdle: () {
      final requested = _programmatic;
      _programmatic = null;
      if (requested != null &&
          (requested.latitude - _camera.latitude).abs() < 0.000001 &&
          (requested.longitude - _camera.longitude).abs() < 0.000001) {
        return;
      }
      widget.onIdle?.call(_camera);
    },
  );
  // GoogleMap owns and disposes its controller when it unmounts.
}
