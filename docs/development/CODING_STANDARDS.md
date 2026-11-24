# Standar kode

- Pakai nama Inggris dan konvensi Dart: `snake_case` file, `PascalCase` tipe, `camelCase` nilai dan fungsi. Gunakan null safety, `const`, state immutable, pola Dart yang mudah dibaca, dan anotasi tipe bila membantu.
- Gunakan fungsi kecil dan hindari nesting, duplikasi, magic number, serta API call dari `build`. Periksa file tulisan tangan di atas 300 baris. Pisahkan menurut tanggung jawab yang nyata.
- Rujuk tema dan ARB untuk nilai tampilan dan teks. Tema Phase 1 bersifat netral dan sementara. Pertahankan SafeArea, dukungan keyboard, text scaling, label aksesibilitas, dan kondisi kosong/error.
- Gunakan `AppFailure` untuk error lintas data dan presentation. Jangan log respons mentah, URI berisi data, header, token, atau data pribadi.
- Jalankan `dart format .` dan `bash scripts/check.sh`. Tambah tes perilaku dan perbarui dokumentasi terkait.
