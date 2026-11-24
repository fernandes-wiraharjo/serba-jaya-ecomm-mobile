# Panduan menambah fitur

1. Ambil aturan dari [pemetaan](../requirements/TRACEABILITY.md) dan selesaikan pertanyaan terbuka yang memengaruhi pekerjaan.
2. Buat folder fitur saat ada implementasi. Definisikan entitas atau kontrak domain bila menambah perilaku bisnis. Buat repository data dan DTO hanya berdasarkan kontrak backend yang disetujui.
3. Gunakan Riverpod untuk wiring serta ViewModel. Render state loading, kosong, hasil, atau error. Simpan teks di ARB dan gunakan tema. Tempatkan widget yang dipakai lintas fitur di `shared/widgets` sesudah pola pakainya jelas.
4. Tambahkan tujuan dan kebijakan akses di router. Tentukan apakah deep link memerlukan guard, serta validasi data pada link. Jangan meneruskan URL mentah ke redirect.
5. Untuk API, gunakan `dioProvider`, tipe response, `CancelToken` bila dibutuhkan, dan `mapNetworkFailure`. Uji dengan override/fake. Pastikan server tetap otoritatif untuk data transaksi.
6. Jalankan pemeriksaan, perbarui traceability, status, dan dokumentasi terkait. Catat keputusan baru dalam ADR bila berdampak lintas fitur.
