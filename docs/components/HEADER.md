# Header

`AppHeader` adalah boundary reusable untuk status bar iOS/Android dan tinggi konten Header 55 px. `MainShell` menerapkan boundary satu kali serta menghapus inset atas dari body. Seluruh visual Header berada pada widget reusable di `lib/shared/widgets/header/`.

## Varian yang terbaca di Figma

Varian di bawah berasal dari Page 1 pada file Serba Jaya Ecommerce App. Metadata node dan screenshot Bridge disimpan di [`docs/verification/figma/`](../verification/figma/).

| Varian | Node | Rincian terukur |
|---|---|---|
| Mobile: Search + Menu | `2:1753` | 390 × 55 px, latar `#FCFBF8`, logo 43 × 42 px, search 28 × 28 px, menu 24 × 24 px; shadow hitam 15%, blur 24 px |
| Mobile: Cart + Notifikasi | `474:4779` | 390 × 55 px, latar `#FCFBF8`, logo 43 × 42 px, cart 29 × 24 px, notifikasi 23 × 24 px, badge 14 px |
| Nama Halaman + Cart | `427:1281` | 390 × 55 px, putih, panah kembali 24 px, judul Roboto Bold 18 px, cart dan badge 14 px; shadow 15%, blur 24 px |
| Search + Cart | `427:1170` | search 287 × 38 px di X44/Y9, `#F8F9FB`, border `#DDE1E6` 0.5 px, radius 12 px, teks 16 px; back dan cart |
| Search + Clear + Cart | `427:1249` | geometri field yang sama, ikon clear 18 × 18 px saat query berisi teks |

Contoh teks Figma seperti `Detail Produk`, `Jeruk`, dan badge `8` bersifat sampel. Judul, query, jumlah badge, dan callback disediakan secara dinamis oleh pemanggil.

## Komponen dan pemetaan rute

- `HeaderMobile` menyediakan varian Search + Menu dan menerima callback opsional. Tidak ada layar pencarian atau menu pada aplikasi saat ini, maka callback tersebut tidak dipalsukan.
- `HeaderMobileActions` menyediakan varian Cart + Notifikasi. Ini dipasang pada Beranda; aksi Cart dan Notifikasi memakai pemeriksaan akses tujuan yang sama dengan navbar. Vector Cart (`474:4792`) dan Bell (`474:4787`) diekspor dari layer Figma masing-masing agar badge contoh `8` tidak tertanam pada ikon.
- `HeaderPageTitle` menyediakan judul dinamis, tombol kembali, dan aksi Cart; dipakai untuk rute Chat, Keranjang, Pesanan, Profil, dan Notifikasi yang sudah terdaftar. Judul tab pada placeholder bukan nama layar bisnis final. Kembali membawa pemakai ke Beranda.
- `HeaderSearch` dan `AppSearchField` menyediakan varian Search + Cart, nilai teks/query, callback perubahan/pengiriman, dan clear. Varian ini reusable, tetapi belum dipasang karena belum ada layar pencarian/katalog yang ada dalam lingkup pekerjaan.
- `HeaderActionButton` mengemas aset, target ketuk semantik, callback opsional, dan badge dinamis.

Pemetaan judul placeholder ke komponen Nama Halaman adalah pilihan integrasi sementara agar rute yang telah ada memakai boundary yang sama; desain Header khusus Cart/Pesanan/Profil/Chat belum tersedia di Figma. Jangan menganggapnya desain bisnis final.

Aset di `assets/header/` memadukan vector asli Cart/Bell (`cart.svg`, `notification.svg`) dan crop raster Bridge untuk logo serta ikon lain. Ekspor root component sebelumnya gagal karena tidak memiliki visible layers; pembacaan child vector secara lokal kemudian berhasil. Crop raster 1× dapat sedikit kurang tajam pada density tinggi. UI tetap dibangun sebagai widget Flutter, bukan screenshot layar datar.
