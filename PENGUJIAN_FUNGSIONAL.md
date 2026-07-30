# Pengujian Fungsional Sprout.ly

Skenario uji black-box untuk 14 kebutuhan fungsional. Formatnya sengaja dibuat
sesuai bab Evaluasi di proposal (§7), jadi hasilnya bisa langsung dikutip.

**Cara jalanin:** Android Studio → pilih device → Run. Untuk fitur AI:

```
flutter run --dart-define=OPENROUTER_API_KEY=sk-or-v1-...
```

**Prasyarat:** deploy dulu rules-nya, kalau belum:

```
firebase deploy --only firestore:rules
```

Kolom "Hasil" diisi ✅ / ❌ + catatan.

---

## Manajemen Akun & Profil

| ID | Skenario | Langkah | Hasil diharapkan | Hasil |
|---|---|---|---|---|
| U-01 | Registrasi orang tua (RF-01) | Landing → Daftar → isi data orang tua + nama/tgl lahir/tingkat anak → simpan | Masuk ke Beranda. Di Firebase Console muncul 1 dokumen `users` (role `parent`) dan 1 dokumen `children` | |
| U-02 | Registrasi email ganda (RF-01) | Daftar pakai email yang sudah ada | Pesan "Email sudah terdaftar. Silakan masuk." — bukan error mentah | |
| U-03 | Login (RF-01) | Keluar → masuk pakai akun tadi | Langsung ke Beranda | |
| U-04 | Login salah (RF-01) | Masuk dengan password salah | Pesan "Email atau password salah." | |
| U-05 | **Logout** (RF-01) | Beranda → ikon gear → tekan "Keluar" | Muncul dialog konfirmasi. Tekan Batal → tetap di Pengaturan. Tekan Keluar → balik ke Landing | |
| U-06 | Rute terlindungi (RF-01) | Setelah logout, tekan back | Tidak bisa balik ke Beranda | |
| U-07 | Edit profil anak (RF-02) | Pengaturan → kartu profil → ubah nama | Nama berubah di halaman profil, Beranda, dan Pengaturan | |
| U-08 | Edit sebagian tidak menghapus sisanya (RF-02) | Isi preferensi dulu, lalu ubah nama saja | Preferensi tetap ada setelah nama diubah | |
| U-09 | Preferensi & target intervensi (RF-02) | Profil → + Tambah di kedua bagian | Chip muncul, bisa dihapus, tetap ada setelah keluar-masuk halaman | |
| U-10 | Tanggal lahir & tingkat (RF-02) | Profil → ubah tanggal lahir dan tingkat perkembangan | Umur di kartu profil ikut berubah | |

## SproutPlan — Papan & Aktivitas

| ID | Skenario | Langkah | Hasil diharapkan | Hasil |
|---|---|---|---|---|
| P-01 | Papan jadwal (RF-03) | Papan → + → Aktivitas → Jadwal → isi nama, tambah 3 aktivitas + waktu → simpan | Papan muncul di daftar Papan dan di Beranda | |
| P-02 | Urutan waktu (RF-03) | Buka papan tadi | Aktivitas urut jam, bukan urut input | |
| P-03 | Simpan tanpa aktivitas (RF-03) | Buat papan jadwal, langsung simpan | Pesan "Tambahkan minimal satu aktivitas..." — tidak tersimpan | |
| P-04 | **Papan Pertama-Kemudian** (RF-03) | Papan → + → Aktivitas → Pertama-Kemudian → isi 2 slot → simpan | Tersimpan, muncul di filter "Pertama-Kemudian", urutan slot dipertahankan | |
| P-05 | **Papan Menunggu** (RF-04) | Papan → + → Menunggu → pilih aktivitas, atur timer, pilih min. 1 hadiah → simpan | Tersimpan, muncul di filter "Menunggu", durasi tampil di detail papan | |
| P-06 | Timer bisa diubah (RF-04) | Di papan menunggu, tap lingkaran timer | Pilihan 1/2/3/5/10/15 menit, angka di lingkaran ikut berubah | |
| P-07 | **Papan Emosi** (RF-04) | Papan → + → Emosi → pilih emosi, min. 1 aktivitas menenangkan → simpan | Tersimpan, muncul di filter "Emosi" | |
| P-08 | Slot emosi dikunci (RF-04) | Di papan emosi, tap slot "Ketika aku merasa" | Hanya kartu emosi yang muncul (Bahagia, Kesal, Sedih, dst) — bukan semua aktivitas | |
| P-09 | Validasi papan emosi (RF-04) | Simpan tanpa pilih emosi | Pesan "Pilih dulu emosi yang ingin didampingi." | |
| P-10 | Filter papan (RF-03) | Tekan tiap chip filter di halaman Papan | Hanya papan jenis itu yang tampil; jenis yang kosong kasih pesan, bukan layar blank | |
| P-11 | Kategori picker (RF-05) | Buka picker aktivitas → chip "Emosi", lalu "Menunggu" | Chip Emosi kasih 7 kartu emosi, Menunggu kasih 1 kartu — **bukan semua aktivitas** | |
| P-12 | **Aktivitas kustom** (RF-05) | Picker → Buat Baru → isi nama, ganti gambar, pilih kategori, tambah 2 instruksi → simpan | Muncul di picker bareng preset, dan di halaman Profil | |
| P-13 | Aktivitas kustom tanpa nama (RF-05) | Simpan tanpa isi nama | Pesan "Beri nama aktivitas sebelum menyimpan." | |
| P-14 | Hapus aktivitas kustom (RF-05) | Profil → tekan × di chip aktivitas | Dialog konfirmasi; setelah hapus tidak muncul lagi di picker | |
| P-15 | Ubah nama papan (RF-03) | Detail papan → ⋮ → Ubah nama papan | Nama berubah di detail, daftar Papan, dan Beranda | |
| P-16 | Hapus papan (RF-03) | Detail papan → ⋮ → Hapus papan | Dialog konfirmasi; setelah hapus, keluar dari halaman dan papan hilang dari daftar | |

