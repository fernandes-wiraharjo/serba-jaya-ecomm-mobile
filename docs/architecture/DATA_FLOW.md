# Alur data

```mermaid
sequenceDiagram
  participant App as Bootstrap dan router
  participant VM as Riverpod SessionController
  participant Store as SessionRepository dan secure storage
  participant Check as SessionValidator
  App->>VM: Inisialisasi provider
  VM->>Store: Baca sesi lokal
  alt Sesi masih dalam masa berlaku
    VM->>Check: Validasi sesi melalui kontrak
    Check-->>VM: Phase 1 menolak, fake test dapat menerima
  end
  VM-->>App: Guest atau authenticated
  App->>App: Izinkan atau arahkan ulang rute
```

`main.dart` memanggil `bootstrap.dart` untuk parsing environment dan memasang `ProviderScope`. Kesalahan format memunculkan pesan lokal tanpa memulai router. Router berlangganan state sesi dan mengambil keputusan saat rute atau sesi berubah. Kedaluwarsa memicu pencabutan akses melalui timer dan diperiksa lagi saat app resume, saat guard berjalan, serta sebelum injeksi header.

Alur fitur API mendatang adalah View → ViewModel → repository domain → implementasi data → Dio. Repository mengubah DTO menjadi entitas, dan memetakan `DioException` ke `AppFailure`. ViewModel menetapkan state UI, sedangkan widget mengubah kategori error menjadi teks dari ARB. Fitur menentukan kapan retry sesuai operasi.
