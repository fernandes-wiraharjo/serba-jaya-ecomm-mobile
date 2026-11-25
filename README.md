# Serba Jaya Ecommerce

Fondasi Flutter untuk aplikasi pelanggan Android dan iOS. Proyek memiliki flavor dev, staging, dan prod, konfigurasi API/sesi, UI autentikasi, serta dokumentasi setup. Lihat [status proyek](docs/PROJECT_STATUS.md) dan [indeks dokumentasi](docs/DOCUMENTATION_INDEX.md).

## Mulai

Gunakan Flutter Stable **3.41.9** dan Dart **3.11.5** yang disertakan Flutter. Siapkan Android SDK dan JDK 17 untuk Android, atau Xcode dan CocoaPods pada macOS untuk iOS. Lihat [Setup](docs/development/SETUP.md) untuk rincian.

```bash
flutter doctor -v
flutter pub get
flutter devices
flutter run -d DEVICE_ID --flavor dev --dart-define-from-file=config/dev.example.json
```

Ganti `DEVICE_ID` dengan ID perangkat Android/iOS fisik dari `flutter devices`; jangan pilih emulator atau simulator.

Untuk staging dan production, pasangkan `--flavor staging` dengan `config/staging.example.json`, atau `--flavor prod` dengan `config/prod.example.json`. Pilihan VS Code tersedia untuk ketiganya. Flavor dan `APP_ENV` divalidasi saat startup. [Panduan environment](docs/development/ENVIRONMENT.md)

Konfigurasi contoh menjalankan shell tanpa backend. Bottom Navigation Bar menghubungkan Beranda, Keranjang, Chat, Pesanan, dan Profil; Beranda dan Chat dapat dibuka sebagai tamu. Keranjang, Pesanan, Profil, dan Notifikasi memerlukan sesi aplikasi yang tervalidasi. Token navigasi berasal dari catatan inspeksi Figma sebelumnya, sedangkan ikon dan treatment badge masih provisional. Header hanya memiliki boundary integrasi tanpa desain visual final. Lihat [navigasi](docs/components/BOTTOM_NAVIGATION_BAR.md), [Header](docs/components/HEADER.md), dan [UI autentikasi](docs/features/AUTHENTICATION_UI.md).

```bash
bash scripts/check.sh
```

[Kontribusi](CONTRIBUTING.md) · [Catatan perubahan](CHANGELOG.md) · [Panduan agen](AGENTS.md)

Data pendaftaran OAuth Android dan iOS serta status sertifikat tercatat di [panduan GCP OAuth](docs/integrations/GCP_OAUTH_REGISTRATION.md). OAuth provider belum diaktifkan.
