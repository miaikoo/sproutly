# Design system Sprout.ly

Aturan visual yang dipakai app ini, ditranskrip dari `ref/color system.html`,
`ref/text system.html`, dan mockup di `ref/mock up/`.

Ditulis karena tokennya sudah ada tapi sebagian besar halaman tidak memakainya:
76 `TextStyle` dan 41 warna mentah ditulis ulang per halaman. Ternyata warna
mentah itu justru nilai Figma yang benar — tokennya yang melenceng.

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
- **Teks jangan tipis.** `textSecondary` Figma hanya lolos untuk teks besar;
  untuk ukuran body pakai `textPrimary`.

## Warna

Sumbernya `ref/color system.html` (Figma). Tujuh ramp x sepuluh langkah (50-900).
Nilai rendah untuk latar & area lembut, nilai tinggi untuk teks & elemen tegas.

**Token di kode sebelumnya melenceng dari Figma.** Yang paling merusak:
`neutral300` ditulis `DCCAD7` padahal Figma `CCDAD7` - transposisi dua huruf
pertama. Itu sebabnya alas setiap gambar aktivitas berwarna mauve. Bukan
keputusan desain, murni salah ketik. `teal700` (`446B60` vs `446860`),
`peach500` (`CA8C6C` vs `C4806C`), dan `neutral50` (`F8F8F4` vs `FAFCFB`) juga
meleset. Ironisnya, warna mentah yang bertebaran di halaman-halaman justru
nilai Figma yang benar; tokennya yang drift.

Sekarang seluruh nilai di `app_colors.dart` sama persis dengan Figma.

Figma memakai `neutral100` untuk kanvas aplikasi dan `neutral50` untuk kartu di
atasnya - itu yang dipakai `background` dan `surface`.

### Kontras: tabel Figma sudah tidak sinkron dengan hex-nya

| Klaim Figma | Kenyataan (diukur) | |
|---|---|---|
| Sage 500 + White = 4.8:1 "AA OK" | teal500 + putih = **2.79** | tak ada ramp yang menghasilkan 4.8 |
| Sage 600 + White = 6.2:1 "AA OK" | teal600 = 3.96 - **teal700 = 6.19** | angkanya menunjuk ke 700, bukan 600 |
| Sage 50 + Neutral 800 = 12.4:1 | sekitar 10.1 | optimistis |
| Blush 500 + White = 3.2:1 "teks besar" | peach500 = **3.16** | akurat, dan jujur menandai batasnya |

Ramp-nya kelihatan pernah di-restep setelah tabel kontras ditulis, dan tabelnya
tidak ikut diperbarui.

**Keputusan:** desainnya menandai semua pasangan itu "AA", jadi niatnya memang
lolos AA. Karena angka 6.2:1 yang ia tuliskan tepat jatuh di `teal700`, itulah
yang dipakai untuk permukaan terisi - bukan mengarang standar baru, melainkan
memenuhi angka yang desainnya sendiri tetapkan. `peach500 + putih` tetap dipakai
**hanya untuk teks besar**, persis seperti catatan desainnya.

Dua pasangan di export layar hampir pasti bug di file Figma-nya, bukan desain:
teks `#FAFCFB` di atas `#D2E8E5` dan di atas `#EECABC`, keduanya sekitar
1.1-1.3:1 alias praktis tak terlihat. Tidak ditiru.

**`textSecondary` Figma (neutral600) hanya 3.29:1.** Untuk teks seukuran body
pakai `textPrimary`; `neutral600` disimpan untuk label besar dan elemen non-teks.

## Tipografi

Sumbernya `ref/text system.html`. Font primer **Nunito** (display, heading,
label, button, angka), sekunder **Nunito Sans** (body dan teks panjang).

**Kedua font itu dulu tidak pernah ada di project.** Tidak ada `fonts:` di
pubspec, tidak ada `assets/fonts/`, jadi 76 deklarasi `fontFamily: 'Nunito'`
diam-diam jatuh ke Roboto. Sekarang keduanya di-bundle sebagai variable font di
`assets/fonts/` - satu file mencakup semua weight, dan tidak butuh jaringan saat
runtime.

Skalanya persis spesifikasi Figma: Display XL/L/M, Heading L/M/S, Body L/M/S,
Label L/M/S, Button L/M/S, Time XL/L, Caption. Pakai token, jangan tulis ukuran
per halaman.

