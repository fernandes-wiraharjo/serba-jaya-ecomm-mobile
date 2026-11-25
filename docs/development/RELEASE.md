# Build Android dan iOS

```bash
flutter build apk --debug --flavor dev --dart-define-from-file=config/dev.example.json
flutter build ios --no-codesign --flavor dev --dart-define-from-file=config/dev.example.json
```

| Platform | Konfigurasi |
|---|---|
| Android | ID resmi tiap flavor tercantum di [environment](ENVIRONMENT.md). Namespace dasar `id.serbajaya.ecommerce`. Wrapper Gradle 8.14, AGP 8.11.1, Kotlin plugin 2.2.20, target Java/Kotlin 17, minSdk 24 dan compile/target SDK 36 dari Flutter. Manifest memakai nama flavor dan menonaktifkan backup aplikasi. Ketiga varian debug memakai debug keystore lokal. Signing release **NOT CONFIGURED**. SHA-1/SHA-256 dan masa berlaku sertifikat debug terdapat di [data OAuth](../integrations/GCP_OAUTH_REGISTRATION.md). |
| iOS | Scheme `dev`, `staging`, `prod` memakai sembilan konfigurasi `Debug`, `Profile`, dan `Release`. Bundle ID dan display name telah diverifikasi. Target minimum iOS 13.0. CocoaPods mempunyai konfigurasi untuk semua environment. Team ID dan provisioning profile **NOT CONFIGURED**. |

## Kompatibilitas Android dan insiden wrapper (25 November 2026)

Versi Gradle proyek ditentukan oleh `android/gradle/wrapper/gradle-wrapper.properties`, bukan versi Gradle bawaan Flutter. Sebelum perbaikan, working tree menunjuk ke Gradle `9.7.1-bin`; `HEAD` Git yang diperiksa menunjuk ke `8.14-all`. Bukti yang tersedia menunjukkan perubahan lokal pada properti wrapper, bukan upgrade otomatis oleh Flutter. Tidak ada informasi yang dapat memastikan siapa atau alat apa yang mengubahnya. Wrapper kini kembali ke `8.14-all` yang terlacak Git agar run berikutnya tetap memakai versi kompatibel.

Gradle 9.7.1 gagal saat memasang AGP 8.11.1 karena plugin meminta API internal `InternalProblems` yang sudah dihapus mulai Gradle 9.6. Gradle 8.14 adalah batas tertinggi yang didukung penuh oleh Kotlin Gradle Plugin 2.2.20, sedangkan AGP 8.11.1 menetapkan Gradle minimal 8.13 dan JDK minimal 17. Karena itu, `8.14 / AGP 8.11.1 / KGP 2.2.20` adalah irisan kompatibilitas yang sudah tersedia di cache dan menghindari migrasi AGP/Kotlin yang tidak perlu. [Kotlin Gradle compatibility](https://kotlinlang.org/docs/gradle-configure-project.html) · [AGP 8.11 compatibility](https://developer.android.com/build/releases/agp-8-11-0-release-notes) · [Gradle Java compatibility](https://docs.gradle.org/current/userguide/compatibility.html)

Pemeriksaan 25 November: Flutter Stable 3.41.9 / Dart 3.11.5; Flutter Doctor memilih JBR Android Studio 17.0.11, sedangkan `java -version` pada shell dan daemon build yang diamati menunjukkan Corretto 18.0.2. Gradle 8.14 mendukung menjalankan Gradle dengan Java 18; bytecode proyek tetap Java/Kotlin 17. `flutter analyze --suggestions` menyatakan kombinasi Java, Gradle, KGP, dan AGP kompatibel. Perintah `flutter run -d R9RX602H0LA --flavor dev --dart-define-from-file=config/dev.example.json` berhasil mengeksekusi `assembleDevDebug`, memasang APK, dan meluncurkan aplikasi pada Samsung SM A057F. Tidak ada perubahan pada AGP, Kotlin, JDK setting, flavor, ID aplikasi, OAuth, atau signing.

Untuk diagnosis berikutnya, periksa `distributionUrl` dan `./gradlew --version`; jika Gradle berubah, pastikan perubahan wrapper memang disengaja dan versi masih cocok dengan matriks Kotlin serta minimum AGP. Jangan mengandalkan versi Gradle dari proses Android Studio lain sebagai sumber versi wrapper proyek.

Sebelum rilis, buat dan simpan signing key resmi di luar repositori, atur Play App Signing, serta verifikasi sertifikat distribusi pada Play Console. Fingerprint debug saat ini hanya siap untuk pengujian lokal. Fingerprint produksi release belum tersedia. Tambahkan Android OAuth client dengan SHA-1 sertifikat yang benar, dan iOS OAuth client berdasarkan Bundle ID setelah registrasi GCP disetujui. Google Play dapat menandatangani artefak distribusi memakai app signing key yang berbeda dari upload key, sehingga fingerprint distribusi harus diambil dari Play Console. [Google Play App Signing](https://support.google.com/googleplay/android-developer/answer/9842756?hl=en)

Jangan buat Apple Developer certificate atau provisioning profile sebelum akun, Team ID, dan kebijakan signing tersedia. CI tidak mendistribusikan build.

Verifikasi runtime dan tampilan hanya boleh memakai perangkat Android/iOS fisik sesuai [aturan pengujian](../../AGENTS.md). Jangan meluncurkan emulator atau simulator.