## SproutVoice — Voice Prompting

| ID | Skenario | Langkah | Hasil diharapkan | Hasil |
|---|---|---|---|---|
| V-01 | **Mulai rutinitas** (RF-06) | Detail papan jadwal → "Mulai bersama anak" | Aktivitas pertama tampil, langkah 1 **dibacakan dengan suara** | |
| V-02 | Instruksi bertahap (RF-06) | Tekan "Langkah berikutnya" berulang | Tiap langkah tampil dan dibacakan satu per satu, penanda "Langkah N dari M" benar | |
| V-03 | Ulangi instruksi (RF-06) | Tekan "Ulangi" | Langkah yang sama dibacakan lagi | |
| V-04 | Mundur satu langkah (RF-06) | Setelah lewat langkah 1, tekan "Kembali ke langkah sebelumnya" | Kembali ke langkah sebelumnya dan dibacakan lagi | |
| V-05 | Aktivitas tanpa instruksi (RF-06) | Jalankan papan berisi aktivitas kustom tanpa instruksi | Suara membacakan "Ayo lakukan \<nama\>." — tidak error, tidak diam | |
| V-06 | **Reinforcement suara + visual** (RF-07) | Di langkah terakhir tekan "Selesai" → pilih mood | Muncul badge + kalimat pujian, **dan pujiannya dibacakan** | |
| V-07 | Reinforcement adaptif (RF-09) | Selesaikan 3 aktivitas dengan mood Senang, lalu 1 lagi | Pujian ke-4 lebih meriah ("Luar biasa!" / 🎉) | |
| V-08 | Reinforcement lembut (RF-09) | Selesaikan aktivitas lalu pilih mood **Sedih** | Pujian jadi lembut (💛 "Sudah berusaha") dan **tidak** bilang "kamu berhasil" | |
| V-09 | Lanjut antar aktivitas (RF-06) | Tekan "Aktivitas berikutnya" sampai habis | Sampai aktivitas terakhir lalu layar "Rutinitas selesai" | |
| V-10 | Hentikan di tengah (RF-06) | Tekan × saat rutinitas jalan → Hentikan | Suara berhenti, keluar halaman, aktivitas yang sudah selesai tetap tersimpan | |
| V-11 | Suara berhenti saat keluar (RF-06) | Saat suara sedang membaca, tekan × | Suara langsung berhenti — tidak lanjut bicara setelah halaman ditutup | |
| V-12 | Papan sudah selesai (RF-06) | Selesaikan semua aktivitas, lalu tekan Mulai lagi | Tombol Mulai hilang, atau muncul "Semua aktivitas sudah selesai" | |

## SproutTrack — Analitik & Laporan

