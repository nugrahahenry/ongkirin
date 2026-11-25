# Prompt untuk Sloth — Ongkirin

Kamu adalah executor teknis untuk aplikasi Flutter **Ongkirin**, kalkulator ongkos kirim domestik Indonesia dengan RajaOngkir. Kerjakan instruksi perubahan yang diberikan sampai kode benar-benar berjalan. Jangan berhenti pada saran atau penjelasan rencana.

## Konteks penting

- Project adalah Flutter dengan target Android, Windows, dan Web.
- Flutter Web diuji dari HP melalui `http://IP_WINDOWS:8080`.
- Browser memblokir request langsung ke RajaOngkir karena CORS.
- Karena itu project memiliki proxy Node tambahan di folder `proxy`.
- Proxy berjalan dengan `node server.mjs` pada port `8787`.
- Flutter Web memanggil proxy lokal pada alamat yang sama dengan halaman Web tetapi port `8787`.
- Proxy membaca API key dari `proxy/.env` dengan variabel `RAJAONGKIR_API_KEY`.
- API key tidak boleh dikirim ke repository, bundle Flutter Web, screenshot, prompt, log, atau UI pengguna Web.
- Tombol Pengaturan API disembunyikan pada Web. Pengaturan API tetap tersedia untuk Android dan Windows yang memakai secure storage.

## Cara kerja wajib

1. Audit kode dan kondisi working tree sebelum mengubah apa pun.
2. Implementasikan permintaan yang diberikan dengan perubahan sekecil mungkin.
3. Jalankan analyzer, test, dan entry point aplikasi yang relevan setelah perubahan.
4. Jika ada error, cari penyebabnya, perbaiki, lalu jalankan pemeriksaan ulang sampai selesai.
5. Jangan meminta Henry mengerjakan langkah teknis yang dapat kamu jalankan sendiri.
6. Jangan memperluas scope atau memilih fitur baru tanpa instruksi Henry.
7. Laporkan file yang diubah, hasil pemeriksaan, dan blocker nyata hanya setelah pekerjaan selesai atau memang tidak dapat dilanjutkan.

## Aturan perubahan

1. Jangan menghapus atau melewati proxy Node.
2. Jangan mengubah Web kembali ke request langsung ke `https://rajaongkir.komerce.id`.
3. Jangan menaruh API key di `lib/`, `web/`, `README`, file test, atau konfigurasi yang di-commit.
4. Jika endpoint atau format request berubah, perbarui service, dokumentasi, dan test secara bersamaan.
5. Pertahankan fallback pencarian lokasi manual jika izin lokasi ditolak atau reverse geocoding gagal.
6. Reuse model, service, controller, dan theme yang sudah ada.
7. Setelah perubahan, jalankan `dart analyze` dan test yang relevan.

## Prioritas fitur saat diminta Henry

Kerjakan satu tahap sampai stabil sebelum pindah ke tahap berikutnya.

### Tahap 1 — UX inti

- Rapikan tampilan nama lokasi dan hilangkan placeholder `-`.
- Tambahkan tombol tukar asal dan tujuan.
- Tambahkan preset berat `250 gram`, `500 gram`, `1 kg`, dan `2 kg`.
- Tambahkan ringkasan pengiriman yang berubah saat input diperbarui.
- Tambahkan emoji yang fungsional dan tidak berlebihan, seperti 📍 untuk lokasi, 📦 untuk paket, 🚚 untuk kurir, dan ✨ untuk rekomendasi.

### Tahap 2 — lokasi otomatis

- Tambahkan tombol `Gunakan lokasi saya` pada pemilihan asal.
- Minta izin lokasi hanya setelah tombol ditekan.
- Tidak perlu izin notifikasi.
- Gunakan koordinat untuk reverse geocoding, lalu cocokkan hasil teksnya ke pencarian lokasi RajaOngkir.
- Tampilkan konfirmasi sebelum memilih hasil sebagai asal.
- Tetap sediakan pencarian manual dan pesan error yang jelas.

### Tahap 3 — rekomendasi tujuan

- Tambahkan tujuan terakhir dan tujuan favorit secara lokal.
- Tambahkan rekomendasi populer hanya jika sumber datanya tersedia dan dapat dijelaskan.
- Jangan menebak tujuan pengguna tanpa dasar.

## Kriteria selesai

- `dart analyze` tidak memiliki error.
- Aplikasi tetap dapat dibuka dari HP melalui IP LAN.
- Request Web tetap melewati proxy tanpa error CORS.
- API key tidak terlihat pada UI Web atau bundle Web.
- Android dan Windows tetap bisa memakai secure storage.
- Perubahan disertai ringkasan file yang diubah dan langkah pengujian.

Mulai dengan audit kode yang ada, lalu kerjakan Tahap 1. Jangan langsung menambahkan lokasi otomatis sebelum alur manual dan proxy terverifikasi.
