import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:serba_jaya_mobile/core/location/location_models.dart';
import 'package:serba_jaya_mobile/core/location/location_search_sheet.dart';
import 'package:serba_jaya_mobile/core/location/location_services.dart';
import 'package:serba_jaya_mobile/l10n/generated/app_localizations.dart';

class _ControlledPlaces implements PlacesService {
  final requests =
      <
        ({
          String query,
          String session,
          CancelToken cancel,
          Completer<List<LocationSearchResult>> response,
        })
      >[];
  String? detailsSession;

  @override
  Future<List<LocationSearchResult>> autocomplete(
    String query, {
    required String sessionToken,
    required CancelToken cancel,
  }) {
    final response = Completer<List<LocationSearchResult>>();
    requests.add((
      query: query,
      session: sessionToken,
      cancel: cancel,
      response: response,
    ));
    return response.future;
  }

  @override
  Future<LocationAddress> details(
    String placeId, {
    required String sessionToken,
    required CancelToken cancel,
  }) async {
    detailsSession = sessionToken;
    return LocationAddress(
      placeId: placeId,
      coordinate: (latitude: -6, longitude: 106),
    );
  }
}

void main() {
  testWidgets(
    'autocomplete debounces, cancels stale results and shares a session with details',
    (tester) async {
      final service = _ControlledPlaces();
      LocationAddress? selected;
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () async {
                  selected = await showModalBottomSheet<LocationAddress>(
                    context: context,
                    builder: (_) => LocationSearchSheet(service: service),
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      final field = find.byType(TextField);

      await tester.enterText(field, 'Dra');
      await tester.pump(const Duration(milliseconds: 120));
      await tester.enterText(field, 'Draft');
      await tester.pump(const Duration(milliseconds: 400));
      expect(service.requests.single.query, 'Draft');

      await tester.enterText(field, 'Lokasi terbaru');
      await tester.pump(const Duration(milliseconds: 400));
      expect(service.requests, hasLength(2));
      expect(service.requests.first.cancel.isCancelled, isTrue);
      service.requests.last.response.complete([
        const LocationSearchResult(placeId: 'new', label: 'Terbaru'),
      ]);
      service.requests.first.response.complete([
        const LocationSearchResult(placeId: 'stale', label: 'Lama'),
      ]);
      await tester.pumpAndSettle();
      expect(find.text('Lama'), findsNothing);
      await tester.tap(find.text('Terbaru'));
      await tester.pumpAndSettle();
      expect(selected?.placeId, 'new');
      expect(service.requests.last.session, service.detailsSession);
    },
  );
}
