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
flutter pub get
flutter devices
flutter run -d DEVICE_ID --flavor dev --dart-define-from-file=config/dev.example.json
flutter run -d DEVICE_ID --flavor staging --dart-define-from-file=config/staging.example.json
flutter run -d DEVICE_ID --flavor prod --dart-define-from-file=config/prod.example.json
```

Ganti `DEVICE_ID` dengan ID perangkat fisik. Nama scheme iOS cocok dengan flavor tersebut. File `*.example.json` berisi konfigurasi aman untuk shell awal tanpa backend. Salin sebagai `config/dev.json`, `config/staging.json`, atau `config/prod.json` untuk pengaturan lokal. File konfigurasi lokal dikecualikan oleh Git.

Bootstrap memvalidasi `APP_ENV`, flavor native, dan `APP_DISPLAY_NAME`. Flavor yang hilang atau tidak cocok, nama yang salah, serta nilai environment yang tidak dikenal menghentikan startup. File development tidak dapat digunakan diam-diam sebagai production atau sebaliknya. `APP_DISPLAY_NAME` boleh tidak ditulis, lalu label resmi native digunakan. Base URL kosong menonaktifkan request API.

| Define | Perilaku |
|---|---|
| `APP_ENV` | Wajib. Nilai `dev`, `staging`, atau `prod` dan harus cocok dengan flavor native. |
| `APP_DISPLAY_NAME` | Label resmi sesuai environment. Jika kosong, aplikasi memakai label dari konfigurasi environment. |
| `API_BASE_URL` | Base URL HTTPS tanpa kredensial, query, atau fragmen. Nilai kosong menonaktifkan request. Path dasar diakhiri `/`. |
| `ENABLE_DEBUG_LOGGING` | String `true` atau `false`. Logging selalu nonaktif di production. |
| `GOOGLE_SERVER_CLIENT_ID` | Web OAuth client ID publik untuk environment tersebut. Wajib untuk mencoba Google Sign-In di Android atau iOS. |
| `GOOGLE_IOS_CLIENT_ID` | iOS OAuth client ID publik untuk Bundle ID environment tersebut. Wajib di iOS; Android mengabaikannya. URL scheme iOS perlu didaftarkan secara native. |
| `GOOGLE_MAPS_ANDROID_API_KEY` | Key Maps SDK for Android yang dibatasi ke ID dan sertifikat lingkungan. Kosong menonaktifkan peta Android. |
| `GOOGLE_MAPS_IOS_API_KEY` | Key Maps SDK for iOS yang dibatasi ke Bundle ID lingkungan. Kosong menonaktifkan peta iOS. |

Klien Google yang kosong atau salah format tidak menghentikan startup. Tombol Google memberi pesan konfigurasi saat digunakan. Untuk pengujian OAuth setelah registrasi dikonfirmasi, jalankan flavor DEV dengan `--dart-define-from-file=config/dev.json`. Gunakan ID dari environment yang sesuai untuk staging dan prod.

[Panduan Google Maps dan lokasi](../integrations/GOOGLE_MAPS.md) menjelaskan aktivasi serta pembatasan key.

Konfigurasi yang ditanam ke aplikasi dapat dibaca dari artefak. Jangan simpan password, client secret, token, service account, atau private key di define, source, atau repositori. Lihat [data pendaftaran OAuth](../integrations/GCP_OAUTH_REGISTRATION.md).
