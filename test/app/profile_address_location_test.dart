import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:serba_jaya_mobile/app/app.dart';
import 'package:serba_jaya_mobile/app/config/app_config.dart';
import 'package:serba_jaya_mobile/app/router/app_router.dart';
import 'package:serba_jaya_mobile/core/location/location_models.dart';
import 'package:serba_jaya_mobile/core/location/location_providers.dart';
import 'package:serba_jaya_mobile/core/location/location_services.dart';
import 'package:serba_jaya_mobile/features/auth/presentation/session_controller.dart';
import 'package:serba_jaya_mobile/features/profile/presentation/profile_address_page.dart';

import '../support/fakes.dart';

const _point = (latitude: -6.2, longitude: 106.8);

class _TestGps extends LocationService {
  _TestGps(this.result) : super(const LocationPermissionService());

  LocationResult result;

  @override
  Future<LocationResult> current() async => result;
}

class _TestGeocoder implements GeocodingService {
  @override
  Future<LocationAddress?> reverse(
    LocationCoordinate coordinate,
    CancelToken cancel,
  ) async => LocationAddress(
    coordinate: coordinate,
    formattedAddress: 'Alamat uji terpilih',
    street: 'Jalan uji',
    city: 'Kota uji',
  );
}

void main() {
  Future<ProviderContainer> mount(WidgetTester tester, _TestGps gps) async {
    final container = ProviderContainer(
      overrides: [
        appConfigProvider.overrideWithValue(
          AppConfig.parse(environment: 'dev'),
        ),
        sessionRepositoryProvider.overrideWithValue(FakeSessionRepository()),
        mapConfigurationProvider.overrideWithValue(
          const MapConfiguration(showSetupHint: true),
        ),
        locationServiceProvider.overrideWithValue(gps),
        geocodingServiceProvider.overrideWithValue(_TestGeocoder()),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const SerbaJayaApp(),
      ),
    );
    await tester.pumpAndSettle();
    return container;
  }

  Finder field(AddressField key) => find.descendant(
    of: find.byKey(ValueKey('address-${key.name}')),
    matching: find.byType(TextFormField),
  );

  Future<void> enter(
    WidgetTester tester,
    AddressField key,
    String value,
  ) async {
    await tester.ensureVisible(field(key));
    await tester.pumpAndSettle();
    await tester.enterText(field(key), value);
    await tester.pumpAndSettle();
  }

  testWidgets(
    'without a key, GPS can fill missing fields and save a local address',
    (tester) async {
      final container = await mount(
        tester,
        _TestGps(const LocationFix(_point, approximate: true)),
      );
      final router = container.read(appRouterProvider);
      router.go('/profile/addresses/new');
      await tester.pumpAndSettle();
      expect(
        find.text('Google Maps API Key belum dikonfigurasi.'),
        findsOneWidget,
      );

      await enter(tester, AddressField.details, 'Detail yang diketik sendiri');
      final edit = find.text('Ubah Lokasi');
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      await tester.ensureVisible(edit);
      await tester.pumpAndSettle();
      await tester.tap(edit);
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Gunakan lokasi saat ini'));
      await tester.pumpAndSettle();
      expect(find.text('Alamat uji terpilih'), findsOneWidget);
      expect(
        find.text('Lokasi perkiraan. Periksa kembali titik alamat.'),
        findsOneWidget,
      );
      await tester.tap(find.text('Simpan Titik Lokasi'));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<TextFormField>(field(AddressField.details))
            .controller!
            .text,
        'Detail yang diketik sendiri',
      );
      expect(
        tester.widget<TextFormField>(field(AddressField.city)).controller!.text,
        'Kota uji',
      );

      final save = find.text('Simpan alamat');
      await tester.ensureVisible(save);
      await tester.pumpAndSettle();
      await tester.tap(save);
      await tester.pumpAndSettle();
      expect(container.read(profileAddressesProvider), isEmpty);
      expect(find.text('Wajib diisi.'), findsWidgets);

      for (final key in [
        AddressField.label,
        AddressField.recipient,
        AddressField.phone,
        AddressField.province,
        AddressField.district,
        AddressField.village,
        AddressField.postalCode,
      ]) {
        await enter(
          tester,
          key,
          key == AddressField.phone ? '081234567890' : 'Isi uji ${key.name}',
        );
      }
      await tester.ensureVisible(save);
      await tester.pumpAndSettle();
      await tester.tap(save);
      await tester.pumpAndSettle();
      final saved = container.read(profileAddressesProvider).entries.single;
      expect(saved.value.location?.coordinate, _point);
      expect(saved.value[AddressField.details], 'Detail yang diketik sendiri');

      router.go('/profile/addresses/${saved.key}/edit');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ubah Lokasi'));
      await tester.pumpAndSettle();
      expect(find.text('Alamat uji terpilih'), findsOneWidget);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      await enter(tester, AddressField.details, 'Perubahan yang dibatalkan');
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(
        container.read(
          profileAddressesProvider,
        )[saved.key]![AddressField.details],
        'Detail yang diketik sendiri',
      );
    },
  );

  testWidgets(
    'picker exposes denied, permanent, disabled, timeout and unavailable states',
    (tester) async {
      final gps = _TestGps(const LocationFailure(LocationIssue.denied));
      final container = await mount(tester, gps);
      container.read(appRouterProvider).go('/profile/addresses/location');
      await tester.pumpAndSettle();
      for (final (issue, label) in [
        (
          LocationIssue.denied,
          'Izin lokasi ditolak. Coba lagi atau isi alamat manual.',
        ),
        (LocationIssue.deniedForever, 'Izinkan lokasi di pengaturan aplikasi.'),
        (
          LocationIssue.disabled,
          'Aktifkan layanan lokasi untuk menggunakan GPS.',
        ),
        (LocationIssue.timeout, 'GPS belum menemukan lokasi. Coba lagi.'),
        (LocationIssue.unavailable, 'Lokasi tidak dapat diambil.'),
      ]) {
        gps.result = LocationFailure(issue);
        await tester.tap(find.byTooltip('Gunakan lokasi saat ini'));
        await tester.pumpAndSettle();
        expect(find.text(label), findsOneWidget);
        expect(
          tester
              .widget<FilledButton>(
                find.widgetWithText(FilledButton, 'Simpan Titik Lokasi'),
              )
              .onPressed,
          isNull,
        );
      }
      await tester.tap(find.text('Cari alamat'));
      await tester.pumpAndSettle();
      expect(find.text('Pencarian alamat belum tersedia.'), findsOneWidget);
    },
  );
}
