# Instrumen Evaluasi Usability Sprout.ly

Untuk bab Evaluasi proposal (§7.2). Dua bagian: **task-based usability testing**
(mengukur keberhasilan & waktu) dan **System Usability Scale** (mengukur persepsi).
Responden utama: orang tua/caregiver. Terapis mengisi lembar validasi terpisah (§7.3).

---

## Bagian 1 — Task-Based Usability Testing

Responden diminta menyelesaikan tugas **tanpa dibantu**. Fasilitator mencatat
saja, tidak mengarahkan. Kalau responden menyerah, tandai gagal.

| # | Tugas | Target | Berhasil? | Waktu | Jumlah kesalahan | Catatan |
|---|---|---|---|---|---|---|
| T1 | Daftarkan akun dan profil anak Anda | < 3 menit | | | | |
| T2 | Buat papan jadwal berisi 3 aktivitas rutinitas pagi | < 4 menit | | | | |
| T3 | Jalankan papan itu bersama anak sampai satu aktivitas selesai | < 3 menit | | | | |
| T4 | Buat papan Pertama-Kemudian: mandi dulu, lalu bermain | < 3 menit | | | | |
| T5 | Buat papan emosi untuk saat anak merasa kesal | < 3 menit | | | | |
| T6 | Buat aktivitas baru sendiri beserta langkah-langkahnya | < 4 menit | | | | |
| T7 | Tambahkan hal yang disukai anak ke profilnya | < 2 menit | | | | |
| T8 | Lihat tingkat penyelesaian aktivitas anak minggu ini | < 2 menit | | | | |
| T9 | Hubungkan akun anak dengan terapis pendamping | < 3 menit | | | | |
| T10 | Ubah nama papan yang sudah dibuat | < 2 menit | | | | |

**Metrik yang dihitung:**

- *Task success rate* = tugas berhasil ÷ total tugas × 100%
- *Waktu penyelesaian* rata-rata per tugas
- *Error rate* = jumlah kesalahan ÷ total tugas

Tugas yang gagal atau jauh melewati target menandai titik yang perlu diperbaiki —
catat **di langkah mana** responden tersendat, bukan hanya bahwa ia gagal.

---

## Bagian 2 — System Usability Scale (SUS)

Diisi setelah semua tugas selesai. Skala 1 = sangat tidak setuju,
5 = sangat setuju. **Jangan ubah urutannya** — SUS bergantung pada pola
pernyataan positif dan negatif yang bergantian.

| # | Pernyataan | 1 | 2 | 3 | 4 | 5 |
|---|---|---|---|---|---|---|
| 1 | Saya berpikir akan sering menggunakan aplikasi ini | | | | | |
| 2 | Saya merasa aplikasi ini terlalu rumit | | | | | |
| 3 | Saya merasa aplikasi ini mudah digunakan | | | | | |
| 4 | Saya membutuhkan bantuan orang lain untuk bisa menggunakan aplikasi ini | | | | | |
| 5 | Saya merasa fitur-fitur aplikasi ini berjalan dengan semestinya | | | | | |
| 6 | Saya merasa ada banyak hal yang tidak konsisten dalam aplikasi ini | | | | | |
| 7 | Saya merasa orang lain akan mudah mempelajari aplikasi ini | | | | | |
| 8 | Saya merasa aplikasi ini membingungkan saat digunakan | | | | | |
| 9 | Saya merasa yakin dan nyaman saat menggunakan aplikasi ini | | | | | |
| 10 | Saya perlu belajar banyak hal sebelum bisa menggunakan aplikasi ini | | | | | |

### Cara menghitung skor SUS

1. Pernyataan **ganjil** (1, 3, 5, 7, 9): skor = jawaban − 1
2. Pernyataan **genap** (2, 4, 6, 8, 10): skor = 5 − jawaban
3. Jumlahkan sepuluh skor, lalu **kalikan 2,5**

Hasilnya berada di rentang 0–100. **Ini bukan persentase** — 70 tidak berarti 70%.

### Tafsiran skor

| Skor | Grade | Tafsiran |
|---|---|---|
| > 80,3 | A | Sangat baik |
| 74 – 80,3 | B | Baik |
| 68 – 73,9 | C | Cukup (68 adalah rata-rata industri) |
| 51 – 67,9 | D | Kurang |
| < 51 | F | Buruk, perlu perbaikan besar |

Skor akhir yang dilaporkan adalah **rata-rata skor semua responden**, bukan
rata-rata jawaban per pernyataan lalu dihitung sekali.

---

## Bagian 3 — Pertanyaan terbuka

Tiga pertanyaan ini biasanya menghasilkan temuan paling berguna, karena SUS
hanya memberi angka tanpa alasan.

1. Bagian mana yang paling membingungkan saat Anda mencoba aplikasi ini?
2. Apakah ada hal yang Anda harapkan ada tetapi tidak Anda temukan?
3. Apakah Anda merasa aplikasi ini akan membantu Anda mendampingi anak di rumah?
   Mengapa?

---

## Catatan pelaksanaan

- **Jumlah responden.** Untuk menemukan masalah usability, 5 responden sudah
  mengungkap sebagian besar masalah. Untuk skor SUS yang cukup stabil,
  usahakan ≥ 12 responden. Kalau responden sedikit, laporkan skornya sebagai
  indikasi awal, bukan kesimpulan.
- **Jangan pandu responden.** Begitu fasilitator menunjukkan letak tombol,
  data tugas itu hangus. Biarkan responden tersendat — di situ temuannya.
- **Catat perangkat.** Tablet dan ponsel memberi pengalaman berbeda, terutama
  pada layar rutinitas SproutVoice. Catat jenis dan ukuran layar tiap responden.
- **Fitur SproutGuide perlu API key.** Kalau saat pengujian key belum terpasang,
  tandai tugas terkait AI sebagai tidak diuji — jangan dihitung sebagai gagal.
- **Uji dengan anak, bukan hanya orang tua.** Tugas T3 satu-satunya yang
  melibatkan anak. Amati juga reaksi anak terhadap suara dan gambar; itu tidak
  tertangkap SUS tetapi paling relevan dengan tujuan intervensi.