| ID | Skenario | Langkah | Hasil diharapkan | Hasil |
|---|---|---|---|---|
| T-01 | Dashboard (RF-11) | Pengaturan → Perkembangan Anak | Tingkat penyelesaian, sebaran suasana hati, tren harian, riwayat terbaru | |
| T-02 | Belum ada data (RF-11) | Buka analitik dengan akun baru | Pesan "Belum ada aktivitas yang tercatat..." — bukan 0% atau grafik kosong aneh | |
| T-03 | **Rentang waktu** (RF-11) | Tekan chip 7 hari / 30 hari / Semua | Angka dan grafik ikut berubah; judul tren ikut label rentang | |
| T-04 | Data masuk setelah rutinitas (RF-11) | Jalankan rutinitas, lalu buka analitik | Aktivitas yang baru selesai langsung terhitung | |
| T-05 | **Laporan berkala** (RF-12) | Analitik → Lihat Laporan | Dikelompokkan per minggu kalender dengan ringkasan "N dari M selesai" tiap minggu | |
| T-06 | Judul aktivitas di laporan (RF-12) | Lihat baris laporan | Nama aktivitas benar (bukan "Aktivitas" generik) | |

## SproutLink — Kolaborasi

| ID | Skenario | Langkah | Hasil diharapkan | Hasil |
|---|---|---|---|---|
| L-01 | Registrasi terapis (RF-01) | Daftar dengan peran Terapis | Dokumen `users` dengan role `therapist`, tanpa dokumen anak | |
| L-02 | Hubungkan terapis (RF-13) | Login orang tua → Pengaturan → Terapis → isi email terapis | Kartu "Terapis Terhubung" muncul dengan nama terapis | |
| L-03 | Email tidak ditemukan (RF-13) | Isi email yang bukan akun terapis | Pesan "Tidak ditemukan akun terapis dengan email tersebut." | |
| L-04 | **Terapis lihat perkembangan** (RF-13) | Login terapis → Terapis → pilih anak | Tampil dashboard perkembangan anak (angka sama dengan yang dilihat orang tua) + riwayat aktivitas | |
| L-05 | Terapis tulis catatan (RF-13) | Tambah Catatan → isi observasi + rekomendasi | Catatan muncul di daftar | |
| L-06 | **Sinkronisasi** (RF-14) | Tanpa restart, buka akun orang tua | Catatan terapis muncul di sisi orang tua | |
| L-07 | Putuskan hubungan (RF-13) | Sisi orang tua → Putuskan | Kembali ke form hubungkan terapis | |
| L-08 | Isolasi data (RF-14, RNF-04) | Buat akun orang tua kedua | Akun kedua **tidak** bisa melihat papan/log anak dari akun pertama | |

## SproutGuide — perlu API key

| ID | Skenario | Langkah | Hasil diharapkan | Hasil |
|---|---|---|---|---|
| G-01 | Tanpa API key | Buddy → Dapatkan Rekomendasi (key belum diisi) | Pesan jelas "API key SproutGuide belum diisi..." — bukan crash atau error 401 mentah | |
| G-02 | Rekomendasi aktivitas (RF-08) | Isi key → Buddy → Dapatkan Rekomendasi | Kartu aktivitas + alasan + tingkat keyakinan | |
| G-03 | Saran strategi prompting (RF-09) | Lihat kartu rekomendasi | Baris "Saran strategi: ..." tampil | |
| G-04 | Terima rekomendasi (RF-08) | Tekan Tambahkan | Aktivitas masuk ke papan, notifikasi konfirmasi muncul | |
| G-05 | Belum ada papan (RF-08) | Terima rekomendasi tanpa punya papan | Pesan "Buat papan jadwal terlebih dahulu di SproutPlan." | |
| G-06 | Analisis perkembangan (RF-10) | Buddy → Analisis Perkembangan | Ringkasan, kekuatan, hal perlu perhatian, saran periode berikutnya + disclaimer bukan diagnosis | |
| G-07 | Analisis tanpa data (RF-10) | Analisis dengan akun baru | Pesan "Belum ada aktivitas yang tercatat..." | |
| G-08 | Personalisasi (RF-08) | Isi preferensi & target di Profil, lalu minta rekomendasi | Alasan rekomendasi menyinggung preferensi/target tersebut | |

## Non-fungsional & tablet

