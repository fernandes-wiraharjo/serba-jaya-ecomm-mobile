# Google Maps dan lokasi alamat

Alur Profil → Alamat Saya → Tambah atau Ubah Alamat → Ubah Lokasi memakai satu form dan satu picker. Rujukan Figma memakai section `232:5155` di Profile `232:5159`. Layar yang dibaca meliputi Alamat Saya `168:2696`, Tambah Alamat `439:1479`, Ubah Alamat `439:1705`, dan Ubah Lokasi `169:3014`. Tidak ditemukan prototype link pada anak section. Navigasi mengikuti label pada frame. Peta dalam form menyediakan ruang 166 px, radius 8, dan CTA pada posisi yang sama. Pin `279:574` serta ikon lokasi `169:3041` diekspor 4× ke WebP lossless. Kartu pilihan pada picker membuka pencarian sebagai sheet karena desain terpisah untuk pencarian tidak ditemukan.

## Aktivasi

1. Aktifkan billing proyek dan **Maps SDK for Android** serta **Maps SDK for iOS** sesuai platform. Gunakan key mobile yang berbeda per platform dan lingkungan.
2. Untuk Android, batasi key ke Maps SDK for Android dan ke pasangan application ID serta SHA-1 sertifikat yang menandatangani APK. Pastikan SHA-1 debug, release, atau Play App Signing sesuai jalur distribusi. Untuk iOS, batasi key ke Maps SDK for iOS serta bundle ID scheme yang sesuai. [Pembatasan Google Maps](https://developers.google.com/maps/api-security-best-practices)
3. Isi `GOOGLE_MAPS_ANDROID_API_KEY` dan/atau `GOOGLE_MAPS_IOS_API_KEY` di `config/dev.json`, `config/staging.json`, atau `config/prod.json`. File lokal ini diabaikan Git. File contoh berisi string kosong. Key mobile tertanam dalam artefak, maka pembatasan Google Cloud tetap diperlukan. Simpan key web service server hanya di backend.
4. Jalankan `flutter devices` dan pilih ID perangkat fisik. Gunakan flavor dan file konfigurasi dari lingkungan yang sama.

```bash
flutter run -d DEVICE_ID --flavor dev --dart-define-from-file=config/dev.json
flutter run -d DEVICE_ID --flavor staging --dart-define-from-file=config/staging.json
flutter run -d DEVICE_ID --flavor prod --dart-define-from-file=config/prod.json
```

| Lingkungan | Application ID / Bundle ID |
|---|---|
| DEV | `id.serbajaya.ecommerce.dev` |
| STAGING | `id.serbajaya.ecommerce.staging` |
| PROD | `id.serbajaya.ecommerce` |

## Native dan izin lokasi

Android membaca `dart-defines` dari build Flutter dan mengisi metadata `com.google.android.geo.API_KEY` melalui manifest placeholder. Pada iOS, provider memanggil `GMSServices.provideAPIKey` lewat channel sebelum view peta dibuat. Kunci kosong atau format tidak valid menonaktifkan view peta. DEV menampilkan petunjuk, sedangkan STAGING dan PROD memakai pesan layanan sementara. Validasi flavor di `AppConfig` tetap berlaku. [Paket Flutter Maps versi proyek](https://pub.dev/packages/google_maps_flutter/versions/2.18.0)

Minimum iOS berubah dari 13 ke 14 karena versi paket Maps yang dipilih. iPhone dengan iOS 13 tidak dapat memasang build baru. Android tetap menggunakan minimum yang ditetapkan Flutter. Android meminta izin coarse/fine dan iOS meminta *When In Use* saat tombol lokasi ditekan. GPS dapat digunakan tanpa Maps key. Lokasi perkiraan tetap dapat dipilih dan ditandai. Izin ditolak permanen dan layanan lokasi mati memberi akses ke pengaturan. Timeout dan gagal GPS menyediakan percobaan ulang lewat tombol lokasi. Peta memerlukan titik yang berasal dari alamat tersimpan, hasil pencarian, atau GPS sebelum aktif. Setelah aktif, pengguna bisa menggeser dan mencubit peta untuk zoom, termasuk saat izin GPS ditolak jika titik awal tersedia.

## Core, backend, dan privasi

`AppGoogleMap`, `AppMapMarker`, dan `AppLocationPicker` berada di `lib/core/location/`. `LocationService`, `LocationPermissionService`, `GeocodingService`, dan `PlacesService` diinjeksikan lewat Riverpod. Koordinat dan komponen alamat bersifat typed. Form menyalin saran ke field kosong atau nilai autofill sebelumnya dan mempertahankan detail yang diketik pengguna. Alamat dan titik baru disimpan di state lokal saat formulir dikonfirmasi.

Reverse geocoding sementara menggunakan layanan sistem melalui paket `geocoding`. Ini dapat menghasilkan isian parsial dan dapat gagal; koordinat tetap tersedia untuk penulisan alamat manual. Pengambilan menunggu kamera idle, memakai debounce, dan membuang respons lama yang dibatalkan. SDK geocoder OS tidak menyediakan pembatalan panggilan yang sudah berjalan. [Dokumentasi geocoding platform](https://pub.dev/packages/geocoding/versions/4.0.0)

Pencarian memiliki antarmuka, loading, kosong, error, pembatalan, penanganan respons terlambat, serta token sesi yang sama untuk autocomplete dan detail pilihan. Implementasi `PlacesService` menunggu endpoint backend. Saat backend tersedia, gunakan Places API (New) dan Geocoding API di backend, klien Dio proyek, serta key server yang dibatasi. Jangan kirim key server ke Flutter. Backend Profile diperlukan untuk penyimpanan alamat lintas perangkat. [Token sesi autocomplete](https://developers.google.com/maps/documentation/places/web-service/place-session-tokens)

Jika peta gagal tampil meski key terisi, periksa billing, API yang aktif, restriction platform, application ID atau bundle ID, dan SHA-1 Android. Build ulang setelah perubahan konfigurasi native. Geocoder OS bisa memasuki batas kuota sistem; pengguna tetap bisa melengkapi alamat manual. Titik hapus saat objek alamat lokal dihapus atau sesi berubah. Hindari mencatat koordinat dan alamat pengguna pada log.

Pengujian live map masih menunggu key. Pencarian Google Places dan Google Geocoding masih menunggu backend. Verifikasi geocoder OS berbeda dari verifikasi Google Geocoding.


## Verifikasi Fisik dan Perbandingan Desain

Figma Desktop Bridge dibaca secara read-only pada Profile `232:5159`, bagian alamat `232:5155`, Daftar Alamat `168:2696`, Tambah `439:1479`, Ubah `439:1705`, dan Pilih Lokasi `169:3014`. Marker `279:574` dan ikon GPS `169:3041` diekspor sebagai WebP lossless. Referensi disimpan pada `docs/verification/figma/maps-*.png`. Frame tambah dan ubah berukuran 390 × 1311. Picker berukuran 390 × 844.

DEV dibangun, dipasang, dan dibuka pada Samsung SM M325FV (Android 13, 1080 × 2400, densitas 450 dpi). Flutter debugger tersambung dan hot reload berhasil. Pada konfigurasi tanpa key, form dan picker terbuka tanpa crash, menampilkan pemberitahuan DEV, tombol pencarian, GPS, dan simpan nonaktif sampai koordinat asli dipilih. Perbandingan dengan Figma memeriksa hierarchy, field, pin, kartu pilihan, header, tombol dan inset pada perangkat. Screenshot fisik [Tambah Alamat tanpa key](../verification/screenshots/address-add-dev-no-key-sm-m325fv.png) dan [Pilih Lokasi tanpa key](../verification/screenshots/location-picker-dev-no-key-sm-m325fv.png). Kartu pencarian dan kontrol native peta mempertahankan slot desain. Peta nyata dan marker atas peta belum bisa dibandingkan tanpa key. Screenshot referensi menampilkan konten alamat contoh dari dokumen desain, sedangkan screenshot aplikasi memakai form kosong.

Setelah hot reload, kabel/perangkat terputus sehingga prompt izin GPS dan alur lokasi fisik tidak sempat diselesaikan. Izin, status approximate, field form, simpan lokal, edit, cancel, dan perubahan state lulus dalam widget test menggunakan layanan lokasi sintetis untuk test saja. Tes ini bukan bukti akses GPS perangkat. iOS diatur ke target minimum 14 sesuai podspec Maps 2.18.0 dan CocoaPods terpasang, tetapi aplikasi iOS belum dibangun atau diuji.
