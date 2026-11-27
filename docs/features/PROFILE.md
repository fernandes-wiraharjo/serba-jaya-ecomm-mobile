# Modul Profil

Sumber desain adalah section Profile `232:5159` di Serba Jaya Ecommerce App. Figma Console 2.0.0 membaca file melalui Desktop Bridge. Probe WebSocket berhasil dalam 30 ms. [Screenshot section](../verification/figma/profile-section.png) merekam seluruh kelompok. Desain dibaca tanpa perubahan pada file Figma. Pembacaan frame tidak menemukan tautan prototipe. Pemetaan navigasi memakai label menu dan kelompok layar.

| Bagian | Node Figma | Implementasi |
|---|---|---|
| Profil pelanggan | `321:338` | Tab Profil, kartu identitas, ringkasan manfaat, menu akun dan preferensi |
| Profil membership dan marketing | `321:428`, `359:1087` | Memerlukan atribut status dan peran dari sumber profil |
| Edit Profil | `168:2483` | Validasi nama, pilihan gender, pratinjau perubahan lokal dan kontak hanya baca |
| Alamat Saya, tambah dan ubah | `168:2696`, `439:1479`, `439:1705` | Tambah, ubah, hapus dengan konfirmasi dan pemilihan satu alamat utama dalam memori. Form menerima saran lokasi dan entri manual. Pilihan wilayah dari katalog menunggu data |
| Ubah lokasi | `169:3014` | Picker native, GPS foreground dan geocoder OS tersedia. Live map menunggu key dan Places menunggu backend |
| Membership | `218:4494`, `218:4540`, `223:4762`, `263:308`, `263:276`, `326:764`, `326:781` | Titik masuk dan tiga tahap terlihat. Kamera KTP, pengajuan, hasil verifikasi, dan benefit aktif tertunda |
| Poin, riwayat, voucher | `333:963`, `333:1032`, `342:962`, `342:993`, `165:1685` | Halaman dan navigasi poin, voucher, serta riwayat dengan status layanan belum tersedia |
| Hapus akun | `379:2960`, `379:2995`, `379:3030` | Validasi kata HAPUS dan persetujuan, dialog dengan status layanan belum tersedia |
| Keluar akun | `416:6042` | Dialog konfirmasi dan logout melalui controller sesi |
| Referral dan marketing | `340:860`, `340:885`, `340:565`, `340:725`, `340:787`, `359:1264`, `359:1187`, `359:1284` | Layar dan flow tertunda |
| Penarikan dan rekening | `359:1311`, `359:1362`, `359:1400`, `359:1422`, `359:1447` | Layar dan flow tertunda |

Tab Profil berada di shell dan memakai navbar yang sudah ada. Halaman turunan memakai GoRouter, transisi aplikasi, dan header bersama. Untuk sementara, tab Profil dan subrutenya dapat dibuka sebagai tamu. Logout hanya tampil saat ada sesi aktif. Google Account Preview DEV tetap terpisah dari sesi aplikasi.

Riverpod menyimpan perubahan profil dan alamat hanya dalam memori selama sesi. Data prototipe Figma tidak dipakai sebagai identitas, saldo, voucher, atau transaksi pengguna. Kontrak Profile API, status membership, saldo dan riwayat, peran marketing, data referral, bank, dan penghapusan akun diperlukan untuk integrasi server. Penggantian foto belum aktif karena pipeline pemrosesan WebP terpusat belum tersedia.

Delapan aset Profil diekspor dari layer Figma dan dikonversi ke WebP lossless. Aset berada di folder akun yang sudah terdaftar, `assets/auth/`, dengan prefiks `profile-`. Ikon sumber berasal dari node `321:356`, `321:363`, `321:378`, `321:386`, `321:395`, `321:402`, dan `321:383`; ilustrasi keluar dari `416:6114`. Avatar contoh Figma tidak dijadikan foto pengguna aplikasi.

`flutter devices` tidak mendeteksi Android atau iOS fisik. Uji runtime dan perbandingan visual di perangkat masih tertunda.

Verifikasi lokal 27 November 2026. Format Dart dan `flutter analyze --no-pub` lulus. Sebanyak 27 tes lulus pada `app_test.dart`, `motion_navigation_test.dart`, dan `session_test.dart`. Cakupan termasuk pemeriksaan akses Profil sebelum perubahan aturan tamu, edit dan validasi nama, pembatalan logout dan logout lokal, serta regresi transisi dan sesi. Delapan aset terdeteksi sebagai WebP dan `git diff --check` lulus.

Setelah akses tamu dibuka, format Dart dan analisis lulus. Seluruh 19 tes navigasi aplikasi dan transisi lulus, termasuk akses tamu ke Profil, Edit Profil, serta tautan langsung Tambah Alamat.
