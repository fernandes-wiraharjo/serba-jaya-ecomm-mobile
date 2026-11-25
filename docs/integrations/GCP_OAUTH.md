# Persiapan Google OAuth 2.0 dan OpenID Connect

Dokumen ini menyiapkan arsitektur dan urutan integrasi. Android flavors, iOS schemes, dan ID aplikasi sudah tersedia. Data yang dapat disalin ke registrasi beserta fingerprint debug aktual tercatat di [data pendaftaran GCP OAuth](GCP_OAUTH_REGISTRATION.md). Pembuatan resource, pemasangan client ID, dan SDK sign-in tetap ditunda sampai disetujui.

| Area | Persiapan setelah disetujui |
|---|---|
| Google Cloud | Tentukan proyek per lingkungan atau kebijakan isolasi, OAuth consent screen, scope minimum, akun pengujian, dan pihak yang mengelola publikasi. |
| Android | Buat Android OAuth Client untuk tiap application ID dengan SHA-1 sertifikat build yang diuji. Debug certificate tersedia untuk pengembangan lokal. Signing release belum dikonfigurasi. |
| iOS | Buat iOS OAuth Client untuk tiap Bundle ID. Tambahkan reversed client ID callback hanya dari nilai yang dihasilkan GCP setelah disetujui. Team ID belum tersedia. |
| Backend | Konfirmasi Web OAuth Client ID yang akan menjadi server client ID dan audience ID token. Verifikasi signature, issuer, audience, expiry, dan nonce sesuai kontrak backend. |
| Lingkungan | Kelola client ID publik dev, staging, dan prod secara terpisah setelah disetujui. Client secret, service account, serta private key hanya berada di backend atau secret manager. |
| Sign in with Apple | Konfirmasi Apple Developer account, App ID/capability dan audience per lingkungan, nonce, penanganan relay email, serta Services ID/redirect apabila alur Android memerlukannya. Simpan Apple private key di server. |

Tidak ada Firebase Authentication, OAuth client ID, API key, atau credential provider yang ditambahkan. Lihat [data pendaftaran](GCP_OAUTH_REGISTRATION.md), [alur yang diusulkan](AUTHENTICATION.md), dan [pertanyaan terbuka](../requirements/OPEN_QUESTIONS.md).
