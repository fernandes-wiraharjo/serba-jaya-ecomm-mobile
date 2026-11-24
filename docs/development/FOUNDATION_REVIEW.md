# Audit fondasi — Phase 2

Audit 24 November 2026 di direktori proyek final. Cakupan meliputi kode Dart tulisan tangan, unit/widget/smoke test, konfigurasi native dan CI, dokumentasi, serta kandidat baseline Git. Sumber kebutuhan lokal diverifikasi melalui master prompt, dokumen ruang lingkup, dan traceability.

## Temuan dan koreksi

| Severity | Bukti dan berkas | Koreksi |
|---|---|---|
| HIGH | `session_controller.dart` dapat kembali ke `SessionAuthenticated` saat provider dibangun ulang sebelum penghapusan selesai atau sesudah penghapusan gagal. Dua tes regresi mereproduksi kondisi ini dengan validator yang menerima sesi. | Cabut akses segera, gabungkan pemanggilan logout yang masih berjalan, dan blokir restoration pada controller yang sudah mencabut sesi. Pertahankan status gagal saat provider dibangun ulang agar penghapusan dapat diulang. |
| MEDIUM | `api_client.dart` mengikuti default Dio yang mendekode body respons error. Tes adapter menunjukkan 401 dengan body non-JSON bertipe JSON berubah menjadi `DioException` tanpa status sebelum pemetaan. Hal yang sama dapat terjadi pada status error lain. | Atur `receiveDataWhenStatusError: false` sebagai default agar 401/503 tetap terpetakan. Respons sukses yang tidak valid tetap menjadi `invalidResponse`. |
| LOW | Dua sumber referensi klien di root dan folder requirements sebelumnya masuk kandidat Git. Distribusinya bergantung pada izin repositori yang belum disepakati. | Simpan kedua referensi asli secara lokal dan kecualikan dari baseline. Keterangan pemetaan Markdown tetap tersedia dalam checkout baru. |
| INFORMATIONAL | Data auth mengimplementasikan kontrak domain. Domain independen dari Flutter/Dio. Bootstrap merakit dependensi, ViewModel menangani sesi, router menangani guard, dan widget tidak mengakses API atau penyimpanan langsung. | Tidak ditemukan siklus impor, pelanggaran batas layer, atau kebutuhan refactor tambahan dalam cakupan yang diperiksa. |
| INFORMATIONAL | Provider memulai sumber daya saat dibutuhkan. Timer sesi, router, listener lifecycle, dan Dio memiliki jalur disposal. Log hanya mencatat status atau tipe error. `shared_preferences` tersedia sebagai provider preferensi non-sensitif dan belum digunakan alur UI. | Pertahankan dependensi yang disetujui dan pertahankan lockfile. Belum ada dasar pengukuran untuk optimisasi rebuild atau startup tambahan. |

Tidak ada temuan **CRITICAL** pada cakupan ini. Pemeriksaan kandidat Git menggunakan pola kredensial umum dan tinjauan jenis berkas. Contoh dev/staging/prod memakai URL kosong. Audit ini tidak menguji sistem backend atau keamanan rilis produksi.

## Perilaku yang diperiksa

- Rute terlindungi menunggu inisialisasi. Sesi lokal saja belum cukup, dan sesi kedaluwarsa ditolak oleh guard serta akses token. Tujuan kembali setelah login dibatasi ke path yang terdaftar. Jika secure storage gagal dibaca, aplikasi tetap dalam status tamu.
- Logout menutup akses sepanjang siklus hidup controller. Jika penghapusan persisten gagal, pengguna masih perlu mengulangnya. Sebelum autentikasi nyata, sepakati kontrak revokasi backend dan perilaku setelah proses aplikasi dimulai ulang. Backend tetap berwenang untuk otorisasi.
- Dio membatasi jaringan ke origin HTTPS dan path backend, menghapus header Authorization dari caller, memerlukan tanda eksplisit untuk token, dan menonaktifkan redirect. Koneksi, send, dan receive timeout, pembatalan, multipart, status, dan fallback saat backend belum tersedia diperiksa. Integrasi 401 dengan invalidasi sesi dan token refresh menunggu kontrak backend.
- Android memakai ID serta namespace sementara, JDK 17, minSdk 24 dan target SDK 36. Manifest memakai izin Internet dan mematikan backup aplikasi, sesuai konfigurasi plugin yang dipasang. iOS memakai minimum 13.0, bundle ID sementara, CocoaPods, dan Keychain dengan `unlocked_this_device` tanpa access group bersama. Penyimpanan dan revokasi pada perangkat fisik perlu diuji setelah signing dan akun tes disetujui.
- Tema netral, teks lokal, versi dependensi, dan konfigurasi native dipertahankan. Audit Figma menggunakan catatan baca saja dari Phase 1. [Rencana Design System](../architecture/DESIGN_SYSTEM_PLAN.md) mencatat prasyarat Phase 3.

## Berkas Dart terbesar

| Berkas | Baris | Tanggung jawab |
|---|---:|---|
| `test/core/network_test.dart` | 202 | Adapter fake dan kontrak jaringan. |
| `test/features/session_test.dart` | 178 | Skenario penyimpanan, restoration, kedaluwarsa, dan logout. |
| `lib/features/auth/presentation/session_controller.dart` | 148 | State sesi, transaksi logout, dan timer. |
| `lib/app/router/app_router.dart` | 121 | Shell, daftar rute, guard, dan placeholder dev. |
| `test/app/app_test.dart` | 104 | Tes widget navigasi dan pemilihan tujuan setelah autentikasi. |

Kode hasil generasi dikecualikan. Berkas tetap kohesif dan tidak ada yang melampaui pedoman tinjauan 300 baris.

## Verifikasi dan keterbatasan

Tiga assertion regresi gagal sebelum koreksi. Hasil akhir perintah dari folder final dan riwayat verifikasi native dicatat di [status proyek](../PROJECT_STATUS.md). Android SDK masih memiliki lisensi yang belum diterima. Kapasitas disk tidak cukup untuk mengemas APK multi ABI atau membangun ulang runner iOS dengan aman pada pemeriksaan fase ini. Rilis juga menunggu identifier dan signing resmi, validasi perangkat fisik, dan kontrak pada [pertanyaan terbuka](../requirements/OPEN_QUESTIONS.md).
