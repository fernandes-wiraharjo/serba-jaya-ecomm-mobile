# Integrasi Figma

Panduan permanen agent ada di [`AGENTS.md`](../../AGENTS.md). Untuk implementasi UI Flutter, gunakan Figma Console MCP (`figma-console`) dan Desktop Bridge secara baca saja; MCP resmi `figma` dan REST tidak dipakai pada pekerjaan ini.

## Pemeriksaan koneksi — 25 November 2026

| Pemeriksaan | Hasil aktual |
|---|---|
| Figma Console MCP | Terhubung; versi server yang dilaporkan 1.46.0 |
| Desktop Bridge | Pengguna membuka plugin setelah status awal tidak tersambung. Probe berikutnya berhasil; WebSocket lokal sehat dan operasi Plugin API merespons. Port fallback ditetapkan transport secara dinamis dan tidak dikunci di proyek. |
| Sesi Figma Desktop | Berhasil membaca file aktif melalui plugin; tidak mengambil atau mencatat token/kredensial maupun identitas akun. |
| File | `Serba Jaya Ecommerce App`, key `gMs1cpj2AGfubJP8slp0yM`, Page 1 |
| Node navigasi | `232:5152`, section `Bottom Navigation Bar`, metadata dan screenshot berhasil |
| Node Header | Lima komponen di bawah berhasil ditemukan dan dibaca dari Desktop Bridge |
| REST / MCP resmi | Tidak dipakai |

## Tool Figma Console yang digunakan

- `figma_get_status` (probe), `figma_diagnose`, `figma_list_open_files` untuk transport dan file aktif.
- `figma_search_components` untuk menemukan Header.
- `figma_get_file_data` untuk hierarki node navbar.
- `figma_execute` untuk membaca Plugin API lokal dan menguji ekspor vector, tanpa mutasi desain.
- `figma_capture_screenshot` untuk sepuluh screenshot referensi.

Keterbatasan yang ditemui: `figma_get_component_for_development` terkena HTTP `429 rate limit` dalam inspeksi terdahulu dan tidak dicoba berulang. Ekspor root component dengan `node.exportAsync({format:'SVG'})` gagal karena tidak memiliki visible layers. Plugin API memakai `dynamic-page`, sehingga percobaan sinkron `getNodeById` ditolak; pembacaan berhasil setelah memakai `getNodeByIdAsync`. Runtime plugin tidak menyediakan `TextDecoder`; byte SVG didekodekan dengan cara lain. Child vector yang terlihat lalu berhasil diekspor lokal: Cart `474:4792`, Bell `474:4787`. Dokumen Figma tidak diubah.

Screenshot referensi: [`docs/verification/figma/`](../verification/figma/). Crop aset yang dipakai aplikasi berada di `assets/navigation/` dan `assets/header/`; aset itu adalah raster screenshot crop, bukan file SVG/PNG asli yang diekspor terpisah.

## Bottom Navigation — node `232:5152`

Section berisi lima komponen state terpilih, semuanya 390 × 90 px:

| Tujuan | Node komponen |
|---|---|
| Beranda | `176:3135` |
| Keranjang | `176:3119` |
| Chat | `176:3103` |
| Pesanan | `176:3087` |
| Profil | `176:3071` |

Nilai yang tercatat dari Plugin API/screenshot:

- Permukaan putih `#FFFFFF`; cradle Chat `#FCFBF8`; radius atas 24 px.
- Shadow bar `#2E261F` dengan alpha sekitar 0.07, offset `(0,-4)`, blur 20 px.
- Warna aktif `#FF0000`, nonaktif `#858585`; label Roboto 10 px dengan tinggi baris 13.5 px.
- Label aktif Beranda memakai SemiBold; state aktif lain Medium. Ikon berada dalam frame 24 × 24 px, dengan jarak vertikal 6 px ke label.
- Slot 60 px dengan pusat X 40, 114, 195, 276, 350 pada lebar 390 px. Ikon outline home sekitar 18 × 18, cart 20 × 18, order 12 × 19, profil 18 × 19 px.
- Badge Keranjang merah 14 × 14 px, angka putih Roboto 8 px. Angka `8` adalah contoh visual, bukan data bisnis.
- Cradle Chat 70 × 70 px di `(160,-27)`; tombol merah 56 × 56 px di `(167,-20)`, shadow merah alpha .23, offset Y5, blur10; logo mask putih sekitar 31 × 31 px.

Widget menerapkan geometri, warna, shadow, state aktif/nonaktif, badge dinamis, dan safe area. Rincian ada di [Bottom Navigation Bar](../components/BOTTOM_NAVIGATION_BAR.md).

## Header yang ditemukan

`figma_search_components(query: "Header")` menemukan lima Header di Page 1:

| Node | Nama | Dimensi / isi utama |
|---|---|---|
| `2:1753` | Header Mobile | 390 × 55; logo, search, menu; latar `#FCFBF8` |
| `427:1281` | Header Page Name + Icon | 390 × 55; back, judul 18 px Bold, cart + badge; putih |
| `427:1170` | Header Mobile - Search + Cart | 390 × 55; field 287 × 38, back, cart |
| `427:1249` | Header Mobile - Search + (x) + Cart | state query terisi dengan clear 18 × 18 |
| `474:4779` | Header Mobile | 390 × 55; logo, cart, notifikasi; latar `#FCFBF8` |

Header memakai Roboto, judul `#333333`, field `#F8F9FB` dengan border `#DDE1E6` 0.5 px dan radius12, badge14 px. Pada node `474:4779`, Cart vector berukuran 20 × 18 px di posisi `(304,19)` dan Bell berukuran 14 × 18.25 px di `(345,19)`; masing-masing badge contoh berukuran 14 × 14 px. Shadow pada empat varian lama berupa hitam 15% dengan blur24; varian Mobile cart/notifikasi yang terakhir tidak menampilkan shadow pada screenshot. Teks `Detail Produk`, query `Jeruk`, dan angka badge `8` adalah konten sampel.

MCP Console tidak mengembalikan koleksi variable/design-token untuk inspeksi sesi ini. Nilai warna dan tipografi di atas dibaca dari fills, style teks, efek, geometri, dan screenshot Plugin API lokal; jangan menganggapnya sebagai audit lengkap variable library. Implementasi dan pemetaan sementara dibahas di [Header](../components/HEADER.md).

## Batas verifikasi

- Perbandingan visual Flutter tersedia jika screenshot aplikasi runtime berhasil ditangkap; status dan tautannya dicatat di [status proyek](../PROJECT_STATUS.md).
- Aset asli vektor resolusi tinggi masih dibutuhkan untuk ketajaman terbaik pada density tinggi. Daftar screenshot dan node lokal di atas dapat dipakai untuk ekspor manual bila Desktop Bridge export kembali tersedia.
- Hanya data yang didukung node dan screenshot yang diimplementasikan. Node atau screen yang tidak ada tidak dijadikan alasan untuk mengarang alur produk.
- Section Autentikasi yang dibaca dalam task terdahulu tercatat di [UI Autentikasi](../features/AUTHENTICATION_UI.md).
