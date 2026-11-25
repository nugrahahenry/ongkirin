---
title: Brainstorm and Decisions
document_id: OVR-003
version: 1.0
status: Draft
owner: Henry Nugraha
reviewers:
- Diego Adrian Gozali
- Sloth
last_updated: 2026-11-25
related_documents:
- application-overview.md
- ../01-business/business-requirements.md
- ../03-design/design-system.md
- ../04-technical/architecture.md
---

# Brainstorm and Decisions

## Sudah jelas

1. Aplikasi RajaOngkir dibuat baru dan terpisah.
2. `pengembangan_aplikasi_bergerak_ets` tidak diubah.
3. Repository dan design system baru dibuat khusus kalkulator ongkos kirim.
4. Akun hanya diperlukan untuk mengambil API key RajaOngkir.
5. Aplikasi tidak memiliki login atau registrasi pengguna.
6. MVP menghitung ongkos kirim domestik.

## Keputusan UX

Lokasi dipilih melalui search sheet yang menampilkan nama dan hierarki lokasi. Adapter API menyimpan provider ID sehingga UI tidak terikat pada format JSON.

## Keputusan API key

Untuk tugas kelas, request langsung dari Flutter dipakai agar integrasi REST API terlihat jelas. Key dimasukkan saat runtime dan disimpan melalui secure storage. Untuk produk publik, proxy backend perlu menjadi perubahan arsitektur terpisah.

## Gate sebelum coding

- Pemilik project memiliki akun RajaOngkir.
- API key Shipping Cost tersedia dari akun pemilik project.
- Base URL dan endpoint aktif dikonfirmasi.
- Contoh response sukses dan error tersedia.
- Kurir demo dipilih.

## Pertanyaan yang masih terbuka

- Semua kurir atau satu kurir pilihan untuk demo.
- Android saja atau Android dan web.
- Key lewat form setup atau konfigurasi development.
- Perlu riwayat kalkulasi lokal atau tidak.

