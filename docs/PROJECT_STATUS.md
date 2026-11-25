# Status proyek — Multi-environment dan persiapan OAuth

## Pembaruan — Ikon Chat Bottom Navigation Bar (25 November 2026)

Logo tombol Chat kini memakai `assets/navigation/chat-branding-icon.png` dan dirender proporsional (`BoxFit.contain`) pada lingkaran merah yang selalu sama di seluruh state navbar. Cradle 70 px `#FCFBF8` di belakang tombol 56 px membentuk ring terang sesuai Figma; node tombol merah sendiri tidak mempunyai stroke. Ukuran, posisi, shadow, label, dan ring diverifikasi pada lima variant `232:5152` melalui screenshot Desktop Bridge dan pembacaan Plugin API lokal. Permintaan metadata file mengembalikan HTTP 429; tidak diulang.

| Pemeriksaan | Hasil |
|---|---|
| Aset | PASS — file tersedia dan folder `assets/navigation/` sudah terdaftar di `pubspec.yaml`. |
| `dart format` | PASS — file Dart navbar dan tes diformat. |
| `flutter test test/shared/navigation_test.dart --reporter expanded` | PASS — 5 tes; tes multi-state memeriksa logo, rasio, posisi, warna merah, shadow, cradle, label, dan overflow di kelima state. |
| `flutter analyze` | PASS — tidak ada issue. |
| Uji runtime / hot reload | PENDING — `flutter devices` saat validasi tidak mendeteksi perangkat fisik; hanya simulator iPhone, desktop, dan Chrome yang tercantum. Tidak menjalankan simulator. Sambungkan HP fisik untuk validasi runtime. |
| Figma | READ-ONLY — lima screenshot dan data geometri dari Desktop Bridge; tidak ada perubahan pada file Figma. |

Saat tes menemukan nama asset Orders tidak cocok (`orders-innactive.png` vs referensi `orders-inactive.png`), nama file dirapikan tanpa mengubah byte gambarnya; checksum sebelum/sesudah sama. Aset visual tab selain Chat tidak diubah. Rincian komponen ada di [Bottom Navigation Bar](components/BOTTOM_NAVIGATION_BAR.md).

## Pembaruan — Perbaikan kompatibilitas Gradle Android (25 November 2026)

Wrapper Android sebelumnya berubah di working tree dari Gradle `8.14-all` (versi yang tercatat di `HEAD`) menjadi `9.7.1-bin`. Versi 9.7.1 membuat AGP 8.11.1 gagal saat memasang plugin karena API internal `InternalProblems` telah dihapus di Gradle 9.6. Wrapper dipulihkan ke Gradle 8.14; tidak ada bukti bahwa Flutter melakukan upgrade otomatis. AGP, Kotlin, JDK setting, flavor, ID, OAuth, dan signing dipertahankan. Detail matriks versi dan cara mendiagnosis ada di [panduan build](development/RELEASE.md).

| Pemeriksaan | Hasil |
|---|---|
| `./gradlew --version` | PASS — Gradle 8.14, wrapper `8.14-all`. |
| `flutter analyze --suggestions` | PASS — Java, Gradle, KGP, dan AGP dinilai kompatibel. |
| `flutter run -d R9RX602H0LA --flavor dev --dart-define-from-file=config/dev.example.json` | PASS — `assembleDevDebug` berhasil (205,8 detik), APK terpasang, dan activity `id.serbajaya.ecommerce.dev` terkonfirmasi foreground di SM A057F. Perangkat fisik Android 15/API 35. |
| Storage | PASS — tersedia 4,3 GiB sebelum build dan 5,1 GiB pada pemeriksaan akhir; tidak menjalankan `flutter clean` atau emulator/simulator. |
| Java | Sesuai — `flutter doctor -v` memilih Android Studio JBR 17.0.11; shell/daemon build memakai Corretto 18.0.2. Gradle 8.14 mendukung Java 18 dan target bytecode tetap 17. |
| Flavor dan environment | PASS — perintah run memakai flavor `dev` dan `config/dev.example.json`; deklarasi `dev/staging/prod` serta konfigurasi tidak diubah. Build runtime hanya dilakukan untuk dev. |

