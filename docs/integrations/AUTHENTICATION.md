# Autentikasi dan sesi aplikasi

## Fondasi sesi

`SessionRepository` merupakan kontrak domain dan `SecureSessionRepository` menyimpan sesi aplikasi lokal melalui `SecureStore` dengan satu record berversi. Penyimpanan sensitif menggunakan `flutter_secure_storage`. Preferensi biasa dapat menggunakan `SharedPreferencesAsync`. Jangan gunakan preferensi untuk token.

`SessionController` membaca data lokal, mengecek waktu kedaluwarsa, lalu memanggil `SessionValidator`. Validator bawaan menolak karena kontrak backend belum tersedia. Data rusak, kedaluwarsa, atau sesi yang ditolak dihapus. Error saat baca atau validasi membuat pengguna menjadi tamu. Logout menutup akses secara sinkron dan mencoba menghapus record, dengan retry jika penghapusan gagal. Panggilan logout bersamaan memakai satu operasi penghapusan. Selama controller hidup, pembangunan ulang provider tidak dapat mengaktifkan kembali sesi yang dicabut. Guard mencegah akses sebelum sesi tervalidasi. [Alur data](../architecture/DATA_FLOW.md) menjelaskan wiring.

## Usulan integrasi mendatang

1. Pengguna memilih Google (OAuth 2.0 / OpenID Connect di GCP) atau Sign in with Apple.
2. Data source provider memperoleh token identitas. Data source autentikasi backend mengirimkannya melalui kontrak yang disetujui.
3. Backend memvalidasi signature, issuer, audience, expiration, serta nonce sesuai alur provider. Backend menentukan akun dan kebutuhan registrasi.
4. Backend menerbitkan sesi aplikasi. Repository menyimpan token sesi secara aman. Riverpod mengelola state dan GoRouter mengizinkan kelanjutan ke rute yang terdaftar.
5. Dio menggunakan token akses aplikasi untuk request terlindungi. Backend memeriksa otorisasi setiap operasi.

Gunakan data source Google, Apple, backend, dan lokal yang terpisah saat fitur tersedia. Token identitas Google/Apple tidak dipakai sebagai bearer ecommerce. Bahas aturan pertukaran token, registrasi, expiry, refresh, revokasi, dan logout, termasuk kegagalan penghapusan lokal setelah proses dimulai ulang, sebelum mengaktifkan provider. SDK provider, integrasi backend, dan refresh otomatis ditunda. [UI autentikasi](../features/AUTHENTICATION_UI.md) menyediakan titik integrasi untuk Google dan Apple serta formulir registrasi lokal. Firebase Authentication tidak digunakan.

## Identitas aplikasi dan OAuth

Konfigurasi native mempunyai tiga environment dengan ID resmi yang telah diverifikasi: `dev` memakai `id.serbajaya.ecommerce.dev`, `staging` memakai `id.serbajaya.ecommerce.staging`, dan `prod` memakai `id.serbajaya.ecommerce`. Android debug fingerprint lokal dicatat di [data pendaftaran GCP](GCP_OAUTH_REGISTRATION.md). Release signing Android dan Apple Team ID belum dikonfigurasi. Tidak ada client ID atau resource GCP yang dibuat.
