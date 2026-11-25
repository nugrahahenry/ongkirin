---
title: Product Requirements, Features, and User Stories
document_id: PRD-001
version: 1.0
status: Draft
owner: Henry Nugraha
reviewers:
- Diego Adrian Gozali
- Sloth
last_updated: 2026-11-25
related_documents:
- ../01-business/business-requirements.md
- ../03-design/user-flows.md
- ../04-technical/api-specification.md
---

# Product Requirements

Ongkirin mengubah parameter pengiriman menjadi pilihan tarif kurir yang mudah dibandingkan.

| ID | Requirement | Prioritas |
|---|---|---|
| FR-01 | Menyediakan halaman kalkulator ongkir. | Must |
| FR-02 | Memilih asal dan tujuan dari data API. | Must |
| FR-03 | Memasukkan berat dalam gram atau kilogram. | Must |
| FR-04 | Memilih kurir yang didukung. | Must |
| FR-05 | Menolak input wajib yang kosong atau invalid. | Must |
| FR-06 | Mengirim request kalkulasi ke RajaOngkir. | Must |
| FR-07 | Menampilkan layanan, harga, dan estimasi. | Must |
| FR-08 | Menandai harga terendah. | Should |
| FR-09 | Mengubah input dan menghitung ulang. | Must |
| FR-10 | Memasukkan atau mengganti API key lokal. | Must |
| FR-11 | Menampilkan error dengan tindakan pemulihan. | Must |

## Feature catalogue

| Feature | Output |
|---|---|
| API setup | status key siap digunakan |
| Location search | provider ID asal dan tujuan |
| Package input | berat dalam gram |
| Courier selector | courier code |
| Cost calculation | daftar pilihan tarif |
| Result comparison | kartu layanan dan penanda termurah |
| Retry and recovery | state pulih tanpa kehilangan input |

## User stories

- Sebagai operator demo, saya ingin memasukkan API key agar aplikasi dapat mengakses RajaOngkir.
- Sebagai pengguna, saya ingin mencari asal dan tujuan agar ID lokasi valid.
- Sebagai pengguna, saya ingin memasukkan berat dan memilih kurir agar tarif sesuai kebutuhan.
- Sebagai pengguna, saya ingin melihat harga dan estimasi agar dapat memilih layanan.
- Sebagai evaluator, saya ingin melihat loading dan error handling agar integrasi API dapat dinilai.

