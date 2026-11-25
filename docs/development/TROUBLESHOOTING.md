# Pemecahan masalah

- Versi SDK berbeda: jalankan `flutter --version` dan periksa path Flutter di VS Code dan terminal. Gunakan versi di [Setup](SETUP.md).
- Plugin atau ARB belum ditemukan: jalankan `flutter pub get` lalu `flutter gen-l10n`. Pada perangkat, hentikan aplikasi dan build ulang jika registrasi plugin berubah.
- Masalah SDK Android: cek `flutter doctor -v`, SDK 36, NDK dan JDK 17. Jalankan `flutter doctor --android-licenses` setelah meninjau lisensi yang berlaku.
- Perangkat fisik tidak terdeteksi: jalankan `flutter devices`, periksa kabel USB/wireless debugging, buka kunci perangkat, dan aktifkan Developer Mode bila diperlukan. Jangan meluncurkan emulator/simulator sebagai fallback; jika perangkat tetap tidak tersedia, lewati runtime test dan jalankan verifikasi Dart yang relevan sesuai [aturan proyek](../../AGENTS.md).
- Aplikasi menampilkan error saat startup: periksa nilai `APP_ENV`, `ENABLE_DEBUG_LOGGING`, dan format base URL di [Environment](ENVIRONMENT.md).
- Permintaan lokal ditolak: isi base URL HTTPS yang disetujui. Untuk rute terlindungi, login nyata memerlukan integrasi backend. Selama Phase 1 gunakan override fake pada tes.
- Penyimpanan sesi bermasalah: verifikasi plugin pada Android/iOS dan ulangi logout dari Beranda bila tombol retry tampil. Jangan menyalin payload storage ke log.
