# Bottom Navigation Bar

Bottom Navigation memakai `MainShell`, `AppBottomNavBar`, `BottomNavItem`, dan `NavigationBadge`. GoRouter menjadi satu-satunya sumber state tab terpilih; komponen tidak menyimpan state navigasi lokal.

## Bukti Figma dan status visual

Section `232:5152` serta lima komponennya berhasil dibaca melalui Figma Console Desktop Bridge dalam mode baca saja. Metadata dan screenshot lima state tersimpan di [`docs/verification/figma/`](../verification/figma/). Node anak: Beranda `176:3135`, Keranjang `176:3119`, Chat `176:3103`, Pesanan `176:3087`, dan Profil `176:3071`.

| Properti terukur | Spesifikasi Figma |
|---|---|
| Kanvas komponen | 390 × 90 px |
| Latar bar / cradle Chat | `#FFFFFF` / `#FCFBF8` |
| Radius sudut atas | 24 px |
| Shadow bar | `#2E261F` 7%, offset Y `-4`, blur 20 px |
| Warna aktif / nonaktif | `#FF0000` / `#858585` |
| Font label | Roboto Medium, 10 px, tinggi baris 13.5 px |
| Ikon umum | frame 24 × 24 px; jarak ikon-label 6 px |
| Badge Keranjang | 14 × 14 px, merah, teks putih Roboto 8 px |
| Chat tengah | cradle 70 × 70 px pada Y `-27`; tombol 56 × 56 px pada Y `-20` |
| Logo dan ring Chat | Logo putih `chat-branding-icon.png`, sekitar 31 × 31 px dengan proporsi dipertahankan; cradle `#FCFBF8` membentuk ring sekitar tombol merah. Ellipse merah Figma tidak memiliki stroke terpisah. |
| Shadow tombol Chat | merah 23%, offset Y `5`, blur 10 px |
| Slot label | lebar 60 px; pusat X pada 40, 114, 195, 276, 350 di lebar 390 |

Screenshot memperlihatkan ikon outline; state aktif mengubah warna ikon dan label ke merah. Tombol Chat tetap merah pada kelima varian. Teks Beranda terpilih memakai SemiBold, label aktif lainnya Medium. Contoh badge `8` adalah isi contoh pada Figma, bukan jumlah aplikasi.

## Implementasi

- `AppBottomNavBar` menskalakan posisi pusat slot dari lebar acuan 390 px, mempertahankan slot minimum yang tidak tumpang tindih pada lebar kecil, radius, shadow, cradle, tombol Chat, dan SafeArea bawah.
- `BottomNavItem` menerima aset kedua state, status terpilih, label aksesibel, dan callback. Tombol Chat selalu memakai logo putih dari `assets/navigation/chat-branding-icon.png` dengan `BoxFit.contain` pada tombol merah; tidak memakai ikon Material generik.
- `NavigationBadge` menerima jumlah dari pemanggil, menyembunyikan nol, dan membatasi tampilan di atas 99 menjadi `99+`. Nilai tidak dibuat secara lokal.
- Badge `8` yang tampak pada screenshot Figma ditutup dengan permukaan bar dan diganti badge runtime; ikon Cart tetap mempertahankan potongan gambar Figma.
- Rute Keranjang, Pesanan, dan Profil tetap terlindungi. Ketukan oleh tamu memakai dialog yang sama di atas halaman aktif; aturan auth tidak diubah.

Tombol Chat memakai `assets/navigation/chat-branding-icon.png`, logo putih transparan 123 × 124 px yang dipasang 31 × 31 px dengan `BoxFit.contain`; file itu sudah tercakup oleh deklarasi folder `assets/navigation/` pada `pubspec.yaml`. `chat-branding.png` adalah gambar lingkaran merah dan tidak digunakan sebagai logo. Aset ikon tab lain tidak diubah. Nama file lama `orders-innactive.png` dirapikan menjadi `orders-inactive.png` agar cocok dengan referensi kode; checksum gambar tetap sama. Screenshot tidak dipakai untuk meratakan UI: tata letak, teks, badge, safe area, tombol, dan interaksi dibangun sebagai widget Flutter.

Implementasi mengikuti ukuran dan warna yang terukur, tetapi belum boleh disebut pixel-perfect. Hasil runtime harus dibandingkan pada screenshot dan perangkat; catatan akhir berada di [`PROJECT_STATUS.md`](../PROJECT_STATUS.md).
