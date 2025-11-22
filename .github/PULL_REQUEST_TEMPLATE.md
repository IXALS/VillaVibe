## Deskripsi
Mengimplementasikan sistem backend dan UI untuk fitur Favorites (Wishlist). User sekarang bisa menekan tombol "Love" pada kartu Villa untuk menyimpannya ke daftar favorit mereka di database (Firestore). Tombol juga otomatis mendeteksi status login user.

## Issue Terkait
*Sebutkan nomor issue yang diselesaikan oleh PR ini (contoh: Fixes #12, Closes #45).*
Ref: #

## Jenis Perubahan
*Centang opsi yang sesuai dengan memberi tanda 'x' di dalam kurung.*

- [ ] Perbaikan Bug (non-breaking change yang memperbaiki masalah)
- [x] Fitur Baru (non-breaking change yang menambahkan fungsionalitas)
- [ ] Perubahan UI/UX (perubahan visual saja, logika tidak berubah)
- [ ] Breaking Change (fix atau fitur yang mengubah cara kerja fitur lama)
- [ ] Refactoring (perbaikan struktur kode tanpa mengubah fungsi)

## Detail Implementasi
* Membuat FavoriteRepository untuk menangani logika arrayUnion dan arrayRemove pada field savedVillas di Firestore.
* Membuat widget reusable FavoriteButton yang terintegrasi dengan Riverpod (currentUserProvider).
* Mengimplementasikan logika pengecekan autentikasi (jika belum login, akan muncul modal login).
* Mengganti icon statis pada PropertyCard dengan FavoriteButton agar interaktif.

## Bukti Tampilan (Screenshots/Video)
*Wajib dilampirkan jika ada perubahan pada UI/Layout.*

| Sebelum (Before) | Sesudah (After) |
|------------------|-----------------|
| *(Tempel Gambar Disini)* | *(Tempel Gambar Disini)* |

## Cara Testing
*Jelaskan langkah-langkah untuk memverifikasi perubahan ini agar reviewer bisa mencobanya.*

1. Buka halaman...
2. Lakukan aksi...
3. Pastikan hasil yang muncul adalah...

## Checklist
- [x] Kode sudah mengikuti standar penulisan (style guidelines) project ini.
- [x] Saya sudah melakukan self-review terhadap kode saya sendiri.
- [ ] Saya sudah memberikan komentar pada bagian kode yang sulit dipahami.
- [x] Perubahan ini tidak memunculkan error atau warning baru saat di-compile.