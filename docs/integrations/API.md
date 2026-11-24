# Fondasi API

`dioProvider` membuat satu Dio per konfigurasi dan menutupnya bersama provider. Tanpa base URL, request ditolak sebelum jaringan. Gunakan path relatif terhadap base URL yang sudah disetujui, `queryParameters`, payload JSON bertipe, `FormData` untuk multipart, dan `CancelToken` untuk operasi yang perlu dibatalkan. Timeout connect 10 detik, send/receive masing-masing 30 detik.

Gunakan `Options(extra: {requiresSession: true})` untuk operasi terlindungi setelah kontraknya tersedia. Interceptor menghapus header Authorization dari caller, menambahkan bearer sesi aktif hanya untuk request bertanda, membatasi tujuan ke origin HTTPS dan path dasar backend, dan menonaktifkan redirect otomatis. TLS tetap diperiksa oleh platform/client standar. Logging dan error untuk UI menghindari URI, payload, dan data pribadi.

Repository menangkap `DioException` dan memakai `mapNetworkFailure`. Decoder repository menangani bentuk DTO yang salah sebagai `invalidResponse`. Mapping menangani koneksi, timeout, cancellation, 401, 403, 5xx, dan error tak dikenal tanpa bergantung pada envelope backend. Secara default Dio melewati decoding body HTTP error agar mapping mempertahankan status, termasuk saat gateway mengirim body non-JSON.

Ada jalur untuk mengaitkan 401 dengan invalidasi sesi setelah semantik backend disepakati. Refresh, replay, dan retry otomatis ditunda. Pembuatan pesanan serta upload bukti bayar tidak boleh direplay tanpa kontrak idempotensi. Upload langsung ke origin lain memerlukan client dan kebijakan tersendiri.

Konfirmasi endpoint, kontrak DTO, error, pagination, aturan otorisasi, dan idempotensi dengan backend. Backend berwenang atas stok, harga, diskon, membership, total, reward, komisi dan verifikasi pembayaran. Kontrak autentikasi dirinci pada [Authentication](AUTHENTICATION.md).