## Layout

- `AppSpacing` (grid 8pt). Tidak ada angka lepas.
- Lebar konten dibatasi: 840 halaman biasa, **900 untuk runner** — itu layar
  yang dilihat anak, jadi ia memakai lebar tablet, bukan kolom sempit.
- Grid papan pakai lebar tile tetap (~168) lalu wrap, bukan 3 kolom dipaksa
  melebar. Tablet jadi memuat lebih banyak, bukan meregangkan.
- **Navigasi ikut ukuran**: bar pil `BottomNav` di bawah 600dp, `SideNav`
  (rail) di atasnya. Bentuknya dari Figma — pil melayang, lingkaran terracotta
  menandai tab aktif — bukan `NavigationBar` Material. Barnya dibatasi 520dp
  supaya di tablet tetap terbaca sebagai pil, bukan pita selebar layar.
  Bar-nya `teal700`, bukan `teal500` seperti mockup: lihat catatan kontras.
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
  sudah mulai beda warna dan aspek rasio. Ilustrasinya duduk di kartu putih di
  dalam kotak berwarna, seperti di mockup — supaya gambar tetap terbaca apa pun
  hue jenis papannya.

## Grafik (SproutTrack)

**Palet ini tidak bisa membawa grafik kategorikal.** Diukur, bukan ditebak:
setiap hue duduk di chroma 0.012–0.092, di bawah ambang 0.10 tempat sebuah
warna berhenti bekerja sebagai identitas. Jadi tidak ada grafik multi-seri di
sini — semuanya sequential (satu hue), ordinal, atau diverging. Kebetulan itu
juga yang diminta syarat "tenang".

**Kosakata diverging** (dipakai untuk suasana hati dan transisi):

| Peran | Token | Kontras vs surface |
|---|---|---|
| Kutub tenang / mudah | `teal700` | 5.61 |
| Titik tengah | `neutral500` (abu sungguhan, spread 2) | 2.47 |
| Kutub sulit / perlu perhatian | `peach700` | 6.24 |

Dua lengannya divalidasi sebagai ramp ordinal — `teal500→teal700` dan
`peach500→peach700` dua-duanya **PASS**: lightness monoton, ΔL ≥ 0.06, ujung
terang lolos ambang kontras. (Level-300 gagal: `teal300` 1.68:1, `peach300`
1.79:1.)

Titik tengahnya 2.47:1, di bawah ambang 3:1 untuk mark. Itu **hanya legal
dengan kanal pemulih**, jadi setiap diverging bar di sini wajib membawa label
segmen yang terlihat **dan** legenda — dan untuk suasana hati, daftar hitungan
per-mood di bawahnya berfungsi sebagai table view. Jangan hapus salah satunya.

**Kutub sulit sengaja peach, bukan merah alarm.** Ini informasi untuk orang
tua, bukan vonis atas anaknya.

**Bar magnitude satu warna.** Aktivitas itu kategori nominal — mewarnai tiap
bar sesuai nilainya akan menghabiskan kanal identitas untuk mengulang apa yang
sudah dikatakan panjang bar.

Aturan lain yang dipakai: mark tipis, jarak 2px antar segmen (bukan garis tepi),
label hanya dirender di dalam segmen kalau muat, tinggi kontainer sudah termasuk
pita sumbu (supaya kartunya tidak menumbuhkan scroll sendiri), angka proporsional
untuk figur besar dan `tabularFigures` hanya untuk kolom yang berbaris.

Statistiknya ada di `progress_stats.dart` sebagai fungsi murni dengan 20 test —
angka yang dibaca orang tua dan terapis tidak boleh hanya "kelihatannya benar".

## Empty state

Ajari antarmukanya, jangan bilang "tidak ada apa-apa". Halaman Papan yang
kosong menjelaskan apa itu papan, lalu memberi satu tombol untuk membuatnya.

## Yang belum

- **Tema gelap.** Material menganggapnya first-class dan `AppTheme` baru punya
  `light`. Untuk audiens ini satu palet tenang bisa dipertahankan, tapi ini
  keputusan yang belum diambil, bukan yang sudah diselesaikan.
- **Dynamic Color (Material You).** Sengaja tidak dipakai: warna papan
  membawa makna (jenis papan), jadi tidak boleh ikut wallpaper.
