# Persiapan Google OAuth 2.0 dan OpenID Connect

Phase 1 mendokumentasikan kebutuhan konfigurasi. Pembuatan resource, akses GCP, pemasangan client ID, dan SDK sign-in ditunda.

| Area | Persiapan setelah disetujui |
|---|---|
| Google Cloud | Tentukan proyek per lingkungan atau kebijakan isolasi, OAuth consent screen, scope minimum, akun pengujian, dan pihak yang mengelola publikasi. |
| Android | Buat Android OAuth Client ID untuk application ID resmi dan SHA-1 setiap sertifikat signing yang relevan, termasuk debug dan distribusi. |
| iOS | Buat iOS OAuth Client ID untuk bundle ID resmi. Konfirmasi URL scheme callback dari client yang disetujui. |
| Backend | Konfirmasi Web OAuth Client ID yang menjadi server client ID dan audience ID token. Gunakan konfigurasi sesuai lingkungan dan verifikasi signature/issuer/audience/expiry/nonce. |
| Lingkungan | Siapkan daftar client ID publik dev, staging, prod setelah ID aplikasi resmi disetujui. Client secret, service account, dan private key hanya dikelola di server bila diperlukan. |
| Sign in with Apple | Konfirmasi Apple Developer account, App ID/capability dan audience per lingkungan, nonce, penanganan relay email, serta Services ID/redirect apabila alur Android memerlukannya. Simpan Apple private key di server. |

Lihat [alur yang diusulkan](AUTHENTICATION.md) dan [pertanyaan terbuka](../requirements/OPEN_QUESTIONS.md).
