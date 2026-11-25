---
title: Business Requirements and Scope
document_id: BRD-001
version: 1.0
status: Draft
owner: Henry Nugraha
reviewers:
- Diego Adrian Gozali
- Sloth
last_updated: 2026-11-25
related_documents:
- ../00-overview/brainstorm-and-decisions.md
- ../02-product/product-requirements.md
- ../05-quality/acceptance-criteria.md
---

# Business Requirements

Tugas meminta aplikasi mobile yang mengambil data ongkos kirim dari RajaOngkir melalui REST API. Pengguna memasukkan parameter pengiriman dan melihat biaya serta estimasi layanan.

Tujuan akademiknya adalah membuktikan pemahaman model JSON, API service, HTTP request, status response, loading, dan error handling pada Flutter.

| Stakeholder | Kebutuhan |
|---|---|
| Diego atau Sloth | aplikasi berjalan dan mudah didemokan |
| Henry | repository rapi dan dapat menjadi portofolio integrasi API |
| Dosen atau penguji | integrasi REST API dan state handling dapat dilihat |
| Pengguna demo | input jelas dan hasil mudah dibandingkan |

## In scope

API key setup, lokasi asal dan tujuan, berat paket, pilihan kurir, kalkulasi tarif, daftar layanan, harga, estimasi, penanda termurah, retry, validasi, dan dokumentasi handover.

## Out of scope

Login pengguna, pembayaran, pembuatan order, tracking AWB, backend proxy, database server, dashboard admin, push notification, marketplace, dan riwayat permanen.

## Asumsi dan risiko

API key Shipping Cost aktif, request membutuhkan internet, berat dikirim dalam gram, dan endpoint tutorial dapat berbeda dari endpoint akun terbaru. Contract aktual harus diverifikasi sebelum implementasi.

