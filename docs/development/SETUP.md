# Setup pengembangan

1. Buka root `serba_jaya_mobile` di VS Code. Pasang ekstensi Dart dan Flutter dari rekomendasi workspace.
2. Gunakan Flutter Stable **3.41.9**, Dart **3.11.5** bawaan. Periksa `flutter --version`, `dart --version`, dan `flutter doctor -v`.
3. Android membutuhkan Android SDK 36, NDK 28.2.13676358, dan JDK 17 atau lebih baru yang didukung Flutter/Android Gradle Plugin. Pemeriksaan `signingReport` selesai pada JDK Corretto 18.0.2 dengan target bytecode Java/Kotlin 17. Gunakan perangkat Android fisik melalui USB/wireless debugging; aturan pengujian melarang emulator. Tinjau lisensi SDK jika diminta.
4. iOS membutuhkan macOS, Xcode, dan CocoaPods untuk tooling plugin. Toolchain yang diperiksa: macOS 15.7.2, Xcode 26.3, dan CocoaPods 1.16.2. Runtime hanya memakai perangkat iOS fisik; jangan menyiapkan atau menjalankan simulator untuk pengujian. Pilih perangkat fisik dari `flutter devices`.
5. Jalankan `flutter pub get`. Tooling Flutter menghasilkan kode lokalisasi. Jalankan `flutter gen-l10n` setelah mengubah ARB jika IDE belum memperbaruinya.
6. Dari VS Code pilih **Serba Jaya — Development**, **Serba Jaya — Staging**, atau **Serba Jaya — Production**. Di terminal jalankan salah satu perintah pada [panduan environment](ENVIRONMENT.md).

## Dependensi langsung

| Dependensi | Resolusi | Penggunaan |
|---|---|---|
| flutter | SDK | Widget, Material, lifecycle |
| flutter_localizations | SDK | Delegate lokalisasi Material dan Flutter |
| flutter_riverpod | 3.3.2 | State dan dependency injection |
| go_router | 17.5.0 | Routing dan guard sesi |
| dio | 5.11.1 | HTTP, JSON, multipart, cancellation dan interceptor |
| flutter_secure_storage | 9.2.4 | Penyimpanan token aplikasi |
| shared_preferences | 2.5.6 | Provider preferensi lokal non-sensitif |
| intl | 0.20.2 | Runtime gen-l10n dan format tanggal lahir |
| flutter_svg | 2.3.4 | Rendering aset SVG asli dari Figma |
| image_picker | 1.2.4 | Pilih foto profil opsional dari galeri sistem |
| flutter_lints | 6.0.0 | Aturan analisis |
| flutter_test, integration_test | SDK | Tes unit/widget dan smoke test perangkat |

Git lokal memakai cabang `main`. Sertakan `pubspec.lock` saat membuat commit pertama. Dokumen kerja lokal di `doc-projek/` dikecualikan dari Git. Lihat [lingkungan](ENVIRONMENT.md) untuk flavor dan [release](RELEASE.md) untuk build.

Pertimbangkan `freezed`, `json_serializable`, dan `build_runner` ketika kebutuhan model/DTO membenarkannya. SDK `google_sign_in` dan `sign_in_with_apple` menunggu persetujuan integrasi. SDK push, peta/lokasi, dan pemilihan file ditentukan per fitur.
