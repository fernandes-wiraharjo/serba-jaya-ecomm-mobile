# Pemecahan masalah

- Versi SDK berbeda: jalankan `flutter --version` dan periksa path Flutter di VS Code dan terminal. Gunakan versi di [Setup](SETUP.md).
- Plugin atau ARB belum ditemukan: jalankan `flutter pub get` lalu `flutter gen-l10n`. Pada perangkat, hentikan aplikasi dan build ulang jika registrasi plugin berubah.
- Masalah SDK Android: cek `flutter doctor -v`, SDK 36, NDK dan JDK 17. Jalankan `flutter doctor --android-licenses` setelah meninjau lisensi yang berlaku.
- Simulator tidak terdeteksi: cek `xcode-select -p` dan `xcrun simctl list devices`, jalankan perangkat yang sesuai dari Xcode. Gunakan `flutter build ios --simulator` untuk memeriksa build tanpa boot.
- Aplikasi menampilkan error saat startup: periksa nilai `APP_ENV`, `ENABLE_DEBUG_LOGGING`, dan format base URL di [Environment](ENVIRONMENT.md).
- Permintaan lokal ditolak: isi base URL HTTPS yang disetujui. Untuk rute terlindungi, login nyata memerlukan integrasi backend. Selama Phase 1 gunakan override fake pada tes.
- Penyimpanan sesi bermasalah: verifikasi plugin pada Android/iOS dan ulangi logout dari Beranda bila tombol retry tampil. Jangan menyalin payload storage ke log.
