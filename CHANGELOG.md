# Catatan perubahan

## Belum dirilis — Fondasi navigasi dan Header

- Tambahkan `MainShell`, `AppBottomNavBar`, `BottomNavItem`, badge, dan boundary `AppHeader`; sambungkan lima tab ke GoRouter tanpa mengubah guard autentikasi.
- Gunakan token navigasi yang tercatat dari inspeksi Figma sebelumnya. Ikon Material dan treatment badge diberi status provisional karena aset/screenshot navigasi tidak tersedia lokal.
- Catat pembatasan Starter MCP, kebutuhan ekspor desain, dan batas verifikasi visual pada dokumentasi komponen.

## Belum dirilis — Multi-environment dan persiapan OAuth

- Tambahkan Android flavors, iOS schemes, sembilan konfigurasi build, dan tiga profil VS Code untuk environment yang disetujui.
- Validasi kecocokan native flavor, `APP_ENV`, dan nama aplikasi saat bootstrap.
- Catat fingerprint debug lokal dan status release signing untuk persiapan registrasi GCP OAuth. Belum membuat resource atau client ID GCP.
- Pin Gradle wrapper ke 8.14 agar berada dalam rentang dukungan penuh Kotlin Gradle Plugin 2.2.20 dan Android Gradle Plugin 8.11.1.

## Belum dirilis — UI Autentikasi

- Tambahkan layar pemeriksaan sesi, modal login, halaman login, dan formulir Daftar dari Figma.
- Tambahkan aset lokal, Roboto, validasi dan preview foto; pertahankan guard sampai backend dan provider tersedia.

## Phase 2

- Cegah restoration mengaktifkan kembali sesi ketika logout beririsan dengan pembangunan ulang provider.
- Pertahankan status HTTP error saat body tidak dapat didekode.
- Tambahkan tes regresi, audit fondasi, dan rencana Design System. Siapkan kandidat baseline Git.

## 0.1.0+1 — Phase 1

- Scaffold Flutter Android dan iOS dengan shell navigasi pengembangan dan tema netral.
- Konfigurasi dev/staging/prod, Dio, error mapping, penyimpanan, guard, serta fondasi sesi aplikasi.
- Lokalisasi Indonesia, tes unit/widget, skenario smoke untuk perangkat, CI, dan dokumentasi handover.

- Konfirmasi penyalinan sumber ke direktori proyek, inisialisasi Git lokal, dan verifikasi baca saja pada komponen navigasi Figma.