## Pembaruan — Dialog autentikasi wajib (25 November 2026)

Root cause latar hitam adalah route `/login-required` terpisah di luar `ShellRoute`, yang melepas halaman aktif sebelum dialog transparan tampil. Aksi menu tamu kini memakai `showDialog` dengan barrier hitam 40% di atas halaman shell yang sama. Guard route tetap mengembalikan deep link tamu ke Beranda. Implementasi, bukti screenshot sebelum/sesudah dari SM A057F, dan batas verifikasi ada di [hasil verifikasi dialog autentikasi](verification/AUTH_REQUIRED_DIALOG.md).

| Pemeriksaan | Hasil |
|---|---|
| `flutter analyze` | PASS, tidak ada issue. |
| `flutter test --concurrency=1 --reporter expanded` | PASS, 41 tes unit/widget. |
| `flutter run` flavor dev pada SM A057F | PASS; halaman aktif dan navbar tetap tampak di belakang modal. Android Back, Close, dan Masuk diverifikasi manual. |
| Screenshot | [Sebelum](verification/screenshots/auth-dialog-before.png) menunjukkan latar hitam; [sesudah](verification/screenshots/auth-dialog-after.png) menunjukkan overlay semi-transparan pada halaman aktif. |
| Integration test di SM A057F | Belum lulus. Percobaan pertama gagal pada assertion judul dialog; percobaan ulang dengan jeda pemulihan sesi berhenti sebelum tes berjalan karena `:app:compressDevDebugAssets` kehabisan ruang disk. Alur manual di perangkat berhasil; penyebab assertion belum terisolasi. |

## Pembaruan — Implementasi Bottom Navigation Bar dan Header (25 November 2026)

Node Figma serta screenshot komponen yang diperlukan dibaca melalui Figma Console/Desktop Bridge. `MainShell`, navbar, Header mobile, Header judul, Header pencarian, badge, dan GoRouter terintegrasi. Ikon Cart dan Bell Header menggunakan vector hasil ekspor langsung dari child node Figma; Auth guard dan konfigurasi flavor tidak diubah.

