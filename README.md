# Serba Jaya Ecommerce

Fondasi Flutter untuk aplikasi pelanggan Android dan iOS. Phase 1 menyediakan shell pengembangan, konfigurasi lingkungan, infrastruktur API dan sesi, lokalisasi Indonesia, serta tes. Lihat [status proyek](docs/PROJECT_STATUS.md) dan [indeks dokumentasi](docs/DOCUMENTATION_INDEX.md).

## Mulai

Gunakan Flutter Stable **3.41.9** dan Dart **3.11.5** yang disertakan Flutter. Siapkan Android SDK dan JDK 17 untuk Android, atau Xcode dan CocoaPods pada macOS untuk iOS. Lihat [Setup](docs/development/SETUP.md) untuk rincian.

```bash
flutter doctor -v
flutter pub get
flutter devices
flutter run -d <device-id> --dart-define-from-file=config/dev.example.json
```

Konfigurasi contoh menjalankan shell tanpa backend. Gunakan profil **Serba Jaya (dev)** di VS Code untuk hasil yang sama. Menu Beranda dan Chat dapat dibuka sebagai tamu. Keranjang, Pesanan, Profil, dan Notifikasi memerlukan sesi aplikasi yang tervalidasi.

```bash
bash scripts/check.sh
```

[Kontribusi](CONTRIBUTING.md) · [Catatan perubahan](CHANGELOG.md) · [Panduan agen](AGENTS.md)
