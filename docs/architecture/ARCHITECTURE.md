# Arsitektur

Aplikasi adalah modular monolith Flutter. Modul memakai Feature-first Clean Architecture dan MVVM pragmatis. Widget merender state dan meneruskan aksi. Controller mengelola state dan berinteraksi dengan kontrak domain. Implementasi data menangani penyimpanan dan transformasi. Composition root di `app/` menyatukan infrastruktur dan fitur.

```mermaid
flowchart TD
  Bootstrap["main / bootstrap"] --> App["App / ProviderScope"]
  App --> Router["GoRouter / shell"]
  Router --> Presentation["Presentasi / widget dan ViewModel"]
  Presentation --> Domain["Domain / entitas dan kontrak"]
  Data["Data / implementasi dan mapping"] --> Domain
  Data --> Core["Core / Dio, error, secure store"]
  App --> Data
  App --> Core
```

Domain tidak mengimpor Flutter, Dio, provider, atau data. `core/` bebas dari fitur. Widget tidak memanggil API atau data source. Gunakan use case ketika ada aturan bermakna atau koordinasi beberapa operasi. Lihat [folder](FOLDER_STRUCTURE.md) dan [ADR](../decisions/).
