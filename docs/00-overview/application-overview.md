---
title: Application Overview
document_id: OVR-001
version: 1.0
status: Draft
owner: Henry Nugraha
reviewers:
- Diego Adrian Gozali
last_updated: 2026-11-25
related_documents:
- document-map.md
- ../01-business/business-requirements.md
- ../02-product/product-requirements.md
---

# Application Overview

- Nama kerja: Ongkirin
- Platform: Flutter mobile
- Tujuan: menghitung estimasi biaya pengiriman domestik
- Pemilik kebutuhan: Diego atau Sloth
- Implementasi: Henry Nugraha
- Sumber tarif: REST API RajaOngkir
- Status: scaffold MVP

Ongkirin menerima asal, tujuan, berat paket, dan kurir. Aplikasi mengirim request ke endpoint kalkulasi RajaOngkir lalu menampilkan layanan, biaya, serta estimasi waktu.

Akun yang dimaksud dalam tugas adalah akun RajaOngkir untuk mendapatkan API key. Aplikasi tidak membuat akun pengguna, tidak mengelola pembayaran, dan tidak membuat transaksi pengiriman.

Repository baru yang diusulkan adalah `rajaongkir-shipping-calculator-flutter`. Repository tersebut dan design system-nya tidak digabung dengan `pengembangan_aplikasi_bergerak_ets`.

