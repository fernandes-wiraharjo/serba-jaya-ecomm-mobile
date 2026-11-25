# Verifikasi Bottom Navigation Bar dan Header

Pemeriksaan 25 November 2026. Seluruh runtime screenshot task ini berasal dari perangkat Android fisik SM A057F (Android 15/API 35). Tidak ada emulator atau simulator yang dijalankan.

## Figma Console/Desktop Bridge

- `figma_get_status` dengan probe aktif berhasil; WebSocket Bridge sehat dan file aktif sesuai `Serba Jaya Ecommerce App` (`gMs1cpj2AGfubJP8slp0yM`). Hasil desain dibaca secara lokal dan read-only.
- Section navbar `232:5152` dan komponen Header `474:4779` tersedia pada Page 1. Pada node Header, Plugin API memberi posisi Cart vector `474:4792` (20 × 18 px, `(304,19)`) dan Bell vector `474:4787` (14 × 18.25 px, `(345,19)`); badge contoh masing-masing 14 × 14 px.
- SVG Cart dan Bell diekspor langsung dari child vector tersebut ke `assets/header/cart.svg` dan `assets/header/notification.svg`. Ekspor root component sebelumnya gagal karena node itu tidak memiliki visible layers. Endpoint component-development pernah memberi HTTP 429 dan tidak diulang.
- Tidak ada variabel library yang diklaim. Nilai warna, geometri, dan typography diambil dari node visual/style serta screenshot. Tidak ada elemen Figma yang diubah.

## Implementasi

- `MainShell`, `AppBottomNavBar`, `BottomNavItem`, dan `NavigationBadge` memakai GoRouter sebagai sumber state pilihan, dengan lima tujuan Beranda, Keranjang, Chat, Pesanan, dan Profil.
- `AppHeader` menjadi boundary reusable. Variannya meliputi logo + Search/Menu, logo + Cart/Notifikasi, judul halaman, dan field pencarian. Pencarian tetap reusable dan belum dipasang karena belum ada layar katalog/pencarian.
- Badge tidak menampilkan angka contoh Figma saat jumlah runtime nol. Ikon Cart dan Bell memakai vector child Figma yang bersih. Logo dan beberapa ikon lain masih crop raster dari screenshot Bridge.
- Aksi protected memakai auth guard/dialog yang sudah ada; perubahan tidak membuka akses guest dan tidak menambah dependency.

## Hasil perangkat fisik

`flutter devices` menampilkan empat target, tetapi hanya satu perangkat mobile fisik: SM A057F (`R9RX602H0LA`). iPhone 16e yang tampil adalah simulator dan diabaikan. Flutter juga melaporkan perangkat iPad wireless tidak tersedia (error browsing jaringan `-27`); kondisi itu tidak menghalangi penggunaan SM A057F.

| Pemeriksaan | Hasil |
|---|---|
| Build dan instalasi | PASS. `flutter run -d R9RX602H0LA --no-pub --flavor dev --dart-define-from-file=config/dev.example.json` berhasil dua kali. Build awal sekitar 480 detik; build incremental setelah vector Header sekitar 193 detik. |
| Ketuk Keranjang oleh guest | PASS. Dialog autentikasi muncul di atas halaman shell yang sama; Header dan Navbar terlihat di belakang dimming overlay pada screenshot final. |
| Android Back | PASS pada sesi sebelum penggantian aset ikon. Satu kali Back menutup dialog dan halaman Notifikasi tetap terlihat; source auth guard/dialog tidak berubah pada perbaikan ikon. |
| Perbandingan visual | Dilihat dari Figma node screenshots dan screenshot SM A057F. Geometri utama, warna, tipografi, dan state navbar sudah diukur; hasil belum diklaim pixel-perfect. |
| Simulator | Tidak digunakan untuk task ini. Screenshot iOS simulator terdahulu (`navbar-header-ios-after.png`) adalah arsip dari sebelum aturan fisik-only dan bukan bukti task ini. |

Screenshot 1080 × 2400:

- [Sebelum perubahan](screenshots/navbar-header-before.png)
- [Sesudah, dialog guest dengan ikon vector Figma berada di atas shell](screenshots/navbar-header-auth-dialog-after.png)
- [Sesudah Android Back menutup dialog sebelum penggantian aset ikon](screenshots/navbar-header-back-after.png)

## Toolchain dan batas yang tersisa

Ruang kosong sebelum build awal sekitar 9.4 GiB. Build memakai cache yang tersedia dan tidak menjalankan `flutter clean`; pengukuran setelah sesi berikutnya menunjukkan sekitar 6.2 GiB tersedia. Wrapper yang tersimpan pada workspace adalah Gradle `9.7.1`, sedangkan AGP `8.11.1` proyek mengandalkan API Gradle yang tidak tersedia pada wrapper itu. Agar tes fisik dapat berlangsung, file wrapper diganti sementara ke Gradle `8.14` yang sudah tersedia lokal, lalu dipulihkan persis setelah sesi. Karena itu runtime PASS berlaku untuk build sementara tersebut; run berikutnya dengan wrapper workspace saat ini masih memerlukan keputusan toolchain.

Hot reload pada sesi lama tidak menyertakan asset SVG yang baru ditambahkan; hot restart pada sesi `attach` menampilkan error konfigurasi environment, sehingga sesi tersebut ditutup. Run baru memakai flavor dan file define eksplisit berhasil, memuat Cart/Bell SVG bersih dari Figma, dan screenshot fisik final berhasil ditangkap. ADB kemudian kehilangan SM A057F sebelum pengambilan screenshot tanpa dialog dapat diulang setelah perubahan ikon. Pemeriksaan akhir `flutter devices` tidak lagi menampilkan perangkat fisik; simulator tidak dipakai sebagai pengganti. Logo dan ikon raster lain dapat terlihat kurang tajam pada density tinggi; ekspor aset asli beresolusi tinggi masih dibutuhkan untuk menggantinya.
