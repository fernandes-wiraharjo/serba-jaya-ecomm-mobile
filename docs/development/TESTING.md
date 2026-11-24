# Pengujian

```bash
flutter pub get
dart format .
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
```

Jika runner paralel tertahan pada mesin lokal, ulangi suite lengkap dengan `flutter test --concurrency=1 --reporter expanded`. Hasil eksekusi parsial tidak menghitung sebagai kelulusan suite.

`scripts/check.sh` memakai lockfile yang sama untuk verifikasi lokal dan CI. Tes unit dan widget memeriksa parsing environment, mapping Dio, adapter jaringan tanpa I/O, header sesi, storage fake, expiry/logout, startup, navigasi, guard dan panel feedback.

```bash
flutter test integration_test/app_startup_test.dart -d <device-id> --dart-define-from-file=config/dev.example.json
```

Smoke test perangkat memulai entry point aplikasi dan membuka guard keranjang dari guest shell. Tidak memerlukan kredensial. Hasil host aktual tercatat di [status](../PROJECT_STATUS.md).
