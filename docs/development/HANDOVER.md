# Serah terima pengembangan

Mulai dari [ringkasan proyek](../PROJECT_OVERVIEW.md), [status](../PROJECT_STATUS.md), dan [peta kebutuhan](../requirements/TRACEABILITY.md). Proyek mobile mengonsumsi kontrak backend yang akan disetujui bersama tim. Fitur pelanggan dimulai dari shell, dengan login gate, data domain, dan infrastruktur yang siap diuji.

1. Untuk onboarding perangkat, ikuti [Setup](SETUP.md) dan [Environment](ENVIRONMENT.md). Jalankan shell di Android dan iOS dengan konfigurasi dev.
2. Baca [struktur](../architecture/FOLDER_STRUCTURE.md) dan [alur data](../architecture/DATA_FLOW.md) untuk mengikuti `main → bootstrap → app → router`, lalu [Riverpod dan DI](../architecture/STATE_MANAGEMENT.md) untuk override dan state.
3. Gunakan [panduan fitur](FEATURE_DEVELOPMENT_GUIDE.md) untuk menambah fitur, widget bersama, rute, atau integrasi API. [Kontrak API](../integrations/API.md) menjelaskan batas keamanan dan error handling.
4. Jalankan [tes](TESTING.md), [build platform](RELEASE.md), dan baca [troubleshooting](TROUBLESHOOTING.md) jika verifikasi terhambat.
5. Bahas [pertanyaan bisnis dan integrasi](../requirements/OPEN_QUESTIONS.md) sebelum mengembangkan fitur terkait. Gunakan [dokumen autentikasi](../integrations/AUTHENTICATION.md) dan [Figma](../integrations/FIGMA.md) untuk memahami status ketergantungan.

Sebelum mengubah tema atau menambah widget visual final, baca [rencana Design System](../architecture/DESIGN_SYSTEM_PLAN.md) dan [hasil audit fondasi](FOUNDATION_REVIEW.md).
