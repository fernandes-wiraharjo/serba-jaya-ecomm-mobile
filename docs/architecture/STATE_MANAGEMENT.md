# State management dan dependency injection

Riverpod mengomposisi `appConfigProvider`, `appRouterProvider`, `dioProvider`, dan provider storage serta sesi. Environment dipasok oleh bootstrap melalui override. Dio ditutup ketika provider dibuang. GoRouter dipertahankan saat sesi berubah dan disegarkan melalui listener.

`SessionController` menyediakan state immutable `SessionInitializing`, `SessionGuest`, dan `SessionAuthenticated`. Session controller membaca repository, menjalankan validator, dan mengelola timer. Guard mengambil state dan waktu melalui provider. Logout mencabut akses lokal sebelum operasi storage selesai, mengabaikan hasil restoration lama, dan menandai kegagalan penghapusan agar UI dapat menawarkan retry.

Untuk fitur baru, gunakan `Notifier` atau `AsyncNotifier` ketika ada state interaktif. Widget gunakan `ref.watch` untuk state dan `ref.read` untuk aksi. Override provider untuk fake dalam tes. Letakkan wiring lintas fitur di `app/`.

Logout yang masih berjalan memakai satu penghapusan bersama. Restoration tetap diblokir selama controller yang telah mencabut sesi hidup, termasuk saat Riverpod membangun ulang provider.
