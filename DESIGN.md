# Design system Sprout.ly

Aturan visual yang dipakai app ini. Tulis ini karena tokennya sudah ada tapi
sebagian besar halaman tidak memakainya — 76 `TextStyle` dan 41 warna mentah
ditulis ulang per halaman, banyak di antaranya beda tipis dari token yang sudah
ada (`0xFF446860` vs `teal700` `0xFF446B60`).

## Siapa yang memakai ini

Orang tua anak dengan Autism Spectrum Disorder, di rumah, sering sambil
mendampingi anak yang butuh perhatian penuh. Perangkat utamanya tablet Android
yang ditaruh di meja. Sebagian layar dilihat **anak**, bukan orang tua — dan
untuk anak itu ketenangan bukan preferensi estetis, tapi syarat agar layarnya
bisa dipakai.

Konsekuensinya:

- **Tenang lebih penting daripada menarik.** Satu aksen, tanpa gradien, tanpa
  animasi berulang. Perayaan setelah aktivitas selesai muncul sekali lalu
  berhenti.
- **Target sentuh besar.** Minimum 48dp, diatur di `AppTheme` sekali.
- **Teks jangan tipis.** Tidak ada tier ink yang lebih terang dari
  `textSecondary`; apa pun yang lebih pucat gagal diukur.

## Warna

Ramp warnanya dari Figma dan **tidak diubah**. Yang diubah adalah aturan
pasangannya.

**Masalah yang ditemukan:** teks putih dipasang di atas warna level-500.
Diukur dengan WCAG:

| Pasangan | Rasio | Butuh | Dipakai di |
|---|---|---|---|
| putih di `peach500` | 2.74 | 4.5 | semua tombol utama |
| putih di `teal300` | **1.74** | 4.5 | label bottom nav |
| putih di `olive500` | 2.43 | 4.5 | papan menunggu |
| putih di `cream500` | 1.95 | 4.5 | — |
| `error` = `peach500` | 2.64 | 4.5 | semua pesan gagal simpan |
| `success` = `olive500` | 2.34 | 3.0 | centang selesai |

**Perbaikannya tidak butuh warna baru.** Token level-700 sudah ada dan lulus:
putih di `teal700` 5.82, `peach700` 6.47, `steel700` 6.44, `olive700` 5.67.
Jadi identitasnya utuh, pasangannya yang dibetulkan.

Aturannya sekarang:

| Kebutuhan | Token | Rasio |
|---|---|---|
| Permukaan terisi + teks putih | `actionPrimary` / `actionSecondary` + `onFilled` | 6.47 / 5.82 |
| Kartu bertint + teks | tint 100-level + `onTint` | ≥ 8.5 |
| Teks isi di background | `textPrimary` / `textSecondary` | 10.6 / 5.34 |
| Status sebagai teks | `error` `success` `info` `warning` (700/900) | ≥ 5.47 |
| Garis yang bermakna | `border` | 3.65 |
| Garis hias | `divider` | dikecualikan |

**Jangan** pakai `textSecondary` di atas tint — di `teal100` hasilnya 4.45,
tepat di bawah ambang. Pakai `onTint`.

**`neutral300` diperbaiki.** Sebelumnya `#DCCAD7` — mauve dengan spread 18 di
tengah ramp yang semuanya kehijauan (spread ≤9), dan itu alas **setiap gambar
aktivitas**, jadi seluruh ilustrasi anak duduk di atas kartu pink. Sekarang
`#D6E0DD`, netral sungguhan. Alas gambar punya tokennya sendiri: `imagePlate`.

## Tipografi

**Nunito tidak pernah ada.** Tidak ada `fonts:` di pubspec, tidak ada
`assets/fonts/`. Semua 76 `fontFamily: 'Nunito'` jatuh ke Roboto — sistem
tipografinya cuma dekorasi sejak awal. Nama font hantu itu dihapus daripada
dibiarkan berbohong.

Kalau mau Nunito sungguhan: taruh `.ttf` di `assets/fonts/`, deklarasikan
`fonts:` di pubspec, lalu ubah `AppTextStyles.family` menjadi `'Nunito'`.
Semua style ikut dari satu konstanta itu.

Skalanya rasio ~1.2 (register product: langkah rapat, banyak elemen). Pakai
token, jangan tulis ukuran per halaman.

`caption` 13sp, bukan 12: ini app yang dibaca orang tua satu tangan, dan
caption membawa informasi nyata (jam, hitungan langkah).

## Layout

- `AppSpacing` (grid 8pt). Tidak ada angka lepas.
- Lebar konten dibatasi: 840 halaman biasa, **900 untuk runner** — itu layar
  yang dilihat anak, jadi ia memakai lebar tablet, bukan kolom sempit.
- Grid papan pakai lebar tile tetap (~168) lalu wrap, bukan 3 kolom dipaksa
  melebar. Tablet jadi memuat lebih banyak, bukan meregangkan.
- **Navigasi ikut ukuran** (Material): `BottomNav` di bawah 600dp,
  `SideNav` (rail) di atasnya. Bottom bar ponsel tidak dikirim apa adanya ke
  tablet.
- Aksi utama di luar area scroll. Di runner, tombol dipin sehingga rotasi
  tablet tidak pernah membuatnya tidak terjangkau atau overflow.

## Motion

- 200ms transisi, 320ms untuk perayaan. `Curves.easeOutCubic`.
- **Tidak ada bounce atau elastic.** Overshoot terasa main-main untuk orang
  dewasa dan tidak terduga untuk anak yang sedang menenangkan diri di layar itu.
- **Wajib lewat `AppTheme.motion(context, ...)`**, yang mengembalikan
  `Duration.zero` kalau pengguna menyalakan "Remove animations" di sistem.
  Audiens ini lebih mungkin daripada rata-rata untuk menyalakannya.

## Komponen

Pakai komponen Material, jangan bikin sendiri. Tema di `AppTheme` sudah
mengatur warna, radius, dan tinggi minimum — `FilledButton()` tanpa argumen
apa pun sudah benar.

- `FilledButton` aksi utama, `OutlinedButton` sekunder, `TextButton` tersier.
- `ChoiceChip` untuk filter.
- `SnackBar` untuk umpan balik sesaat, dialog hanya untuk keputusan yang
  memang harus menghentikan.
- `ActivityImage` untuk **semua** gambar aktivitas — ia memilih asset atau
  network sendiri. Ada 15 tempat yang dulu memanggil `Image.asset` langsung;
  semuanya akan crash begitu ada aktivitas kustom berisi URL.
- `BoardTile` untuk papan di grid. Dulu ada dua salinan di Home dan Papan yang
  sudah mulai beda warna dan aspek rasio.

## Empty state

Ajari antarmukanya, jangan bilang "tidak ada apa-apa". Halaman Papan yang
kosong menjelaskan apa itu papan, lalu memberi satu tombol untuk membuatnya.

## Yang belum

- **Tema gelap.** Material menganggapnya first-class dan `AppTheme` baru punya
  `light`. Untuk audiens ini satu palet tenang bisa dipertahankan, tapi ini
  keputusan yang belum diambil, bukan yang sudah diselesaikan.
- **Dynamic Color (Material You).** Sengaja tidak dipakai: warna papan
  membawa makna (jenis papan), jadi tidak boleh ikut wallpaper.
