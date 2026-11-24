# ADR 0005 — Konfigurasi environment

**Status:** diterima untuk Phase 1.

Gunakan `dart-define-from-file` untuk dev/staging/prod. Base URL kosong menonaktifkan I/O. Validasi konfigurasi saat bootstrap dan jangan simpan rahasia dalam artefak aplikasi. Pertimbangkan flavor native jika ID, URL scheme, atau kebutuhan instalasi bersamaan sudah disepakati.
