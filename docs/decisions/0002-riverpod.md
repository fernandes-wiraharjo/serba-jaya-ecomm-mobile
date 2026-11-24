# ADR 0002 — Riverpod

**Status:** diterima untuk Phase 1.

Gunakan Riverpod untuk dependency injection dan state. `Notifier` menangani siklus hidup sesi dan provider override memungkinkan fake. Provider yang memegang resource harus membuang resource itu. Tambahkan generator hanya ketika ada kebutuhan nyata yang mengurangi biaya pemeliharaan.