| Pemeriksaan | Hasil | Bukti |
|---|---|---|
| Figma Console/Desktop Bridge | CONNECTED; baca file/node berhasil | Local Plugin API dan screenshot berhasil. Tidak memakai Figma REST/MCP resmi. Lihat [hasil Figma](integrations/FIGMA.md). |
| Figma rate limit / ekspor | SEBAGIAN TERBATAS | Endpoint component-development sebelumnya memberi 429 dan tidak diulang. Ekspor root component gagal, tetapi inspeksi lokal `getNodeByIdAsync` lalu ekspor child vector Cart/Bell berhasil. Logo serta beberapa ikon tetap memakai crop screenshot. |
| Navbar | IMPLEMENTED DARI NILAI TERUKUR | Geometri, shadow, 5 state ikon/label, Chat berlogo, badge runtime, dan SafeArea. PNG ikon/logo adalah crop screenshot Figma Bridge; widget dan interaksi tetap native Flutter. |
| Header | IMPLEMENTED DENGAN BATAS VARIAN | Home memakai Header Mobile cart/notifikasi. Header judul dinamis dipakai rute yang ada. Search field reusable; belum dipasang ke rute karena layar pencarian/katalog belum ada. Pemetaan placeholder berstatus sementara. |
| `dart format` | PASS | Seluruh file Dart yang berubah diformat. |
| `flutter analyze` | PASS | Tidak ada issue. |
| `flutter test --concurrency=1 --reporter expanded` | PASS | 49 tes lulus termasuk navbar, Header, badge, pencarian, dialog auth, dan protected route. |
| `flutter run` Android SM A057F | PASS FISIK | `flutter devices` mendeteksi SM A057F (Android 15/API 35). Build pertama sekitar 480 detik; build incremental setelah ikon Cart/Bell diganti vector Figma sekitar 193 detik. APK flavor `dev` berhasil dipasang. Wrapper lokal `9.7.1` diganti sementara ke Gradle `8.14` yang sudah tercache lalu dipulihkan persis setelah tiap sesi. |
| Auth guard dan Android Back | PASS FISIK | Pada sesi fisik, ketuk Keranjang sebagai tamu menampilkan dialog autentikasi di atas halaman shell yang sama; Header dan Navbar terlihat di belakang overlay. Satu kali Back menutup dialog dan halaman Notifikasi tetap terlihat. Pengujian Back dilakukan sebelum penggantian ikon raster; perubahan sesudahnya hanya pada aset/render ikon Header. |
| `flutter run` iOS Simulator | TIDAK DIJALANKAN | Sesuai aturan pengujian fisik di [AGENTS.md](../AGENTS.md), simulator tidak digunakan untuk task ini. Screenshot simulator lama di bawah ini hanya arsip historis dan bukan bukti verifikasi task ini. |
| Screenshot sebelum / sesudah | TERSIMPAN | [Sebelum](verification/screenshots/navbar-header-before.png), [dialog di atas shell dengan vector Header final](verification/screenshots/navbar-header-auth-dialog-after.png), dan [halaman setelah Back](verification/screenshots/navbar-header-back-after.png). Semuanya 1080 × 2400 dari SM A057F; screenshot Back diambil sebelum penggantian ikon. |
| Reproduksi dengan wrapper tersimpan | TERATASI 25 NOV 2026 | Pemeriksaan terdahulu terblokir karena working tree memakai Gradle `9.7.1`. Wrapper kini dipulihkan permanen ke versi tracked `8.14-all`; build dan peluncuran aktual pada perangkat fisik berhasil. Lihat [pembaruan perbaikan Gradle](#pembaruan--perbaikan-kompatibilitas-gradle-android-25-november-2026) dan [panduan build](development/RELEASE.md). |

Lihat [Bottom Navigation Bar](components/BOTTOM_NAVIGATION_BAR.md), [Header](components/HEADER.md), [hasil pemeriksaan Figma](integrations/FIGMA.md), dan [laporan verifikasi fisik](verification/NAVBAR_HEADER_UI.md). Tidak ada fitur bisnis atau desain Figma yang ditambahkan. Implementasi belum disebut pixel-perfect; crop logo dan beberapa ikon masih raster, pemetaan Header judul bersifat sementara, serta Header pencarian belum dipasang ke layar.

Riwayat verifikasi environment 25 November 2026, sebelum implementasi navigasi. Flavor native, scheme, ID aplikasi, fingerprint signing debug, serta konfigurasi OAuth diperiksa ulang pada workspace yang dipulihkan. Baris build di bagian ini mencerminkan kondisi saat audit tersebut; hasil terbaru setelah build dan smoke test navigasi tercantum di pembaruan paling atas.

| Pemeriksaan | Hasil | Bukti |
|---|---|---|
| Android flavors dan identitas | PASS | `devDebug`, `stagingDebug`, `prodDebug` memakai application ID serta label yang disetujui. ID/label sembilan varian diverifikasi melalui Gradle. |
| iOS schemes dan build settings | PASS | Shared scheme `dev`, `staging`, `prod`. Sembilan konfigurasi simulator serta tiga konfigurasi device Release menunjukkan Bundle ID, display name, dan minimum iOS 13.0 sesuai. |
| CocoaPods dan sintaks native | PASS | Podfile mengenali sembilan konfigurasi. Plist, proyek Xcode, ketiga scheme, Podfile, JSON environment, dan VS Code launch JSON valid. |
| Debug signing Android | PASS | `./gradlew signingReport` serta `keytool` menunjukkan SHA-1/SHA-256, alias `AndroidDebugKey`, RSA 2048-bit, `SHA256withRSA`, dan masa berlaku sampai 14 Februari 2055. Tiga flavor memakai satu debug keystore lokal. |
| Release signing Android | NOT CONFIGURED | `devRelease`, `stagingRelease`, dan `prodRelease` tidak memiliki signing config, keystore, alias, atau fingerprint. |
| Signing iOS | NOT CONFIGURED | Xcode tidak memiliki Team ID atau provisioning profile. |
| Google Play App Signing | NOT VERIFIED | Informasi Play Console belum tersedia. |
| Data pendaftaran GCP | PASS | Tabel Android, iOS, dan Web per environment tersedia. Fingerprint production release belum tersedia. Tidak ada resource GCP atau client ID yang dibuat. |
| `flutter pub get` | PASS | Berhasil pada Flutter 3.41.9 dan Dart 3.11.5. Versi dependensi tidak dinaikkan oleh pekerjaan ini. |
| Dart format | PASS | `dart format --output=none --set-exit-if-changed .` memeriksa 40 file, nol perubahan. |
| `flutter analyze` | PASS | Tidak ada masalah. |
| Unit dan widget test | PASS | 34 tes lulus dengan `flutter test --concurrency=1 --reporter expanded`, termasuk environment, sesi, akses tamu, dan autentikasi. |
| Build APK Android dev | BLOCKED | Tidak dijalankan. Ruang tersisa 495 MiB setelah tes dan laporan signing, belum memadai mengingat build sebelumnya gagal karena disk penuh. |
| Build iOS simulator dev | BLOCKED | Tidak dijalankan karena ruang disk yang sama. |
| Google/Apple Sign-In, GCP, Figma | DEFERRED | Tidak ada integrasi provider atau perubahan eksternal pada lingkup pekerjaan ini. |

ID aplikasi yang disetujui dan display name tercantum pada [konfigurasi environment](development/ENVIRONMENT.md). Tabel registrasi OAuth dengan fingerprint aktual ada di [GCP OAuth](integrations/GCP_OAUTH_REGISTRATION.md).

Gradle wrapper 8.14 berjalan dengan Android Gradle Plugin 8.11.1 dan Kotlin Gradle Plugin 2.2.20. Android mendokumentasikan minimum Gradle 8.13 untuk AGP 8.11. Kotlin 2.2.20 mendukung penuh Gradle sampai 8.14 dan AGP sampai 8.11.1. Gradle 9.7.1 sebelumnya berada di luar rentang dukungan Kotlin tersebut dan resolusi plugin offline gagal. `signingReport` dengan 8.14 berhasil. Proses Gradle memakai Corretto 18.0.2 dan target bytecode proyek tetap Java/Kotlin 17. Ada peringatan deprecasi `jvmTarget` pada skrip app dan deprecations dari plugin Gradle, tanpa kegagalan task. [Matriks Kotlin Gradle](https://kotlinlang.org/docs/gradle-configure-project.html) · [Kompatibilitas AGP 8.11](https://developer.android.com/build/releases/agp-8-11-0-release-notes)

## Riwayat UI Autentikasi

Perubahan 24 November 2026 mencakup Onboarding untuk pemeriksaan sesi, Alert Login, Login Akun, dan dua keadaan Daftar Akun yang memakai satu formulir. Shell publik serta aturan validasi sesi tetap tersedia. Daftar hanya memvalidasi input lokal. Callback Google/Apple, konfigurasi provider, pertukaran token, dan pendaftaran backend berstatus **DEFERRED**. [Pemetaan Figma dan batas integrasi](features/AUTHENTICATION_UI.md)

| Pemeriksaan | Hasil | Bukti |
|---|---|---|
| Figma `232:5150` | PASS | Metadata, konteks, screenshot, dan aset lima frame diperiksa dalam mode baca saja. |
| Resolusi lockfile, gen-l10n, format dan analisis | PASS | `flutter pub get --enforce-lockfile`, Dart format, dan `flutter analyze --no-pub` berhasil. |
| Unit dan widget | PASS | 32 tes lulus. Termasuk jalur Alert → Login → Daftar, status provider, tujuan terlindungi, validasi lokal, dan layout 320 × 568 dengan text scale 1,4. |
| Perbandingan visual Flutter | PASS | Render widget Onboarding, Login, Alert, dan Daftar diperiksa pada viewport rujukan. Data foto dan email adalah dinamis. Pemeriksaan ini menggunakan Flutter tester. |
| Instalasi pod dan validasi plist | PASS | `pod install --no-repo-update` memasang `image_picker_ios`. CocoaPods memberi peringatan konfigurasi Profile kustom. `Info.plist` valid. |
| Build Android, build iOS, dan smoke test perangkat | NOT RUN | Ruang disk sekitar 285 MiB setelah verifikasi. Build dan smoke test Phase 1 di bawah mendahului perubahan ini. Galeri native belum diverifikasi pada perangkat. |

## Riwayat Phase 2

Audit 24 November 2026 (Asia/Jakarta) dari direktori proyek final. Fondasi siap menjadi baseline pengembangan. Perbaikan menangani logout saat provider dibangun ulang dan pemetaan status ketika body HTTP error tidak valid. Versi dependensi dan konfigurasi native dipertahankan. [Audit fondasi](development/FOUNDATION_REVIEW.md) memuat bukti, tingkat keparahan, dan cakupan tes.

### Verifikasi Phase 2

| Pemeriksaan | Hasil | Bukti |
|---|---|---|
| SDK dan toolchain | PASS | Flutter Stable 3.41.9, Dart 3.11.5, Android SDK 36/JDK 17, Xcode 26.3, CocoaPods 1.16.2 terdeteksi. `flutter doctor -v` melaporkan lisensi Android yang belum diterima. |
| `flutter pub get` dan format Dart | PASS | Lockfile identik dengan Phase 1. Format dan pemeriksaan format mencakup 30 file. |
| `flutter analyze` | PASS | Tidak ada masalah. |
| `flutter test --concurrency=1 --reporter expanded` | PASS | 29 tes unit/widget, termasuk enam regresi baru. Eksekusi paralel dihentikan saat runner tertahan dan hasil parsialnya tidak dihitung. |
| Pemeriksaan konfigurasi native | PASS | Plist, proyek Xcode, Podfile, dan tiga manifest Android lolos pemeriksaan sintaks. |
| Build Android multi ABI | BLOCKED | Ruang sekitar 206–309 MiB saat penutupan audit, setelah kegagalan karena disk penuh pada Phase 1. |
| Build Android x86_64, build iOS, dan tes perangkat | NOT RUN | Verifikasi biner dan smoke test Phase 1 dicatat di bawah. Build ulang tidak dilakukan dengan ruang disk ini. |
| Figma / UI final | DEFERRED | Temuan baca saja Phase 1 dipakai untuk [rencana Design System](architecture/DESIGN_SYSTEM_PLAN.md). |

### Baseline dan keputusan terbuka

Kandidat commit awal memuat kode, platform native, konfigurasi contoh, lockfile, workflow, tes, dan dokumentasi proyek. Master prompt dan PDF asli tetap di folder kerja dan terpisah dari kandidat. Baseline telah disetujui dan disimpan dalam commit lokal `64f0ef2` di `main`.

Design System dapat dimulai setelah persetujuan Phase 3 serta persetujuan rujukan desain, token, dan aset. Build Android multi ABI, signing resmi, uji secure storage pada perangkat fisik, dan kontrak autentikasi backend masih terbuka untuk kesiapan rilis. [Pertanyaan bisnis](requirements/OPEN_QUESTIONS.md) mencakup pembatalan/refund, pengiriman, pembayaran, reward, komisi, dan integrasi GF.

## Riwayat Phase 1

Pemeriksaan akhir 24 November 2026 (Asia/Jakarta) di `/Users/kahfizain/Documents/KAHFI/PROJEK/serba_jaya_mobile/`. Flutter Stable 3.41.9 dan Dart 3.11.5. Catatan build dan runtime simulator pada riwayat Phase 1 merekam hasil saat itu, sebelum aturan permanen pengujian fisik diberlakukan; jangan ulangi pengujian dengan simulator.

### Implementasi dan pemulihan

- Perbandingan checksum dengan direktori sementara mengonfirmasi penyalinan sumber, konfigurasi, tes, dan dokumentasi sudah lengkap. Master prompt, PDF sumber, serta berkas pengguna dipertahankan.
- Android dan iOS memakai satu aplikasi Flutter dengan Feature-first Clean Architecture dan MVVM pragmatis. Bootstrap mengatur dev/staging/prod dan lokalisasi Bahasa Indonesia. Shell dev dan tema netral mendukung verifikasi navigasi.
- Riverpod mengelola state dan dependensi. GoRouter menunggu pemeriksaan sesi untuk rute yang dilindungi. Dio mengirim token aplikasi hanya pada operasi bertanda dan tujuan HTTPS dalam origin serta path backend yang dikonfigurasi. Redirect otomatis dimatikan. Log debug memuat jenis kesalahan atau status HTTP.
- Sesi lokal disimpan melalui secure storage dan diperiksa untuk kedaluwarsa. Token lokal memerlukan validasi sesi. Validator bawaan Phase 1 menolak sesi karena kontrak backend belum tersedia. Logout mencabut akses segera dan mencoba menghapus sesi lokal.
- Pada akhir Phase 1, Git lokal telah diinisialisasi pada cabang `main` tanpa commit atau remote. `.gitignore` mengecualikan hasil build, konfigurasi lokal, dan material sensitif.

### Verifikasi

| Pemeriksaan | Hasil | Lokasi dan bukti |
|---|---|---|
| `flutter pub get` dan lockfile | PASS | Proyek final. Resolusi berhasil, termasuk pemeriksaan CI lokal dengan lockfile. |
| Format Dart | PASS | Proyek final. 30 file diperiksa, tanpa perubahan. |
| `flutter analyze` | PASS | Proyek final. Tidak ada masalah. |
| `flutter test` | PASS | Proyek final. 23 tes unit/widget lulus. |
| APK Android debug multi ABI | BLOCKED | Dua percobaan sebelumnya di direktori sementara gagal dengan `No space left on device`. Tidak diulang di proyek final. Setelah pembersihan keluaran sementara, ruang hanya sekitar 1,9 GiB sebelum build iOS. Pengukuran setelah tes iOS menunjukkan sekitar 553 MiB. Gradle membutuhkan ruang untuk mengekstrak, menyalin, dan mengemas library bagi setiap ABI. |
| APK Android debug x86_64 | PASS | Hasil sebelumnya di direktori sementara memakai `--target-platform android-x64`. Flutter engine x86_64, package ID sementara, minSdk 24 dan target SDK 36 dikonfirmasi pada APK 72 MiB. |
| `flutter build ios --simulator` (konfigurasi dev) | PASS | Proyek final menghasilkan `Runner.app`. Bundle ID sementara dan minimum iOS 13.0 diverifikasi pada artefak. Build sebelumnya juga lulus di direktori sementara. |
| Startup dan guard di iPhone 16e (iOS 26.3) | PASS | Satu tes integrasi lulus dari proyek final. Aplikasi mulai sebagai tamu, lalu membuka login gate untuk Keranjang. Tes sebelumnya juga lulus di direktori sementara. |
| Smoke test Android dan workflow GitHub Actions | NOT RUN | Verifikasi runtime dipusatkan pada iOS. Skrip pemeriksaan CI dijalankan lokal. |
| Figma MCP | PASS | Koneksi, autentikasi, izin file, node, screenshot, dua token, lima komponen, dan sampel aset terverifikasi dalam cakupan baca saja. Lihat [hasil inspeksi](integrations/FIGMA.md). |

`flutter doctor -v` mendeteksi Android SDK 36, JDK 17, Xcode 26.3, dan CocoaPods 1.16.2. Beberapa lisensi SDK Android belum diterima. iPad fisik tidak dapat dihubungi melalui jaringan lokal. iPhone 16e simulator tersedia.

### Pekerjaan tersisa setelah Phase 1

- **DEFERRED** Implementasi UI final, Google Sign-In dengan GCP OAuth 2.0/OpenID Connect, Sign in with Apple, serta integrasi dan refresh sesi backend. Rancangan tersedia di [Authentication](integrations/AUTHENTICATION.md) dan [GCP OAuth](integrations/GCP_OAUTH.md).
- Base URL resmi, ID aplikasi resmi, signing rilis, konfigurasi provider, dan kontrak token/otorisasi backend belum disediakan.
- [Pertanyaan bisnis](requirements/OPEN_QUESTIONS.md) mencakup pembatalan/refund, pengiriman, pembayaran, reward, komisi dan GF. Konfirmasi desain final dan kontrak API sebelum mengerjakan katalog tamu. Mulai fase berikutnya setelah persetujuan.
