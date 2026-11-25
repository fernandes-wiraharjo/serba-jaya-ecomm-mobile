# Data pendaftaran GCP OAuth

Catatan verifikasi 25 November 2026. Data di bawah diambil dari konfigurasi Gradle/Xcode dan debug keystore yang ada di komputer pengembang. Belum ada client OAuth atau resource GCP yang dibuat.

## Development

**Android**

| Kolom Google Cloud Console | Nilai |
|---|---|
| OAuth Client Name | `Serba Jaya Android DEV` |
| Application ID / package name | `id.serbajaya.ecommerce.dev` |
| SHA-1 signing certificate | `7B:37:8A:7B:98:DB:C8:44:9B:EA:79:ED:F6:88:E8:85:7F:07:9C:CA` |
| SHA-256 signing certificate (catatan) | `DC:14:A5:5E:08:62:D3:93:76:97:54:82:01:69:AC:0A:E9:28:B6:96:E0:3A:2C:E6:52:40:88:39:2E:E5:1E:EF` |
| Certificate type | Debug lokal, self-signed X.509, RSA 2048-bit, signature `SHA256withRSA` |
| Alias / masa berlaku | `AndroidDebugKey` / berakhir 14 Februari 2055 |
| Kesiapan fingerprint | Siap untuk klien Android development lokal/debug |

**iOS**

| Kolom | Nilai |
|---|---|
| OAuth Client Name | `Serba Jaya iOS DEV` |
| Bundle ID | `id.serbajaya.ecommerce.dev` |

**Web/server**

| Kolom | Nilai |
|---|---|
| OAuth Client Name | `Serba Jaya Web DEV` |
| Client ID | Belum dibuat |

## Staging

**Android**

| Kolom Google Cloud Console | Nilai |
|---|---|
| OAuth Client Name | `Serba Jaya Android STG` |
| Application ID / package name | `id.serbajaya.ecommerce.staging` |
| SHA-1 signing certificate | `7B:37:8A:7B:98:DB:C8:44:9B:EA:79:ED:F6:88:E8:85:7F:07:9C:CA` |
| SHA-256 signing certificate (catatan) | `DC:14:A5:5E:08:62:D3:93:76:97:54:82:01:69:AC:0A:E9:28:B6:96:E0:3A:2C:E6:52:40:88:39:2E:E5:1E:EF` |
| Certificate type | Debug lokal, self-signed X.509, RSA 2048-bit, signature `SHA256withRSA` |
| Alias / masa berlaku | `AndroidDebugKey` / berakhir 14 Februari 2055 |
| Kesiapan fingerprint | Siap untuk klien Android staging lokal/debug |

**iOS**

| Kolom | Nilai |
|---|---|
| OAuth Client Name | `Serba Jaya iOS STG` |
| Bundle ID | `id.serbajaya.ecommerce.staging` |

**Web/server**

| Kolom | Nilai |
|---|---|
| OAuth Client Name | `Serba Jaya Web STG` |
| Client ID | Belum dibuat |

## Production

**Android**

| Kolom | Nilai |
|---|---|
| OAuth Client Name | `Serba Jaya Android PROD` |
| Application ID / package name | `id.serbajaya.ecommerce` |
| Debug SHA-1 | `7B:37:8A:7B:98:DB:C8:44:9B:EA:79:ED:F6:88:E8:85:7F:07:9C:CA` |
| Debug SHA-256 | `DC:14:A5:5E:08:62:D3:93:76:97:54:82:01:69:AC:0A:E9:28:B6:96:E0:3A:2C:E6:52:40:88:39:2E:E5:1E:EF` |
| Production release SHA-1 / SHA-256 | **NOT CONFIGURED** |
| Production signing status | **NOT CONFIGURED**. `prodRelease` has no signing config, keystore, alias, or certificate. |
| Google Play App Signing status | Belum diverifikasi karena akses/data Play Console belum tersedia. |
| Batas kegunaan debug | Fingerprint debug hanya untuk instalasi/debug lokal `prod`. Jangan daftarkan sebagai fingerprint distribusi production. |

Debug SHA-1 dan SHA-256 di semua environment berasal dari satu `~/.android/debug.keystore` lokal. Alias-nya `AndroidDebugKey`, tipe entri `PrivateKeyEntry`, sertifikat self-signed X.509 RSA 2048-bit dengan signature `SHA256withRSA`, berlaku sampai 14 Februari 2055. Keystore dan password tidak disalin ke repositori atau dokumen. Pengembang lain dapat memiliki sertifikat debug yang berbeda.

### Ringkasan enam varian Android yang diminta

