# Struktur folder

```text
serba_jaya_mobile/
├── android/ dan ios/         proyek native
├── assets/                   images, icons, fonts, animations
├── config/                   contoh dart-define
├── docs/                     kebutuhan, arsitektur, pengembangan, integrasi, fitur, ADR
├── lib/
│   ├── main.dart
│   ├── bootstrap.dart
│   ├── app/                  app.dart, config, router, theme
│   ├── core/                 errors, network, storage
│   ├── features/             auth (data/domain/presentation), home (presentation)
│   ├── shared/widgets/       panel loading, empty, error, retry
│   └── l10n/                 ARB dan output gen-l10n lokal
├── test/                     unit, widget dan fake
├── integration_test/        smoke test perangkat
├── scripts/                  check.sh
├── .github/workflows/        CI format, analyze, test
└── .vscode/                  formatter, ekstensi, launch
```

Rute pengembangan yang belum punya perilaku fitur berada di `app/router/`. Tambah modul hanya ketika mulai mengerjakannya. Lihat [rencana modul](../requirements/TRACEABILITY.md). Dalam fitur, buat subfolder `entities`, `repositories`, `usecases`, `datasources`, `models`, `mappers`, `pages`, `widgets`, `controllers`, `providers`, atau `states` saat jumlah dan tanggung jawab file membutuhkannya. Prinsip yang sama berlaku untuk direktori infrastruktur atau shared tambahan. Folder aset sengaja berisi penanda dan belum didaftarkan ke bundle.
