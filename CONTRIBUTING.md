# Kontribusi

Ikuti [Setup](docs/development/SETUP.md), [standar kode](docs/development/CODING_STANDARDS.md), dan [panduan fitur](docs/development/FEATURE_DEVELOPMENT_GUIDE.md). Tinjau [cakupan](docs/requirements/SCOPE.md) sebelum memilih pekerjaan.

- Gunakan `main` sebagai cabang stabil dan `develop` untuk integrasi bila digunakan tim. Buat cabang `feature/*`, `fix/*`, atau `refactor/*` sesuai tujuan.
- Gunakan Conventional Commits, misalnya `feat(cart): add item selection state` atau `fix(auth): handle session expiration`. Tulis ringkasan perubahan, konteks, hasil verifikasi, dan pekerjaan tertunda dalam PR.
- Jalankan `bash scripts/check.sh`. Untuk perubahan native, jalankan build platform terkait. Lihat [Testing](docs/development/TESTING.md).
- Sertakan `pubspec.lock` untuk perubahan dependensi. Simpan konfigurasi, kredensial, dan artefak build lokal di luar Git. Perbarui dokumentasi bersama perubahan perilaku.
