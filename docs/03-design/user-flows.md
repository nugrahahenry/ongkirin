---
title: User Flows and UI State Matrix
document_id: UX-002
version: 1.0
status: Draft
owner: Henry Nugraha
reviewers:
- Diego Adrian Gozali
last_updated: 2026-11-25
related_documents:
- design-system.md
- ../04-technical/api-specification.md
- ../05-quality/acceptance-criteria.md
---

# User Flows

## First run

```text
Buka aplikasi → API key belum ada → Pengaturan API → masukkan key → validasi
  gagal → error dan tetap di form
  berhasil → kembali ke kalkulator
```

## Calculate flow

```text
Pilih asal → pilih tujuan → masukkan berat → pilih kurir → Hitung
  gagal validasi → error di field
  lolos → loading → request API
    sukses dengan data → hasil tarif
    sukses tanpa data → empty state
    401 → API key error
    400 atau 422 → input atau kurir error
    500 atau jaringan → retry state
```

## State matrix

| Area | State | UI dan aksi |
|---|---|---|
| API setup | empty | field key dan petunjuk |
| API setup | validating | tombol loading |
| API setup | valid | success banner dan kembali |
| API setup | invalid | error key dan buka panduan |
| Location | idle | field dengan placeholder |
| Location | loading | skeleton list |
| Location | results | daftar lokasi |
| Location | empty | ubah pencarian |
| Location | error | coba lagi |
| Weight | empty | helper text |
| Weight | invalid | pesan koreksi |
| Calculator | ready | tombol aktif |
| Calculator | loading | progress dan skeleton hasil |
| Calculator | success | daftar tarif |
| Calculator | empty | ubah rute atau kurir |
| Calculator | unauthorized | atur API key |
| Calculator | bad request | periksa input |
| Calculator | server error | coba lagi |
| Calculator | network error | cek koneksi dan retry |

