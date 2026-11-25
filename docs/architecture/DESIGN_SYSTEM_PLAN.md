# Rencana Design System — Phase 3

Status Design System lengkap tetap **DEFERRED** sampai ada persetujuan Phase 3 dan rujukan desain final. Sebagai pekerjaan UI parsial yang diminta, fondasi navigasi memakai token yang tercatat pada inspeksi Figma sebelumnya. Ini bukan pengesahan palet, library, atau sistem desain aplikasi secara menyeluruh.

## Sumber dan data yang dibutuhkan

Inspeksi sebelumnya mencakup section navigasi `232:5152`. Dua warna, Roboto Medium dan SemiBold, ukuran, serta geometri navigasi merupakan temuan khusus section tersebut. MCP kini membatasi screenshot/konteks lanjutan pada paket Starter; aset navigasi tidak ada di repositori. Rujuk [catatan Figma](../integrations/FIGMA.md). Implementasi ikon dan detail badge sementara diberi label provisional.

- Minta tautan node yang telah disetujui untuk halaman foundations atau library, katalog komponen, dan layar referensi untuk beranda, katalog, autentikasi, keranjang, dan status feedback. Nama serta keberadaan halaman Figma tersebut perlu dikonfirmasi.
- Inventaris variabel semantik dan alias, koleksi dan mode, palet serta state, skala tipografi dan lisensi font, spacing, radius, elevation, ukuran sentuh, safe area, breakpoint, dan perilaku text scaling. Tanyakan spesifikasi untuk state gelap jika termasuk cakupan.
- Minta daftar komponen, status dan varian, serta aturan komposisi. Konfirmasi daftar ikon, sumber gambar dan logo, format ekspor, ukuran intrinsik, hak penggunaan, dan apakah komponen atau aset boleh dibundel. Konfirmasi aturan angka badge dan arti status aktif sebelum implementasi.

## Struktur yang diusulkan

| Area | Tanggung jawab |
|---|---|
| `app/theme/` | `AppColors` memetakan peran warna ke `ColorScheme`. `AppTypography` memetakan gaya teks ke `TextTheme`. `AppSpacing`, `AppRadius`, dan `AppShadows` menampung skala yang telah disetujui. `AppTheme` menyusun `ThemeData` dan tema komponen. Gunakan `ThemeExtension` bila token semantik perlu ikut berubah bersama tema dan tidak memiliki slot Material yang tepat. |
| `shared/widgets/` | UI yang dapat dipakai lintas fitur, seperti tombol, text field, dekorasi dan pesan form, app bar generik, badge generik, kerangka dialog dan bottom sheet, loading/empty/error berbasis `FeedbackPanel`, serta komponen gambar dengan placeholder dan error state. Pertahankan teks di ARB dan serahkan aturan validasi ke fitur. |
| `app/router/` | Integrasi bottom navigation aplikasi dengan shell, GoRouter, dan guard. Komponen visual menerima state aktif, badge, dan callback. Shell memutuskan navigasi. |
| `features/<fitur>/presentation/` | Product card awalnya milik katalog. Harga, stok, promosi, add to cart, serta isi dialog, sheet, dan form tetap milik fitur. Ekstrak bagian visual ke shared setelah beberapa fitur membutuhkan kontrak yang sama. |
| `assets/` | Simpan aset yang telah disetujui untuk dibundel dan daftarkan hanya direktori atau file yang dipakai. Gunakan screenshot sebagai referensi QA. |

## Urutan implementasi dan verifikasi

1. Bekukan cakupan pertama dan petakan nama token Figma ke peran tema Flutter. Catat sumber node, mode, nilai, dan keputusan ketika aksesibilitas memerlukan penyesuaian.
2. Implementasikan tema dan primitive yang benar-benar digunakan oleh komponen pertama. Gunakan data sintetis untuk contoh state, terutama loading, pressed, disabled, focus, invalid, empty, dan error. Sambungkan navigasi setelah perilaku guard dan badge disepakati.
3. Cocokkan perangkat referensi dengan screenshot untuk geometri dan state. Uji safe area, teks Indonesia panjang, skala teks, kontras, fokus, semantik, dan target sentuh. Jalankan widget test serta pemeriksaan Android/iOS. Tambahkan golden test terarah bila baseline render lintas platform sudah disepakati.
