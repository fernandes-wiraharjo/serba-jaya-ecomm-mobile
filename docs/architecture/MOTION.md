# Transisi dan animasi aplikasi

`lib/shared/motion/` adalah rujukan untuk animasi navigasi Android dan iOS. `AppMotion` memuat durasi, kurva, dan kebijakan pengurangan gerakan. `MainShell` menempatkan Header dan Bottom Navigation Bar di luar konten yang dianimasikan.

| Gerakan | Durasi | Implementasi |
|---|---|---|
| Halaman standar, termasuk Daftar dan Notifikasi | 350 ms masuk, 300 ms kembali | `AppTransitionPage` memakai slide dan parallax Cupertino. Kurva primernya `fastEaseInToSlowEaseOut` beserta kurva baliknya, dengan gerak sekunder `linearToEaseOut` dan `easeInToLinear`. |
| Login | 350 ms masuk dan keluar | `AppTransitionPage` dengan `AppPageMotion.modal`, slide vertikal `easeOutCubic` saat masuk dan dibalik saat keluar. Login dari dialog ditumpuk di atas layar asal. |
| Pergantian tab | 180 ms | `AppTabTransition` memudarkan konten masuk dengan `easeOut` di atas konten sebelumnya. Stack dan posisi scroll disimpan oleh Navigator per cabang. |
| Dialog | 220 ms masuk, 180 ms keluar | `showAppDialog` memakai fade `easeOut`, skala 0,96 sampai 1,0, dan barrier hitam 40%. Layar asal tetap terpasang. |
| Bottom sheet | 300 ms masuk dan keluar | `showAppBottomSheet` memakai slide Material dengan `Easing.legacyDecelerate` dan progres linear saat drag, barrier hitam 40%, SafeArea, serta inset keyboard. Radius atas diberikan oleh pemanggil dari spesifikasi desain yang terverifikasi. |
| Efek tekan | 110 ms | `AppPressFeedback` memakai `easeOutCubic` dan skala visual 0,97. Area sentuh dan state tombol Material tetap utuh. |

Di iOS, rute standar memakai swipe-back bawaan Cupertino jika ada rute sebelumnya yang dapat dipop. Pada Android yang mendukung predictive back, gesture sistem mengendalikan progres rute aktif secara linear. Atribut manifest mengikuti panduan Flutter. Tombol Back tetap diproses oleh Navigator dan GoRouter. [Panduan predictive back Flutter](https://docs.flutter.dev/platform-integration/android/predictive-back)

## Pemakaian

Definisikan halaman di routing fitur dengan page builder terpusat. Untuk detail di dalam tab, letakkan rute di cabang yang sesuai dan gunakan push atau rute anak yang mempertahankan halaman induk.
Rute pemeriksaan sesi memakai `NoTransitionPage` agar guard tidak menunggu animasi onboarding.

```dart
pageBuilder: (context, state) => AppTransitionPage<void>(
  key: state.pageKey,
  child: const DetailPage(),
),
```

Gunakan helper overlay agar barrier dan durasi konsisten. Isi yang panjang perlu widget scroll di dalam sheet. Hanya pasangkan Hero saat kedua layar dan gambar yang bersesuaian sudah ada.

```dart
await showAppBottomSheet<void>(
  context: context,
  topRadius: verifiedSheetTopRadius,
  builder: (_) => const DetailOptions(),
);

AppHero(
  tag: (source: 'catalog-featured', itemId: product.id),
  child: productImage,
)
```

Kedua ujung Hero memakai tag yang sama dalam Navigator yang sama. Sertakan bagian atau posisi sumber dalam tag jika satu produk muncul beberapa kali di halaman. Aplikasi saat ini belum punya pasangan thumbnail dan detail produk, sehingga belum memasang Hero pada halaman.

## Scroll halaman

`MaterialApp.router` memasang `AppScrollBehavior` dari core. Semua viewport biasa, termasuk formulir, dialog dan sheet, mewarisi `BouncingScrollPhysics` bawaan dengan momentum dan overscroll elastis. Indikator glow dan stretch Android dilepas. Pada viewport pendek tanpa ruang scroll, biarkan konten diam. Untuk `ListView` vertikal yang tidak perlu menjadi scrollable primer, tetapkan `primary: false` agar Flutter tidak menambahkan physics yang selalu menerima drag. Permukaan pull-to-refresh yang harus menerima drag saat isinya pendek dapat memakai `ScrollConfiguration(behavior: const AppScrollBehavior(alwaysScrollable: true), child: ...)`.

Untuk form atau konten statis, gunakan satu viewport yang ukurannya mengikuti layar dan keyboard. Untuk daftar atau grid panjang gunakan builder. Gabungkan beberapa bagian kompleks lewat sliver, dan gunakan scroll horizontal bersumbu lain hanya jika konten memerlukannya. Jangan memanggil animasi per event scroll. Navigasi tab yang sudah ada mempertahankan viewport yang terpasang. Gunakan `PageStorageKey` stabil bila halaman perlu memulihkan posisi setelah viewport dibangun ulang.

Di Profil, judul, identitas, membership, dan menu berada dalam satu viewport. Navbar tetap di shell. Header halaman turunan berada di luar viewport form. Form dapat digulir sampai aksi paling bawah. Keyboard ditutup saat drag pada halaman turunan Profil.

## Aksesibilitas dan performa

- Hormati `MediaQuery.disableAnimations`. Hilangkan animasi pada pengurangan gerakan, termasuk Hero dan efek tekan. Pertahankan fokus, semantics, dan perilaku kembali.
- Biarkan tab yang sudah dikunjungi tetap terpasang dan matikan ticker, fokus, semantics, serta input pada cabang yang tidak aktif. Guard tetap berlaku pada konten terlindungi yang tersimpan atau sedang keluar.
- Gunakan animasi rute dan transisi Flutter, serta satu controller untuk fade cabang. Hindari blur, shader, animasi yang memicu fetch, dan gesture tambahan di atas kontrol Material.
- Ukur kelancaran dan frame time pada perangkat fisik dengan mode profile saat perlu membuat klaim FPS. Tes widget memeriksa state dan posisi saat transisi berlangsung.
