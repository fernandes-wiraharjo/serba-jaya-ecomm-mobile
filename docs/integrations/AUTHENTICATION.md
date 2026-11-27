# Autentikasi dan sesi aplikasi

## Fondasi sesi

`SessionRepository` merupakan kontrak domain dan `SecureSessionRepository` menyimpan sesi aplikasi lokal melalui `SecureStore` dengan satu record berversi. Penyimpanan sensitif menggunakan `flutter_secure_storage`. Preferensi biasa dapat menggunakan `SharedPreferencesAsync`. Jangan gunakan preferensi untuk token.

`SessionController` membaca data lokal, mengecek waktu kedaluwarsa, lalu memanggil `SessionValidator`. Validator bawaan menolak karena kontrak backend belum tersedia. Data rusak, kedaluwarsa, atau sesi yang ditolak dihapus. Error saat baca atau validasi membuat pengguna menjadi tamu. Logout menutup akses secara sinkron dan mencoba menghapus record, dengan retry jika penghapusan gagal. Panggilan logout bersamaan memakai satu operasi penghapusan. Selama controller hidup, pembangunan ulang provider tidak dapat mengaktifkan kembali sesi yang dicabut. Guard mencegah akses sebelum sesi tervalidasi. [Alur data](../architecture/DATA_FLOW.md) menjelaskan wiring.

## Google Sign-In dan pertukaran identitas

1. Tombol Google memanggil `signInActionProvider`. Login menampilkan indikator tunggu serta menonaktifkan aksi provider selama proses berlangsung. Provider berbagi satu permintaan Google jika dipanggil bersamaan.
2. `GoogleIdentitySource` memakai konfigurasi dari bootstrap dan membuka pemilih akun melalui SDK. Pembatalan mengembalikan tampilan ke keadaan siap. Konfigurasi, koneksi, dan kegagalan lain ditampilkan melalui pesan lokal tanpa payload error SDK.
3. Hasil pemilih akun tersedia sebagai `GoogleIdentity`, dengan `GoogleRegistrationData` bertipe untuk pemetaan profil registrasi. Pada DEV, hasil tersebut ditampilkan sekali pada `GoogleAccountPreviewPage`; data tidak diambil ulang. Claims dari ID token lokal ditandai belum diverifikasi backend dan token mentah tidak ditampilkan. Preview DEV tidak menulis ke `SessionRepository` atau mengaktifkan sesi melalui `SessionController`.
4. Setelah kontrak ditetapkan, implementasi backend akan menukar ID token melalui HTTPS, lalu memakai hasil tervalidasi untuk mengarahkan pengguna baru ke registrasi atau menyimpan sesi aplikasi pengguna terdaftar melalui repositori yang sama.
5. Setelah sesi aplikasi aktif, GoRouter dapat membuka tujuan yang diizinkan dan Dio menggunakan token akses aplikasi untuk request terlindungi. Backend memeriksa otorisasi setiap operasi.

Token identitas Google tidak digunakan sebagai bearer ecommerce atau disimpan oleh aplikasi. Bahas aturan pertukaran token, registrasi, expiry, refresh, revokasi, dan logout, termasuk kegagalan penghapusan lokal setelah proses dimulai ulang, sebelum mengaktifkan sesi backend. Sign in with Apple masih menggunakan titik integrasi yang sama tanpa SDK Apple. [UI autentikasi](../features/AUTHENTICATION_UI.md) masih memakai formulir registrasi lokal. Firebase Authentication tidak digunakan.

## Identitas aplikasi dan OAuth

Konfigurasi native mempunyai tiga environment. `dev` memakai `id.serbajaya.ecommerce.dev`, `staging` memakai `id.serbajaya.ecommerce.staging`, dan `prod` memakai `id.serbajaya.ecommerce`. Web client ID DEV diberikan untuk konfigurasi lokal dan jenisnya belum dikonfirmasi. Status OAuth native, fingerprint Android, dan signing tersedia di [data pendaftaran GCP](GCP_OAUTH_REGISTRATION.md).
