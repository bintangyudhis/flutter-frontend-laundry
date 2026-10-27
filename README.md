# Di Laundry - Frontend Flutter

Aplikasi mobile laundry bernama Di Laundry yang dibangun dengan Flutter. Aplikasi ini adalah sisi frontend dari backend laravel-backend-laundry dan mengambil data melalui REST API. Pengerjaan saat ini berada pada tahap fondasi. Model data dan konfigurasi jaringan sudah dibuat, sedangkan halaman antarmuka masih berupa tampilan awal.

## Yang Sudah Ada

- Model data untuk pengguna, toko laundry, promo, dan pesanan laundry dengan konversi JSON
- Konfigurasi permintaan HTTP dan pembacaan respons API
- Penyimpanan sesi login dengan shared preferences
- Kategori status laundry dari Pickup sampai Done dan Delivery
- Pengaturan tema warna dan format tampilan
- Helper navigasi dan penanganan error jaringan

## Teknologi

- Flutter dengan Dart SDK 3.10
- http untuk permintaan API
- shared_preferences untuk penyimpanan sesi
- google_fonts untuk huruf Lato
- intl untuk format tanggal dan angka
- d_method untuk utilitas tambahan

## Cara Instalasi

Prasyarat:

- Flutter SDK 3.10 atau lebih baru
- Backend laravel-backend-laundry yang sedang berjalan

Langkah instalasi:

```bash
git clone https://github.com/bintangyudhis/flutter-frontend-laundry.git
cd flutter-frontend-laundry
flutter pub get
```

Alamat server API diatur pada konstanta `_host` di `lib/config/app_constants.dart`. Nilai bawaan mengarah ke alamat IP lokal pengembang. Sesuaikan dengan alamat komputer yang menjalankan backend sebelum menjalankan aplikasi.

## Cara Menjalankan

Jalankan aplikasi pada emulator atau perangkat yang terhubung:

```bash
flutter run
```

## Lisensi

Proyek ini memakai lisensi MIT. Lihat berkas [LICENSE](LICENSE) untuk teks lengkapnya.