| Varian | Application ID | Signing config | SHA-1 / SHA-256 / alias / sertifikat |
|---|---|---|---|
| `devDebug` | `id.serbajaya.ecommerce.dev` | `debug` | SHA-1 dan SHA-256 di atas; `AndroidDebugKey`; self-signed X.509 RSA 2048-bit, `SHA256withRSA`, berakhir 14 Februari 2055 |
| `stagingDebug` | `id.serbajaya.ecommerce.staging` | `debug` | SHA-1 dan SHA-256 di atas; `AndroidDebugKey`; self-signed X.509 RSA 2048-bit, `SHA256withRSA`, berakhir 14 Februari 2055 |
| `prodDebug` | `id.serbajaya.ecommerce` | `debug` | SHA-1 dan SHA-256 di atas; `AndroidDebugKey`; self-signed X.509 RSA 2048-bit, `SHA256withRSA`, berakhir 14 Februari 2055 |
| `devRelease` | `id.serbajaya.ecommerce.dev` | **NOT CONFIGURED** | Tidak ada sertifikat, fingerprint, alias, atau tanggal kedaluwarsa |
| `stagingRelease` | `id.serbajaya.ecommerce.staging` | **NOT CONFIGURED** | Tidak ada sertifikat, fingerprint, alias, atau tanggal kedaluwarsa |
| `prodRelease` | `id.serbajaya.ecommerce` | **NOT CONFIGURED** | Tidak ada sertifikat, fingerprint, alias, atau tanggal kedaluwarsa |

`devProfile`, `stagingProfile`, dan `prodProfile` juga memakai konfigurasi debug dan fingerprint yang sama. Nilai SHA-1 dan SHA-256 tiap debug baris sama dengan Development di atas.

**iOS**

| Kolom | Nilai |
|---|---|
| OAuth Client Name | `Serba Jaya iOS PROD` |
| Bundle ID | `id.serbajaya.ecommerce` |

**Web/server**

| Kolom | Nilai |
|---|---|
| OAuth Client Name | `Serba Jaya Web PROD` |
| Client ID | Belum dibuat |

## Checklist saat registrasi disetujui

1. Pastikan satu proyek GCP dan kebijakan pemisahan environment telah ditetapkan. Jangan membuat resource sebelum persetujuan eksplisit.
2. Buat client type **Android** untuk masing-masing package ID di atas dengan SHA-1 dari sertifikat yang menandatangani build yang akan diuji. Untuk Android OAuth, Google meminta pasangan package name dan sertifikat SHA-1. SHA-256 dicatat untuk inventaris sertifikat. [Panduan autentikasi client Android](https://developers.google.com/android/guides/client-auth)
3. Buat client type **iOS** untuk setiap Bundle ID. Apple Team ID belum tersedia dan tidak diverifikasi di project settings. Google menyebut Team ID opsional saat membuat iOS client, tetapi dibutuhkan jika App Check diaktifkan. [Akses Google API dari iOS](https://developers.google.com/identity/sign-in/ios/api-access)
4. Setelah menyetujui integrasi iOS, ambil `REVERSED_CLIENT_ID` yang dihasilkan dari iOS OAuth client dan tambahkan URL scheme callback native sesuai petunjuk resmi. Jangan menebak atau menulis URL scheme sebelum ada client ID.
5. Buat Web application client hanya setelah backend mengonfirmasi audience/client ID per environment, redirect URI, dan origin yang diperlukan. Web client ID adalah server client ID untuk alur ID token backend pada integrasi Google. Client ID belum ada dan tidak di-hardcode.
6. Untuk rilis Android, konfigurasi key release terpisah dan catat sertifikat lokal. Jika Play App Signing dipakai, ambil fingerprint app signing key dari Play Console dan daftarkan fingerprint itu pada API provider. Upload key dan app signing key adalah dua sertifikat yang berbeda. [Play App Signing](https://support.google.com/googleplay/android-developer/answer/9842756?hl=en)
7. Simpan client ID publik melalui konfigurasi per environment setelah persetujuan. Simpan client secret, service account, dan private key hanya di server/secret manager. Server wajib memverifikasi signature token, issuer, audience, expiration, dan nonce sesuai kontrak backend.
8. Uji callback, audience, pemisahan environment, dan akun pengujian pada Android serta iOS sebelum membuka akses produksi.

## Status sekarang

| Item | Status |
|---|---|
| Application ID dan Bundle ID | PASS — keenam ID diverifikasi dari konfigurasi native efektif |
| Android debug SHA-1/SHA-256 | PASS — diambil dari `./gradlew signingReport` dan diverifikasi dengan `keytool` |
| Development/staging Android debug registration data | PASS — siap dipakai untuk pendaftaran client debug lokal |
| Production release fingerprint | NOT CONFIGURED — signing key release belum disediakan |
| Google Play App Signing | NOT VERIFIED — informasi Play Console belum tersedia |
| iOS Team ID dan provisioning | NOT CONFIGURED — belum disediakan |
| GCP projects, consent screen, dan OAuth client IDs | DEFERRED — resource tidak dibuat |
| SDK Sign in with Google / Sign in with Apple | DEFERRED — integrasi provider belum disetujui |

Lihat [panduan integrasi GCP OAuth](GCP_OAUTH.md), [alur autentikasi](AUTHENTICATION.md), dan [build/release](../development/RELEASE.md).
