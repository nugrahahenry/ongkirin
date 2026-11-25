---
title: Acceptance Criteria and Test Cases
document_id: QA-001
version: 1.0
status: Draft
owner: Henry Nugraha
reviewers:
- Diego Adrian Gozali
- Sloth
last_updated: 2026-11-25
related_documents:
- ../02-product/product-requirements.md
- ../03-design/user-flows.md
- ../04-technical/api-specification.md
---

# Acceptance Criteria

- Key dapat dimasukkan dan tidak tampil sebagai plain text setelah disimpan.
- Tombol hitung disabled jika asal, tujuan, berat, atau kurir belum valid.
- Berat kosong, nol, negatif, dan non-numerik ditolak.
- Berat dikirim dalam gram.
- Loading tampil dan request ganda dicegah.
- Hasil sukses menampilkan nama layanan, harga, dan estimasi.
- Harga terendah memiliki label dan pembeda selain warna.
- Data kosong memiliki pesan dan tindakan mengubah input.
- Error 401 membuka pengaturan API.
- Error 400, 422, 500, dan timeout memiliki pesan yang dapat dipulihkan.
- Input tetap ada setelah error jaringan.

## Test cases

| ID | Skenario | Expected |
|---|---|---|
| TC-01 | key kosong | validasi key tampil |
| TC-02 | fixture 401 | error key dan link setup |
| TC-03 | lokasi kosong | field lokasi ditandai |
| TC-04 | berat `0 kg` | input ditolak |
| TC-05 | berat `1 kg` | request memakai `1000` gram |
| TC-06 | fixture 200 dengan data | daftar tarif tampil |
| TC-07 | fixture 200 kosong | empty state tampil |
| TC-08 | fixture 422 | pesan kurir tampil |
| TC-09 | fixture 500 | retry tampil dan input tetap |
| TC-10 | timeout | aplikasi tidak crash |
| TC-11 | tiga tarif | satu opsi ditandai termurah |
| TC-12 | ubah berat | hasil lama diganti setelah sukses |

