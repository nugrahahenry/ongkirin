---
title: UI State Matrix
document_id: UX-003
version: 1.0
status: Draft
owner: Henry Nugraha
reviewers:
- Diego Adrian Gozali
last_updated: 2026-11-25
related_documents:
- design-system.md
- user-flows.md
- ../05-quality/acceptance-criteria.md
---

# UI State Matrix

| Area | State | Tampilan | Aksi |
|---|---|---|---|
| API setup | first run | prompt setup key | buka pengaturan |
| API setup | empty | field key dan helper | isi key |
| API setup | validating | tombol loading | tunggu |
| API setup | valid | success banner | kembali |
| API setup | invalid | error dan panduan | perbaiki key |
| Location | idle | field placeholder | buka search sheet |
| Location | loading | skeleton list | tunggu |
| Location | results | daftar lokasi | pilih lokasi |
| Location | empty | lokasi tidak ditemukan | ubah query |
| Location | error | koneksi gagal | coba lagi |
| Weight | empty | helper text | masukkan angka |
| Weight | invalid | error text | perbaiki berat |
| Calculator | ready | tombol hitung aktif | submit |
| Calculator | loading | progress dan skeleton | tunggu |
| Calculator | success | daftar tarif | pilih atau ubah |
| Calculator | empty | tidak ada layanan | ubah rute atau kurir |
| Calculator | unauthorized | key invalid | atur API key |
| Calculator | bad request | parameter invalid | periksa input |
| Calculator | server error | layanan bermasalah | retry |
| Calculator | network error | koneksi gagal | cek koneksi dan retry |

Setiap state memiliki teks, ikon atau indikator, dan aksi yang jelas. Warna tidak menjadi satu-satunya pembeda status.
