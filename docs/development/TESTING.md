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

## Runtime di perangkat fisik

Sebelum menjalankan aplikasi, jalankan `flutter devices`. Pilih hanya ID Android/iOS fisik yang tersambung lewat USB atau wireless debugging, lalu berikan ID tersebut secara eksplisit bersama flavor dan file environment, misalnya:

```bash
flutter run -d DEVICE_ID --flavor dev --dart-define-from-file=config/dev.example.json
```

Jangan menjalankan emulator atau simulator sebagai pengganti. Jika tidak ada perangkat fisik, lewati runtime test, jalankan format/analyze/unit/widget test yang relevan, dan catat pengujian perangkat sebagai pending. Aturan tetap dan batas penggunaan sumber daya ada di [AGENTS.md](../../AGENTS.md).

```bash
flutter test integration_test/app_startup_test.dart -d <device-id> --dart-define-from-file=config/dev.example.json
```

Smoke test perangkat memulai entry point aplikasi dan membuka guard keranjang dari guest shell. Tidak memerlukan kredensial. Hasil host aktual tercatat di [status](../PROJECT_STATUS.md). Runtime test hanya dijalankan pada perangkat fisik.
