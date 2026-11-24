# Status proyek — Phase 2

Audit 24 November 2026 (Asia/Jakarta) dari direktori proyek final. Fondasi siap menjadi baseline pengembangan. Perbaikan menangani logout saat provider dibangun ulang dan pemetaan status ketika body HTTP error tidak valid. Versi dependensi dan konfigurasi native dipertahankan. [Audit fondasi](development/FOUNDATION_REVIEW.md) memuat bukti, tingkat keparahan, dan cakupan tes.

## Verifikasi Phase 2

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

## Baseline dan keputusan terbuka

Kandidat commit awal memuat kode, platform native, konfigurasi contoh, lockfile, workflow, tes, dan dokumentasi proyek. Master prompt dan PDF asli tetap di folder kerja dan terpisah dari kandidat. Cabang lokal `main` menunggu persetujuan commit awal, tanpa remote.

Design System dapat dimulai setelah persetujuan Phase 3 serta persetujuan rujukan desain, token, dan aset. Build Android multi ABI, signing resmi, uji secure storage pada perangkat fisik, dan kontrak autentikasi backend masih terbuka untuk kesiapan rilis. [Pertanyaan bisnis](requirements/OPEN_QUESTIONS.md) mencakup pembatalan/refund, pengiriman, pembayaran, reward, komisi, dan integrasi GF.

## Riwayat Phase 1

Pemeriksaan akhir 24 November 2026 (Asia/Jakarta) di `/Users/kahfizain/Documents/KAHFI/PROJEK/serba_jaya_mobile/`. Flutter Stable 3.41.9 dan Dart 3.11.5.

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
