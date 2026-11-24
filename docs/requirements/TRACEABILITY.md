# Pemetaan kebutuhan

Bagian mengacu pada PDF lokal *Ruang Lingkup Pekerjaan* v1.0. Aturan lengkap dan batas lingkup ada di [SCOPE](SCOPE.md).

| Modul | PDF | Kebutuhan | Phase 1 |
|---|---|---|---|
| auth | §2.2, §5 | Google/Apple, registrasi, kontrol sesi | Kontrak sesi, secure storage, restoration, logout, guard, login gate; integrasi ditunda |
| home | §2.1 | Navigasi, banner, rekomendasi, kategori, diskon | Shell dan titik masuk Notifikasi |
| catalog | §2.4–2.5 | Jelajah tamu, cari, filter, sort, pagination, detail produk | Rencana |
| address | §2.3, §2.10 | CRUD, lokasi peta, alamat utama | Rencana |
| cart | §2.6 | Pemilihan item, jumlah, catatan, voucher, total | Rute terlindungi |
| checkout | §2.7 | Ringkasan, self pickup, driver internal, jadwal, diskon dan poin | Rencana |
| payment | §2.7, §3 | Upload bukti dan hasil verifikasi admin | Rencana |
| orders | §2.7–2.8 | Daftar/filter, detail, penerimaan, bantuan | Rute terlindungi |
| notifications | §2.9 | Push, daftar dan tujuan notifikasi | Rute terlindungi |
| profile | §2.10 | Profil, hapus akun, logout | Rute terlindungi dan aksi logout lokal |
| membership | §2.10, §5 | Pengajuan dokumen identitas dan status | Rencana |
| vouchers | §2.6–2.7, §2.10 | Voucher tersedia dan penggunaan | Rencana |
| rewards | §2.7, §2.12 | Perolehan, saldo dan penukaran poin | Rencana |
| referral | §2.2, §2.11 | Kode Marketing, komisi, pemantauan dan penarikan | Rencana |
| support | §2.8–2.9, §5 | Redirect WhatsApp untuk Chat dan bantuan pesanan | Rute Chat publik, tautan ditunda |
