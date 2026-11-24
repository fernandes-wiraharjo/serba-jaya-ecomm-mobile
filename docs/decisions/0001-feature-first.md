# ADR 0001 — Feature-first Clean Architecture

**Status:** diterima untuk Phase 1.

Gunakan modular monolith dengan layer sesuai kebutuhan fitur dan MVVM pragmatis. Domain berdiri sendiri, data memenuhi kontrak domain, dan ViewModel menyediakan state. Ini mendukung perubahan per fitur dan pengujian terpisah. Hindari packages terpisah dan use case trivial. Tinjau batas modul saat fitur berulang membutuhkan kolaborasi lintas domain.