| ID | Skenario | Langkah | Hasil diharapkan | Hasil |
|---|---|---|---|---|
| N-01 | **Tablet landscape** (RNF-01, RNF-08) | Jalankan rutinitas di tablet posisi landscape | Gambar di kiri, instruksi di kanan; tombol tetap kelihatan | |
| N-02 | **Tablet portrait** (RNF-01) | Putar ke portrait saat rutinitas jalan | Layout jadi bertumpuk, gambar besar di atas | |
| N-03 | **Rotasi tidak overflow** (RNF-01) | Putar-putar di tiap layar runner (langkah, mood, perayaan, selesai) | Tidak ada garis kuning-hitam overflow; kalau sempit jadi bisa di-scroll | |
| N-04 | Ukuran sentuh (RNF-08) | Coba semua tombol di runner pakai jari | Tombol cukup besar dan mudah ditekan | |
| N-05 | Offline sementara (RNF-03) | Matikan internet, tandai aktivitas selesai, nyalakan lagi | Data tidak hilang, tersinkron setelah online | |
| N-06 | Data lama tetap kebaca (RNF-07) | Buka papan yang dibuat sebelum ada jenis papan | Tetap terbaca sebagai papan Jadwal, tidak error | |

---

## Catatan

- **N-06 penting**: papan yang dibuat sebelum field `type` ada akan terbaca sebagai
  papan Jadwal. Sudah ada unit test-nya, tapi perlu dicek juga di data nyata.
- **L-08 penting**: baru berlaku setelah `firebase deploy --only firestore:rules`.
  Sebelum di-deploy, rules lama masih longgar dan akun mana pun bisa baca data siapa pun.
- Kalau papan lama mendadak hilang setelah deploy rules, kemungkinan `childId`-nya
  tidak nyambung ke dokumen `/children` mana pun — rules baru memblokirnya.
- Belum diuji sama sekali di perangkat nyata sampai dokumen ini dibuat. Semua yang
  dilaporkan sejauh ini berasal dari 75 unit test + `flutter analyze`.

---

## Tambahan: Pengingat & Foto

Ditambahkan setelah P3. Butuh deploy `storage.rules` untuk yang berkaitan foto.

| ID | Skenario | Langkah | Hasil diharapkan | Hasil |
|---|---|---|---|---|
| R-01 | Izin notifikasi (RF-06) | Buka app pertama kali di Android 13+ | Muncul permintaan izin notifikasi | |
| R-02 | **Pengingat terjadwal** (RF-06) | Buat papan jadwal dengan aktivitas 2–3 menit dari sekarang, lalu tutup app | Notifikasi muncul kira-kira pada waktu itu (bisa telat beberapa menit — dijadwalkan inexact) | |
| R-03 | Papan non-jadwal tidak berbunyi (RF-06) | Buat papan emosi/menunggu | Tidak ada notifikasi terjadwal untuk papan itu | |
| R-04 | Aktivitas lampau tidak berbunyi (RF-06) | Buat papan dengan waktu yang sudah lewat | Tidak ada notifikasi yang langsung menyala | |
| R-05 | Hapus papan mencabut pengingat (RF-06) | Buat papan dengan pengingat, lalu hapus papannya | Notifikasi tidak muncul lagi | |
| R-06 | Selesai mencabut pengingat (RF-06) | Tandai aktivitas selesai sebelum waktunya | Notifikasi untuk aktivitas itu tidak muncul | |
| R-07 | **Foto anak** (RF-02) | Profil → tap avatar → Ambil foto / Galeri | Foto tampil di avatar dan bertahan setelah keluar-masuk app | |
| R-08 | Ganti foto membersihkan yang lama | Ganti foto dua kali, cek Firebase Storage | Hanya satu file tersisa di `children/{id}/profile/` | |
| R-09 | **Foto aktivitas kustom** (RF-05) | Buat Baru → Ambil Foto / Dari Galeri | Foto tampil di preview, di picker, dan di papan setelah dipakai | |
| R-10 | Foto muncul di runner (RF-05, RF-06) | Jalankan papan berisi aktivitas berfoto | Foto tampil besar di layar runner, bukan ikon rusak | |
| R-11 | Hapus aktivitas membersihkan foto | Hapus aktivitas kustom berfoto, cek Storage | File fotonya ikut terhapus | |
| R-12 | Gambar rusak tidak menjatuhkan papan | Hapus manual file foto di Firebase Console, buka papannya | Muncul ikon "gambar tidak tersedia", papan tetap bisa dipakai | |
| R-13 | Isolasi media (RNF-04) | Login akun orang tua lain, coba buka URL foto anak akun pertama | Ditolak | |
