# Konfigurasi lingkungan

`APP_ENV` menerima `dev`, `staging`, atau `prod`. Tanpa define aplikasi memulai mode dev. Nilai tidak dikenal gagal validasi. Gunakan file contoh di `config/` dengan `--dart-define-from-file`. Salin ke `config/dev.json`, `staging.json`, atau `prod.json` untuk nilai lokal. VS Code menunjuk ke file contoh secara default.

| Define | Perilaku |
|---|---|
| APP_ENV | Memilih lingkungan; shell placeholder hanya di dev |
| APP_DISPLAY_NAME | Judul aplikasi Flutter; default dari ARB |
| API_BASE_URL | Base URL HTTPS tanpa kredensial, query, atau fragmen. Kosong menonaktifkan request. Path dasar diakhiri garis miring |
| ENABLE_DEBUG_LOGGING | String `true` atau `false`. Produksi selalu nonaktif. Dio hanya menulis tipe kesalahan atau status dalam debug Flutter |

Label peluncur Android dan iOS ditetapkan di berkas native dan sama di ketiga konfigurasi. Native flavor dapat diputuskan ketika perlu side-by-side install atau skema provider yang berbeda. Tidak ada fallback ke URL produksi.

Nilai yang ditanam ke aplikasi dapat dibaca dari artefak. Simpan rahasia dan kunci privat di backend. [GCP OAuth](../integrations/GCP_OAUTH.md) mencatat client ID per lingkungan yang akan dibutuhkan setelah disetujui.
