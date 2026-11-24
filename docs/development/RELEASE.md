# Build Android dan iOS

```bash
flutter build apk --debug --dart-define-from-file=config/dev.example.json
flutter build ios --simulator --dart-define-from-file=config/dev.example.json
```

| Platform | Konfigurasi Phase 1 |
|---|---|
| Android | ID dan namespace sementara `id.serbajaya.dev.serba_jaya_mobile`, Kotlin, Gradle 8.14, AGP 8.11.1, Kotlin plugin 2.2.20, Java 17, minSdk 24 dan compile/target SDK 36 melalui default Flutter. Manifest utama hanya menambah izin internet dan menonaktifkan backup aplikasi untuk melindungi penyimpanan sesi. APK debug menggunakan signing debug bawaan. Release signing belum dikonfigurasi. |
| iOS | Bundle ID sementara `id.serbajaya.dev.serbaJayaMobile`, Swift, target minimum iOS 13.0, Info.plist tanpa deskripsi izin tambahan, template scene Flutter. Xcode team tidak dipasang di proyek. Build simulator tidak perlu provisioning profil perangkat. |

Sebelum rilis, konfirmasi ID resmi dan proses signing Play Console/App Store. Tambahkan Android OAuth client sesuai SHA-1 sertifikat, iOS OAuth URL scheme, konfigurasi Apple dan capability resmi setelah persetujuan. Untuk fitur lokasi, push, dan upload, pilih SDK/permission minimum, siapkan APNs dan deklarasi privasi sesuai fitur. Untuk dokumen/foto gunakan system picker apabila sesuai. Kunci signing dikelola di luar repositori. CI Phase 1 tidak mendistribusikan build.

Untuk pemeriksaan debug khusus emulator Android x86_64, gunakan perintah berikut. Verifikasi distribusi Android tetap memerlukan build dengan seluruh target ABI yang akan didukung.

```bash
flutter build apk --debug --target-platform android-x64 --dart-define-from-file=config/dev.example.json
```
