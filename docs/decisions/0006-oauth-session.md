# ADR 0006 — OAuth/OpenID Connect dan sesi aplikasi

**Status:** arah autentikasi diterima, detail kontrak backend menunggu persetujuan.

Rencanakan Google Cloud OAuth 2.0/OpenID Connect dan Sign in with Apple untuk membuktikan identitas. Backend memvalidasi identitas dan mengelola sesi/otorisasi aplikasi. Karena kontrak belum disepakati, Phase 1 membatasi implementasi pada abstraksi sesi, storage, guard dan header. Lihat [Authentication](../integrations/AUTHENTICATION.md).
