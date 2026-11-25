---
title: Getting Started and API Key Setup
document_id: GUIDE-001
version: 1.0
status: Draft
owner: Henry Nugraha
reviewers:
- Diego Adrian Gozali
last_updated: 2026-11-25
related_documents:
- ../06-operations/environment-and-deployment.md
- ../04-technical/api-specification.md
---

# Getting Started

Prerequisites adalah Flutter SDK stable, Android Studio atau perangkat Android, koneksi internet, dan akun RajaOngkir dengan API key Shipping Cost.

## API key setup

1. Buat dan verifikasi akun RajaOngkir.
2. Masuk ke dashboard collaborator.
3. Buka Developer atau Settings.
4. Salin API key Shipping Cost.
5. Masukkan key pada pengaturan aplikasi.
6. Validasi koneksi.

API key diperlakukan seperti password. Jangan menaruhnya di GitHub, screenshot, README, log, atau source code.

## Run

```text
flutter pub get
flutter run
```

Setelah aplikasi terbuka, pilih asal, tujuan, berat, dan kurir. Tekan Hitung Ongkos Kirim untuk melihat layanan yang tersedia.

## Troubleshooting Windows

Jika muncul pesan `Building with plugins requires symlink support`, buka Developer Mode Windows dengan perintah berikut.

```powershell
start ms-settings:developers
```

Aktifkan Developer Mode, tutup dan buka kembali terminal, lalu jalankan `flutter run -d windows`. Preview cepat dapat dijalankan melalui `flutter run -d chrome`.

`flutter upgrade` tidak diperlukan untuk masalah ini. Jangan gunakan `flutter upgrade --force` karena dapat menghapus perubahan lokal pada SDK Flutter.

Jika pencarian lokasi di Chrome menampilkan pesan koneksi diblokir, gunakan Windows atau Android untuk uji API langsung. Chrome hanya dipakai sebagai preview UI karena request lintas domain dapat dibatasi browser.