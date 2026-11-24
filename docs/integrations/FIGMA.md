# Verifikasi Figma

Pemeriksaan baca saja pada 24 November 2026. [Serba Jaya Ecommerce App](https://www.figma.com/design/gMs1cpj2AGfubJP8slp0yM/Serba-Jaya-Ecommerce-App?node-id=232-5152&t=Bhf7FQ8XTw9gAvax-0), file key `gMs1cpj2AGfubJP8slp0yM`, node `232:5152`.

| Pemeriksaan | Hasil |
|---|---|
| Konektivitas dan autentikasi MCP | **PASS**. `whoami` mengonfirmasi Kahfi Zain, tim Starter, seat Full, dan peran admin tim. |
| Akses file | **PASS**. `create_session` berhasil setelah pemeriksaan sebelumnya menolak akses karena izin edit. Inspeksi menggunakan operasi baca saja. |
| Akses node dan konteks | **PASS**. `get_metadata` mengembalikan section *Bottom Navigation Bar*. `get_design_context` pada section hanya memberi hierarki. Lima permintaan terarah pada komponen anak mengembalikan konteks visual dan aset. |
| Screenshot dan variabel | **PASS**. `get_screenshot` menghasilkan PNG 550 × 831 yang berhasil diambil dan dilihat. `get_variable_defs` mengembalikan dua nilai untuk node ini. |
| Aset | **PASS** untuk sampel. Konteks tiap varian mencantumkan SVG ikon, dudukan dan tombol Chat, badge, serta PNG mask. Satu SVG dan satu PNG (62 × 62) berhasil diambil untuk verifikasi. Tool `download_assets` tersedia untuk PNG, JPG, SVG, dan PDF. Sampel ekspor berasal dari URL konteks. |
| Implementasi UI final | **DEFERRED** hingga disetujui secara terpisah. |

## Temuan pada node yang diperiksa

| Area | Data dari MCP |
|---|---|
| Komponen yang dapat digunakan kembali | Lima komponen dengan status tab aktif, masing-masing berukuran 390 × 90: Beranda `176:3135`, Keranjang `176:3119`, Chat `176:3103`, Pesanan `176:3087`, dan Profil `176:3071`. |
| Token dan warna | `Primary` `#FF0000` untuk status aktif dan `Text Gray` `#858585` untuk status nonaktif. Konteks juga menunjukkan latar dan angka badge berwarna putih. |
| Tipografi | Roboto Medium dan SemiBold. Label 10 px, angka badge 8 px, dengan tinggi baris 1,35× dalam konteks. |
| Tata letak | Pojok atas 24 px, slot label 60 px, area ikon 24 × 24 px, dan jarak vertikal ikon ke label 6 px. Tombol Chat 56 × 56 px berada di tengah dan menonjol 20 px dari tepi atas bar. Badge Keranjang 14 × 14 px memuat angka contoh, tanpa menetapkan aturan bisnis jumlahnya. |
| Cakupan aset | SVG untuk ikon Beranda, Keranjang, Pesanan, dan Profil, SVG untuk tombol/dudukan Chat dan badge, serta PNG sebagai mask logo Chat. URL MCP berumur pendek dan tidak disimpan dalam repositori. |

Hasil ini berlaku pada section dan lima komponennya. Koleksi token, library, breakpoint, spesifikasi aksesibilitas, dan layar lain belum diaudit. Nama `symbol` berasal dari metadata MCP; struktur component set native belum diverifikasi.

## Alur Figma ke Flutter setelah persetujuan UI

1. Konfirmasi node dan status aktif yang disetujui. Ambil metadata, screenshot, konteks pada komponen, dan variabel yang dipakai. Cocokkan screenshot dengan state sebelum mengerjakan widget.
2. Petakan nilai yang disetujui ke `ThemeData`, `ThemeExtension`, dan widget bersama. Gunakan konteks React/Tailwind dari MCP sebagai spesifikasi visual untuk Flutter. Pertahankan aksesibilitas, safe area, locale aplikasi, dan aturan guard di GoRouter.
3. Ekspor aset yang disetujui ke bentuk lokal yang sesuai. Pastikan ikon dan mask/logo Chat siap digunakan lintas platform. Periksa state aktif, badge dinamis, kontras, ukuran sentuh, dan skala teks di Android/iOS. Gunakan screenshot sebagai referensi pembanding.
