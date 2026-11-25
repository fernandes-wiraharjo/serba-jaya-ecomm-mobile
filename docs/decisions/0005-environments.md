# ADR 0005 — Konfigurasi environment

**Status:** diterima.

Gunakan `dart-define-from-file` untuk dev/staging/prod dan native flavor/scheme yang sama namanya pada Android/iOS. Base URL kosong menonaktifkan I/O. Validasi konfigurasi saat bootstrap dan jangan simpan rahasia dalam artefak aplikasi. ID resmi sudah disetujui dan dicatat di [panduan environment](../development/ENVIRONMENT.md).

Gradle wrapper memakai 8.14 dengan Android Gradle Plugin 8.11.1 dan Kotlin Gradle Plugin 2.2.20. Kombinasi ini berada pada batas atas dukungan penuh plugin Kotlin. Gradle 9.7.1 berada di luar rentang dukungan penuh sehingga wrapper dikembalikan ke versi 8.14 tanpa mengganti versi plugin. `signingReport` berhasil dengan kombinasi ini.
