import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:serba_jaya_mobile/app/theme/app_assets.dart';
import 'package:serba_jaya_mobile/app/theme/app_theme.dart';
import 'package:serba_jaya_mobile/core/location/app_google_map.dart';
import 'package:serba_jaya_mobile/core/location/location_models.dart';
import 'package:serba_jaya_mobile/core/location/location_picker_controller.dart';
import 'package:serba_jaya_mobile/core/location/location_providers.dart';
import 'package:serba_jaya_mobile/core/location/location_search_sheet.dart';
import 'package:serba_jaya_mobile/l10n/generated/app_localizations.dart';
import 'package:serba_jaya_mobile/shared/motion/app_overlays.dart';
import 'package:serba_jaya_mobile/shared/widgets/header/app_header.dart';
import 'package:serba_jaya_mobile/shared/widgets/header/header_action_button.dart';

class AppLocationPicker extends ConsumerWidget {
  const AppLocationPicker({super.key, this.initial});
  final LocationAddress? initial;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = AppLocalizations.of(context);
    final state = ref.watch(locationPickerProvider(initial));
    final controller = ref.read(locationPickerProvider(initial).notifier);
    final point = state.selection?.coordinate;
    final mapReady = ref.watch(nativeMapReadyProvider).asData?.value == true;
    final issue = state.issue;
    final needsSettings =
        issue == LocationIssue.deniedForever || issue == LocationIssue.disabled;

    Future<void> openSearch() async {
      final result = await showAppBottomSheet<LocationAddress>(
        context: context,
        topRadius: const Radius.circular(12),
        builder: (_) =>
            LocationSearchSheet(service: ref.read(placesServiceProvider)),
      );
      if (context.mounted && result != null) controller.choosePlace(result);
    }

    return Scaffold(
      body: Column(
        children: [
          AppHeader(
            child: Row(
              children: [
                const SizedBox(width: 16),
                HeaderActionButton(
                  assetPath: AppAssets.headerBack,
                  semanticLabel: s.authBack,
                  width: 24,
                  height: 24,
                  surfaceColor: Colors.white,
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(s.mapsTitle, style: AppTypography.headerTitle),
                ),
              ],
            ),
          ),
          Expanded(
            child: SafeArea(
              top: false,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  AppGoogleMap(
                    coordinate: point,
                    interactive: true,
                    onMoveStarted: controller.beginMove,
                    onIdle: controller.cameraIdle,
                    padding: const EdgeInsets.only(bottom: 80),
                  ),
                  if (mapReady && point != null)
                    IgnorePointer(
                      child: Center(
                        child: FractionalTranslation(
                          // Anchor the visible tip to the padded camera target.
                          translation: const Offset(0, -.5),
                          child: Transform.translate(
                            offset: const Offset(0, -35),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: AppColors.authPrimary,
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 10,
                                    ),
                                    child: Text(
                                      s.mapsPinLabel,
                                      style: AppTypography.authHeading.copyWith(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                const AppMapMarker(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    top: 28,
                    left: 25,
                    right: 25,
                    child: Material(
                      elevation: 3,
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 12,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              s.mapsSelected,
                              style: AppTypography.authCaption,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              state.locating
                                  ? s.mapsLocating
                                  : state.resolving
                                  ? s.mapsResolving
                                  : state.selection?.formattedAddress ??
                                        (point != null
                                            ? s.mapsManualAddress
                                            : s.mapsNoSelection),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.authInput,
                            ),
                            if (state.approximate)
                              Text(
                                s.mapsApproximate,
                                style: AppTypography.authCaption,
                              ),
                            if (issue != null) ...[
                              Text(switch (issue) {
                                LocationIssue.denied => s.mapsGpsDenied,
                                LocationIssue.deniedForever =>
                                  s.mapsGpsDeniedForever,
                                LocationIssue.disabled => s.mapsGpsDisabled,
                                LocationIssue.timeout => s.mapsGpsTimeout,
                                LocationIssue.unavailable =>
                                  s.mapsGpsUnavailable,
                              }),
                              if (needsSettings)
                                TextButton(
                                  onPressed: () => ref
                                      .read(locationPermissionProvider)
                                      .openSettings(issue),
                                  child: Text(s.mapsSettings),
                                ),
                            ],
                            TextButton(
                              onPressed: state.locating ? null : openSearch,
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.authPrimary,
                                minimumSize: const Size(48, 48),
                                padding: EdgeInsets.zero,
                              ),
                              child: Text(s.mapsSearch),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 22,
                    bottom: 106,
                    child: Material(
                      elevation: 3,
                      color: Colors.white,
                      shape: const CircleBorder(),
                      child: IconButton(
                        tooltip: s.mapsLocate,
                        constraints: const BoxConstraints.tightFor(
                          width: 50,
                          height: 50,
                        ),
                        onPressed: state.locating ? null : controller.useGps,
                        icon: state.locating
                            ? const SizedBox.square(
                                dimension: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Image.asset(
                                'assets/auth/location-current.webp',
                                width: 34.72,
                                height: 34.72,
                              ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 22,
                    right: 22,
                    bottom: 40,
                    child: FilledButton(
                      onPressed: state.canSave
                          ? () => Navigator.of(context).pop(state.selection)
                          : null,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.authPrimary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(0, 40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: AppTypography.authHeading,
                      ),
                      child: Text(s.mapsSave, textAlign: TextAlign.center),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
