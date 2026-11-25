# UI Autentikasi

Sumber visual adalah [section Authentication](https://www.figma.com/design/gMs1cpj2AGfubJP8slp0yM/Serba-Jaya-Ecommerce-App?node-id=232-5150) (`232:5150`) pada file `gMs1cpj2AGfubJP8slp0yM`. Inspeksi baca saja mencakup metadata section, konteks dan screenshot pada lima frame, serta variabel yang dipakai. Label di kanvas di luar frame bukan layar aplikasi. MCP tidak memberikan koneksi prototype untuk frame yang diperiksa. Perpindahan layar mengikuti guard yang sudah ada dan tindakan yang terlihat pada desain.

| Frame terverifikasi | Implementasi | Perilaku |
|---|---|---|
| `157:102` Onboarding | `AuthOnboardingPage` di `/session` | Logo tampil selama pemeriksaan sesi untuk rute yang memerlukan guard. Tamu tetap dapat membuka beranda tanpa menunggu layar pengantar atau timer. |
| `198:4477` Alert Login | `LoginRequiredDialog` di Navigator root | Dialog muncul di atas layar yang aktif saat tamu memilih rute terlindungi. Masuk membuka Login setelah transisi dialog selesai. Menutup dialog kembali ke layar asal. |
| `157:66` Login Akun | `LoginPage` di `/login` | iOS menampilkan Apple lalu Google. Android dan platform lain hanya menampilkan Google. Daftar membuka formulir di atas Login. Tutup kembali ke layar asal, atau ke beranda saat Login dibuka sebagai rute awal. |
| `198:4334`, `198:4400` Daftar Akun | `RegistrationPage` di `/login/register` | Satu formulir untuk keadaan kosong dan terisi. Foto, tanggal lahir, jenis kelamin, dan referral bersifat opsional. Nama, nomor telepon, email, dan persetujuan diperiksa secara lokal. |

## Token dan aset

- `Primary #FF0000`, `Text Black #333333`, `Text Gray #858585` dan gaya Roboto Bold 18 berasal dari variabel section. Frame Login dan Alert memakai judul 28, deskripsi 14 dengan line height 1,4, serta tombol 40. Radius tombol Login 8, tombol dan field Daftar 12, dan modal 20. Frame Daftar memakai field `#F8F9FB` dengan garis `#DDE1E6` setebal 0,5 dan keadaan email terhubung `#EAF9E3`.
- Token masuk melalui `AppColors`, `AppTypography`, `AppSpacing`, `AppRadius`, dan tema yang hanya diterapkan pada autentikasi. Teks pengguna tersedia di ARB Bahasa Indonesia. Label versi memakai 0.1.0 sesuai versi aplikasi saat ini dan dapat diatur melalui `APP_DISPLAY_VERSION` jika versi display berubah.
- Logo Serba Jaya dan ilustrasi Alert memakai PNG lokal yang diekspor dari Figma. Logo Google diekspor sebagai PNG dari node `157:86` untuk mempertahankan hasil mask. Logo Apple dan ikon penutup, garis, panah, foto, bendera, kalender, verifikasi email, serta checkbox dipakai sebagai SVG lokal. Foto dan email pada varian formulir terisi adalah data dinamis.
- Font Roboto dibundel untuk konsistensi Android dan iOS. Lisensi SIL OFL 1.1 disertakan dalam `assets/fonts/roboto/OFL.txt`. [Sumber dan lisensi Roboto](https://raw.githubusercontent.com/google/fonts/main/ofl/roboto/OFL.txt)

## Batas integrasi

- `signInActionProvider` membuka Google Sign-In ketika konfigurasi siap. UI menangani loading, pembatalan, penekanan berulang, dan kegagalan. Sign in with Apple belum diaktifkan. Sesudah memilih akun Google, pengguna tetap tamu sampai integrasi backend menghasilkan sesi aplikasi tervalidasi. [Alur autentikasi](../integrations/AUTHENTICATION.md)
- Email terhubung ditampilkan baca saja apabila alur provider yang tepercaya memasok nilainya. Sampai hasil registrasi dari backend tersedia, rute Daftar memakai field email yang dapat diisi. Bentuk visual field mengikuti input Figma. Formulir hanya memvalidasi data lokal. Persetujuan, data, dan foto tidak dikirim ke server. Pembatalan membuang data lokal.
- Pemilih foto memakai galeri sistem dan preview di memori. Android yang menghentikan proses saat membuka galeri akan kehilangan draft lokal. iOS memakai deskripsi akses foto, dengan metadata penuh dimatikan. Kamera, izin mikrofon, dan capability Apple Sign-In tidak dipasang untuk UI ini.
- Desain belum mencantumkan state gagal, layar Syarat & Ketentuan/Kebijakan Privasi, maupun menu pilihan. Pesan validasi dan status menggunakan teks lokal di dalam halaman. Tanggal lahir dan gender memakai kontrol Flutter. Konfirmasi dokumen legal, opsi gender akhir, aturan provider, dan validasi backend sebelum akun dapat dibuat. [Pertanyaan terbuka](../requirements/OPEN_QUESTIONS.md)

Durasi dan pola animasi ada di [sistem gerak](../architecture/MOTION.md). Pengujian dan keterbatasan build dicatat di [status proyek](../PROJECT_STATUS.md).
