# Ongkirin 📦

Kalkulator ongkos kirim domestik Indonesia berbasis Flutter dan RajaOngkir. Ongkirin membantu pengguna memilih lokasi, memasukkan berat paket, membandingkan kurir, lalu melihat estimasi biaya dan waktu pengiriman dari satu alur yang ringkas.

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white)
![Platform](https://img.shields.io/badge/platform-Android%20%7C%20Windows%20%7C%20Web-0F766E)
![Status](https://img.shields.io/badge/status-active%20development-F59E0B)

> 📦 **Ongkirin** membantu membandingkan ongkir, waktu kirim, kurir, dan gambaran rute dalam satu layar yang nyaman dipakai dari HP.

## ✨ Pengalaman utama

| Langkah | Yang dilakukan | Hasil di layar |
| --- | --- | --- |
| 📍 Lokasi | Cari asal dan tujuan atau gunakan lokasi saat ini | Ringkasan rute yang mudah dibaca |
| ⚖️ Paket | Masukkan berat atau gunakan tombol tambah cepat | Berat otomatis tersinkron dengan form |
| 🚚 Kurir | Pilih satu kurir atau bandingkan semua | Layanan tersedia dikumpulkan dalam satu hasil |
| 🧭 Rute | Buka pratinjau Leaflet atau Google Maps | Garis rute, jarak, dan estimasi perjalanan |
| 💡 Pilihan | Gunakan filter semua, termurah, atau tercepat | Kartu hasil diberi konteks yang jelas |

```mermaid
flowchart LR
    A[📍 Asal dan tujuan] --> B[⚖️ Berat paket]
    B --> C[🚚 Pilih kurir]
    C --> D[💰 Hitung ongkir]
    D --> E[📊 Bandingkan hasil]
    E --> F[🧭 Lihat rute]
```

## ✨ Fitur

- Pemilihan asal dan tujuan melalui pencarian lokasi RajaOngkir
- Tombol tukar asal dan tujuan
- Tombol tambah berat `+250 g`, `+500 g`, `+1 kg`, dan `+2 kg`
- Pilihan kurir dan perhitungan estimasi biaya
- Ringkasan pengiriman yang berubah mengikuti input
- Penanda opsi termurah
- Loading, validasi, empty state, timeout, unauthorized, dan server error state
- Proxy Node lokal untuk mengatasi CORS pada Flutter Web
- API key Web disimpan di server proxy, bukan di bundle browser
- Tombol lokasi otomatis dengan fallback pencarian manual
- Rekomendasi tujuan terakhir yang disimpan lokal
- Pratinjau rute Leaflet dan OpenStreetMap di halaman hasil

## 🛣 Alur aplikasi

```mermaid
flowchart LR
    A[📱 Flutter Web atau Mobile] --> B[🧾 Input pengiriman]
    B --> C[🔎 Pencarian lokasi]
    B --> D[🚚 Hitung ongkir]
    C --> E[RajaOngkir API]
    D --> E
    E --> F[✨ Hasil dan opsi termurah]
```

## ⚙ Arsitektur Web

```mermaid
sequenceDiagram
    participant HP as Chrome HP
    participant Flutter as Flutter Web :8080
    participant Proxy as Node Proxy :8787
    participant API as RajaOngkir
    HP->>Flutter: Buka melalui IP komputer
    Flutter->>Proxy: Request lokasi atau ongkir
    Proxy->>API: Request dengan API key server
    API-->>Proxy: Response tarif
    Proxy-->>Flutter: Response dengan CORS lokal
    Flutter-->>HP: Tampilkan hasil
```

### Jalur data rute

```mermaid
sequenceDiagram
    participant UI as Flutter Web
    participant Proxy as Proxy lokal :8787
    participant Geo as Nominatim
    participant Route as OSRM
    UI->>Proxy: Minta titik asal dan tujuan
    Proxy->>Geo: Cari koordinat lokasi
    Geo-->>Proxy: Koordinat dan label
    Proxy->>Route: Hitung rute mobil
    Route-->>Proxy: Geometri, jarak, durasi
    Proxy-->>UI: Data untuk Leaflet
```

## 🚀 Menjalankan secara lokal

### 1. Siapkan API key di proxy

Buat file `proxy/.env` secara lokal. File ini tidak boleh di-commit.

```env
RAJAONGKIR_API_KEY=isi_api_key_rajaongkir
PORT=8787
```

### 2. Jalankan proxy

```powershell
cd proxy
node server.mjs
```

### 3. Preview Web cepat

Buka terminal kedua dari root project. Build release pertama membutuhkan waktu, tetapi halaman berikutnya jauh lebih cepat dibuka.

```powershell
.\tool\serve-web-fast.ps1
```

Setelah tidak ada perubahan pada kode Flutter, jalankan server tanpa build ulang:

```powershell
.\tool\serve-web-fast.ps1 -SkipBuild
```

### Debug Web dengan hot reload

Gunakan mode ini jika sedang mengerjakan perubahan kecil dan membutuhkan hot reload.

```powershell
flutter pub get
flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8080
```

Proxy tetap harus berjalan di terminal lain:

```powershell
node proxy\server.mjs
```

Untuk menguji dari HP, komputer dan HP harus tersambung ke Wi-Fi yang sama. Buka alamat berikut di Chrome HP dengan IP komputer.

```text
http://IP_KOMPUTER:8080
```

Contoh:

```text
http://192.168.1.5:8080
```

Jangan memakai `localhost` atau `127.0.0.1` dari HP.

Browser dapat membatasi geolocation pada alamat HTTP lokal. Jika Chrome meminta HTTPS atau menolak izin lokasi, gunakan pencarian asal manual. Proxy dan kalkulator tetap dapat dipakai tanpa fitur lokasi otomatis.

### Pratinjau rute tanpa API key

Halaman hasil memakai Leaflet untuk tampilan peta, OpenStreetMap untuk tile, Nominatim untuk mencari titik lokasi, dan OSRM untuk menghitung rute mobil. Semua layanan ini dipanggil melalui proxy lokal dan tidak membutuhkan Google Maps API key. Peta menyertakan atribusi OpenStreetMap. Tombol `Buka rute di Google Maps` tetap tersedia untuk navigasi lanjutan.

### Membaca status error API

Pesan `Proxy tidak bisa menghubungi RajaOngkir` menunjuk ke proxy atau koneksi internet lokal. Pesan `API key tidak valid` menunjuk ke kredensial RajaOngkir. Pesan `Kurir atau parameter pengiriman tidak valid` biasanya muncul saat endpoint menolak kombinasi kota, berat, atau kode kurir.

## 🧪 Pemeriksaan kode

```powershell
dart analyze lib test
flutter test --no-pub
node --check proxy/server.mjs
```

Sloth dapat menjalankan pemeriksaan yang sama melalui:

```powershell
.\tool\check.ps1
```

Jika `flutter test` perlu mengunduh package dan jaringan sedang bermasalah, jalankan ulang setelah koneksi ke `pub.dev` tersedia.

## 🔒 Keamanan API key

- API key Web hanya dibaca dari `proxy/.env`.
- `proxy/.env` sudah diabaikan oleh Git.
- Jangan menaruh API key di `lib/`, `web/`, README, screenshot, log, atau prompt.
- Jika key pernah terlihat di screenshot atau chat, revoke dan buat key baru.

## 🛠 Status pengembangan

Ongkirin sedang dikembangkan bertahap dengan fokus pada pengalaman mobile, koneksi Web melalui proxy, lokasi otomatis, riwayat tujuan, dan rekomendasi tujuan yang memiliki dasar data yang jelas.

## 📄 Lisensi dan kontribusi

Project ini dikembangkan untuk kebutuhan pembelajaran dan pengembangan aplikasi. Perubahan sebaiknya melewati analyzer, test yang relevan, dan pengujian melalui entry point aplikasi sebelum digabungkan.
