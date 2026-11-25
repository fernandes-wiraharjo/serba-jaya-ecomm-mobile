# Konfigurasi lingkungan

Aplikasi Android dan iOS memiliki tiga konfigurasi native yang masing-masing dipasangkan dengan `APP_ENV` dan satu file define.

| Lingkungan | Flavor Android / scheme iOS | Application ID / Bundle ID | Nama aplikasi |
|---|---|---|---|
| Development | `dev` | `id.serbajaya.ecommerce.dev` | Serba Jaya DEV |
| Staging | `staging` | `id.serbajaya.ecommerce.staging` | Serba Jaya STG |
| Production | `prod` | `id.serbajaya.ecommerce` | Serba Jaya |

Ketiga ID tersebut telah disetujui dan diverifikasi melalui varian Gradle serta build settings Xcode. Jangan mengubahnya tanpa persetujuan pemilik produk.

## Menjalankan aplikasi

Pilih konfigurasi VS Code **Serba Jaya — Development**, **Serba Jaya — Staging**, atau **Serba Jaya — Production**. Masing-masing meneruskan flavor dan file define yang sesuai. Perintah terminalnya:

```bash

flutter clean
flutter pub get

flutter run --flavor dev --dart-define-from-file=config/dev.example.json
flutter run --flavor staging --dart-define-from-file=config/staging.example.json
flutter run --flavor prod --dart-define-from-file=config/prod.example.json
```

Nama scheme iOS cocok dengan flavor tersebut. File `*.example.json` berisi konfigurasi aman untuk shell awal tanpa backend. Salin sebagai `config/dev.json`, `config/staging.json`, atau `config/prod.json` untuk pengaturan lokal. File konfigurasi lokal tidak boleh memuat kredensial dan jangan di-commit.

Bootstrap memvalidasi `APP_ENV`, flavor native, dan `APP_DISPLAY_NAME`. Flavor yang hilang atau tidak cocok, nama yang salah, serta nilai environment yang tidak dikenal menghentikan startup. File development tidak dapat digunakan diam-diam sebagai production atau sebaliknya. `APP_DISPLAY_NAME` boleh tidak ditulis, lalu label resmi native digunakan. Base URL kosong menonaktifkan request API.

| Define | Perilaku |
|---|---|
| `APP_ENV` | Wajib. Nilai `dev`, `staging`, atau `prod` dan harus cocok dengan flavor native. |
| `APP_DISPLAY_NAME` | Label resmi sesuai environment. Jika kosong, aplikasi memakai label dari konfigurasi environment. |
| `API_BASE_URL` | Base URL HTTPS tanpa kredensial, query, atau fragmen. Nilai kosong menonaktifkan request. Path dasar diakhiri `/`. |
| `ENABLE_DEBUG_LOGGING` | String `true` atau `false`. Logging selalu nonaktif di production. |

Konfigurasi yang ditanam ke aplikasi dapat dibaca dari artefak. Jangan simpan password, client secret, token, service account, atau private key di define, source, atau repositori. Client ID OAuth bersifat publik, namun hanya dipasang setelah konfigurasi GCP disetujui. Lihat [data pendaftaran OAuth](../integrations/GCP_OAUTH_REGISTRATION.md).
