# Sprout.ly — Roadmap Penyelesaian

Audit kode `lib/` terhadap 14 kebutuhan fungsional di `[DRAFT] Proposal PPL.docx`.
Tanggal audit: 30 Juli 2026.

## Status saat ini

- `flutter analyze` → 0 error (48 info/warning: import nggak kepake, `withOpacity` deprecated)
- `flutter test` → 13/13 lolos
- Integrasi Firebase (auth, firestore, TTS, AI service, 4 file test) **belum di-commit**, masih di working tree

Alur yang sudah jalan end-to-end:
register/login → buat schedule board → jalankan aktivitas (TTS + catat mood & transisi)
→ analytics → laporan → hubungkan terapis → catatan terapis.

Kasaran penyelesaian: **~55%** saat audit. Setelah P0–P2: **13,5 dari 14 RF**,
75 test lolos, `flutter analyze` 0 error 0 warning.

Koreksi: sempat ditulis "14 RF terpenuhi" — itu kelewat murah hati. RF-06 minta tiga hal
("**pengingat**, instruksi bertahap, dan bantuan verbal"); instruksi bertahap dan bantuan
verbal sudah jalan, tapi **pengingat belum ada** (`notification_service.dart` masih 0 byte).
Ditutup di P3.

## Peta RF-01 → RF-14

| RF | Modul | Status | Yang kurang |
|---|---|---|---|
| 01 | Manajemen akun | 🟡 70% | Tombol "Keluar" mati (`settings_page.dart:351`, nggak ada `onTap`); edit info akun belum ada |
| 02 | Profil anak | 🔴 25% | `profile_page.dart` full mock ('John Doe'/'Jane Doe'); `Child` model nggak punya preferensi & target intervensi |
| 03 | Visual schedule | 🟡 50% | Cuma bisa create — nggak bisa edit/hapus/reorder; First-Then board nggak bisa disimpan |
| 04 | Visual support card | 🔴 10% | Emotion board & Waiting board cuma UI kosong, tombol simpan `print()` doang |
| 05 | Kelola aktivitas | 🟡 40% | Template (`ActivityCatalog`) ✅; aktivitas kustom nggak bisa disimpan (`create_activity_page.dart:82` ikon save mati) |
| 06 | Voice prompting | 🟡 40% | TTS baca judul ✅; "instruksi bertahap" belum ada (`Activity` nggak punya field `steps`); tombol "Mulai" jalanin rutinitas berurutan belum ada (doc §6.2 langkah 2–6); pengingat/notifikasi kosong (`notification_service.dart` 0 byte) |
| 07 | Reinforcement suara | 🟢 90% | Cuma suara, belum ada perayaan visual |
| 08 | Rekomendasi AI | 🟡 85% | Kode lengkap, tapi API key masih placeholder (`api_endpoints.dart:10`) → SproutGuide mati total |
| 09 | Strategi prompting + adaptive reinforcement | 🔴 30% | AI ngasih `recommendedPrompt` tapi nggak pernah dipakai; reinforcement random dari 4 frasa tetap, bukan adaptif |
| 10 | Analisis perkembangan (AI) | 🔴 20% | Belum ada — AI baru bisa rekomendasi aktivitas |
| 11 | Dashboard | 🟢 85% | Belum ada pilih rentang waktu (doc §6.4 langkah 3) |
| 12 | Laporan | 🟡 60% | Masih list flat semua log, belum "berkala"; belum bisa diekspor |
| 13 | Kolaborasi | 🟡 65% | Terapis nggak bisa lihat riwayat aktivitas & analitik anak — doc §6.5 langkah 3 minta itu |
| 14 | Sinkronisasi | 🟡 80% | Realtime ✅ tapi `firestore.rules` bocor: `schedules`/`behaviour_logs`/`therapist_notes` cuma cek `request.auth != null` → user mana pun bisa baca data keluarga lain. Nabrak RNF-04 |

Tambahan di luar tabel: `home_page.dart` seluruhnya mock dan papannya di-random tiap build
(`Random()` di line 224). Ini halaman pertama setelah login, paling keliatan waktu demo.

## P0 — kecil, tapi bikin app keliatan rusak / nggak aman ✅ SELESAI

- [x] Sambungkan tombol Keluar ke `authService.logout()` (+ dialog konfirmasi, karena
      perangkat sering dipegang anak). Nama anak di kartu profil settings juga ikut nyata.
- [x] API key OpenRouter pindah ke `--dart-define=OPENROUTER_API_KEY=...` biar nggak
      ke-commit; `AiService` ngasih pesan jelas kalau key kosong.
      **Masih perlu: tempel key asli waktu run/build.**
- [x] `firestore.rules` diperketat: `schedules`/`behaviour_logs`/`therapist_notes` sekarang
      cek kepemilikan asli via `get()` ke `/children`. **Masih perlu: `firebase deploy --only firestore:rules`.**
- [x] `home_page` → Firestore: sapaan ikut waktu, nama anak asli, kartu "sedang dikerjakan" =
      aktivitas belum selesai paling awal (tappable → activity detail), grid papan asli
      (tappable → board detail), plus empty state.

## P1 — RF yang tombol simpannya kosong ✅ SELESAI

- [x] `Schedule` dapat field `type` (`BoardType`) + `waitMinutes`. Emotion, Waiting, dan
      First-Then board sekarang beneran bisa disimpan, muncul di daftar papan, dan
      dibuka lagi (RF-03, RF-04). Dokumen lama tanpa `type` tetap kebaca sebagai `schedule`.
      Logika bikin papan dipusatkan di `ScheduleService.createBoard` — empat halaman create
      pakai jalur yang sama.
- [x] Katalog dapat 7 kartu emosi + 1 kartu menunggu (asetnya sudah ada tapi belum kepakai).
      Chip 'Menunggu'/'Emosi' di picker tadinya nggak ke-map jadi malah nampilin semua
      aktivitas — sekarang bener. Slot emosi di emotion board dikunci ke kartu emosi.
- [x] Aktivitas kustom bisa disimpan (RF-05) — nama, gambar dari aset bawaan, kategori.
      Disimpan di dokumen `Child` (bukan koleksi baru), muncul di picker bareng preset,
      dan bisa dihapus dari halaman profil.
- [x] `profile_page` → Firestore (RF-02): ubah nama, tanggal lahir, tingkat perkembangan,
      **preferensi**, dan **target intervensi**. Dua field terakhir juga masuk ke prompt
      SproutGuide, plus umur anak — jadi rekomendasi AI lebih nyambung.
      Multi-profil palsu (John/Jane) dibuang; nggak ada di RF mana pun.

Yang sengaja dilewat di sini: upload foto (butuh Firebase Storage → P3),
"Tambah Suara"/"Tambah Video" dan "Verifikasi aktivitas dengan AI" di halaman buat
aktivitas (nggak ada di RF mana pun), durasi default per aktivitas (masih 15 menit).

## P2 — RF setengah jalan ✅ SELESAI

- [x] **Mode "Mulai"** (RF-06, doc §6.2): `run_board_page.dart` menuntun anak satu aktivitas
      satu langkah, tiap langkah dibacakan TTS, ada tombol "Ulangi", bisa mundur satu langkah,
      lalu layar perayaan + catat mood → lanjut otomatis. Urutan run dibekukan saat mulai
      supaya nandain selesai nggak ngacak daftar di tengah rutinitas.
- [x] `Activity.steps` + `ActivityCatalogItem.steps`, plus instruksi nyata untuk 9 aktivitas
      DLS preset. Aktivitas kustom juga bisa diberi instruksi sendiri (doc §6.1 langkah 4).
- [x] **Adaptive reinforcement** (RF-09): `reinforcement_policy.dart` milih level
      gentle/standard/celebratory dari riwayat nyata anak (streak vs kesulitan) dan mood saat
      itu. Fungsi murni, 11 test. Dipakai runner **dan** halaman aktivitas tunggal — sebelumnya
      cuma 4 frasa random. `recommendedPrompt` dari AI sekarang ditampilkan di kartu
      rekomendasi sebagai saran strategi.
- [x] **Terapis lihat perkembangan anak** (RF-13, doc §6.5 langkah 3): panel SproutTrack
      diekstrak ke `child_progress_panel.dart` dan dipakai dua sisi, jadi orang tua dan
      terapis baca angka yang sama.
- [x] **Analisis perkembangan AI** (RF-10): `AiService.analyseProgress` — ringkasan,
      kekuatan, hal yang perlu perhatian, saran periode berikutnya. Prompt-nya dikirim
      teragregasi (bukan log mentah) biar nggak jebol di model gratisan. Ada disclaimer
      "bukan diagnosis" sesuai batasan di proposal.
- [x] **Filter rentang waktu** (RF-11): chip 7 hari / 30 hari / Semua di panel.
      **Laporan berkala** (RF-12): laporan dikelompokkan per minggu kalender dengan
      ringkasan per minggu, bukan lagi satu daftar datar.
- [x] Hapus & ubah nama papan dari menu di board detail (RF-03).

Yang sengaja dilewat: reorder papan drag-and-drop (ubah nama + hapus sudah cukup untuk
"mengubah dan mengatur"); ekspor laporan ke PDF; di runner cuma nanya mood, nggak nanya
tingkat kesulitan transisi (dua pertanyaan per aktivitas terlalu bikin repot di tengah
rutinitas — catat lewat halaman aktivitas tunggal kalau perlu).

## P5 — Selaraskan dengan desain Figma (`ref/`)

Sumber: `ref/color system.html`, `ref/text system.html`, `ref/mock up/*.png`.
Detail lengkap di `DESIGN.md`.

- [x] **Color system** ditranskrip persis: 7 ramp x 10 langkah (50-900).
      Menemukan akar masalah kartu mauve: `neutral300` ditulis `DCCAD7` padahal
      Figma `CCDAD7` — transposisi dua huruf. Bukan keputusan desain, salah ketik.
      `teal700`, `peach500`, `neutral50` juga meleset. Warna mentah di halaman
      justru nilai Figma yang benar.
- [x] **Text system** persis spesifikasi: Display/Heading/Body/Label/Button/Time/Caption.
- [x] **Font Nunito + Nunito Sans diunduh dan di-bundle** sebagai variable font di
      `assets/fonts/`. Sebelumnya tidak pernah ada di project, jadi 76 deklarasi
      `fontFamily: 'Nunito'` diam-diam jatuh ke Roboto.
- [x] **Bottom nav dikembalikan ke bentuk Figma** — bar pil, lingkaran terracotta
      di tab aktif. Dibatasi 520dp supaya di tablet tetap pil. Rail landscape pakai
      kosakata yang sama.
- [x] Tile papan: ilustrasi di kartu putih dalam kotak berwarna, label di tengah.
- [x] Home: kartu "sedang dikerjakan" teal50 bertepi teal200, plat gambar putih.
- [x] Papan Saya: ikon + di header (bukan FAB), chip filter di dalam track pil teal100.
- [x] Buat Papan: kartu opsi teal100 + radio peach, tombol dipin di bawah dengan
      state disabled sesuai desain (peach200).
- [x] `PageHeader` jadi komponen bersama; 13 tombol kembali buatan sendiri diganti
      `IconButton` yang memenuhi target sentuh 48dp.

**Catatan kontras.** Tabel "Kontras & Aksesibilitas" di Figma sudah tidak sinkron
dengan nilai hex-nya: mengklaim "Sage 500 + White = 4.8:1 AA" padahal terukur
2.79. Angka 6.2:1 yang ia tulis justru jatuh tepat di `teal700`. Karena desainnya
menandai semua pasangan itu "AA", perbaikan mengikuti angka yang desainnya sendiri
tetapkan. `peach500 + putih` tetap teks besar saja, sesuai catatan desainnya, dan
tombol disabled `peach200 + putih` dibiarkan apa adanya — WCAG mengecualikan
kontrol disabled.

- [x] **`SlotBox`** jadi komponen bersama untuk kotak slot aktivitas — garis
      putus-putus saat kosong, kartu aktivitas saat terisi. Motif ini ada di semua
      halaman create dan sebelumnya ditulis ulang empat kali dengan ukuran, border,
      dan ikon kosong yang berbeda-beda. Sekarang keempat papan terlihat satu produk,
      dan slot bisa menampilkan aktivitas kustom (sebelumnya `ActivityCatalog.byId`
      dipanggil tanpa daftar kustom, jadi kartu buatan orang tua muncul salah gambar).
- [x] Ikon pensil & simpan di header create pages: 7 `GestureDetector` di bawah
      48dp diganti `IconButton`.
- [x] Label kolom papan jadwal disamakan dengan mockup ("Pertama, aku harus").

### Sisa P5

- [ ] Detail visual halaman create yang belum persis: tombol pil "Tambahkan Kegiatan"
      (mauve) dan tautan "Gunakan Template" di papan jadwal
- [ ] Samakan Profil dan Settings ke mockup
- [ ] Buddy/toko companion — ada mockup `Buddy - toko.png` dan `toko companion.html`,
      fitur toko ini belum ada di aplikasi sama sekali dan tidak ada di RF mana pun.
      Perlu keputusan: bikin, atau abaikan.

## Catatan lingkungan build

- `build/` pernah korup (cache Kotlin incremental: `supertypes.tab_i.len` hilang) dan bikin
  `assembleDebug` gagal. Obatnya `flutter clean`. Kalau build gagal aneh, coba itu dulu.
- Emulator mati sendiri waktu Gradle build dari nol di mesin ini. Urutan yang aman:
  build dulu (`flutter build apk --debug`), baru nyalakan emulator, baru `flutter run`.
- Warning Flutter: `flutter_tts` dan `shared_preferences_android` masih pakai Kotlin Gradle
  Plugin, yang akan gagal di Flutter versi mendatang. Belum mendesak, tapi catat kalau
  nanti upgrade Flutter dan build-nya jebol.

## P3 — pelengkap & deliverable dokumen

- [x] **Notifikasi pengingat** (RF-06, bagian yang tadinya bolong).
      `notification_service.dart` tadinya 0 byte, sekarang jalan: pengingat dijadwalkan
      per aktivitas di papan jadwal. Logikanya fungsi murni (`remindersFor`,
      `remindersForAll`, `notificationId`) dengan 14 test — hanya papan jadwal yang
      dapat pengingat, aktivitas yang sudah lewat atau sudah selesai dilewati.
      Wiring-nya satu tempat (`reminderSyncProvider` di app shell) jadi buat/ubah/hapus
      papan otomatis ke-sync tanpa nambah call site.
      Perlu diketahui: plugin ini **wajib** core library desugaring — sudah ditambahkan
      ke `android/app/build.gradle.kts`, tanpa itu build Android gagal total.
- [x] Test case black-box → `PENGUJIAN_FUNGSIONAL.md` (63 skenario, dipetakan ke RF-01…RF-14
      + RNF, format siap dikutip ke bab Evaluasi §7)
- [x] Instrumen usability → `EVALUASI_USABILITY.md` (10 tugas task-based + kuesioner SUS
      10 pernyataan + cara hitung & tafsir skor, buat §7.2)
- [x] **Firebase Storage** buat foto anak & gambar aktivitas kustom.
      `image_upload_service.dart`: foto dikecilkan ke maks 800px + kualitas 80 sebelum
      diunggah (foto HP mentah beberapa MB padahal cuma ditampilkan di kartu kecil).
      Path-nya `children/{childId}/...` supaya `storage.rules` bisa cek kepemilikan;
      terapis boleh lihat tapi tidak boleh mengubah, dan upload dibatasi 5MB + harus
      `image/*`. Foto lama dihapus saat diganti, dan gambar aktivitas kustom ikut terhapus
      saat kartunya dihapus — kalau tidak, file menumpuk di Storage selamanya.
      `photoUrl` di `Child` sebelumnya selalu kosong, sekarang kepakai.
      **Masih perlu: `firebase deploy --only storage`.**
- [x] `ActivityImage` — satu widget yang otomatis pilih `Image.asset` atau `Image.network`.
      Ada 15 tempat yang render gambar aktivitas pakai `Image.asset`; tanpa widget ini
      semuanya crash begitu ada aktivitas kustom berisi URL. Sekalian dapat indikator
      loading dan penanganan gambar rusak, jadi satu foto gagal tidak menjatuhkan papan.
- [ ] Isi doc: screenshot SproutTrack & SproutLink — **tertunda**, UI masih perlu dirapikan
      dulu (kata user "UI-nya masih busuk"), screenshot sekarang cuma bikin proposal jelek
- [ ] Isi doc: link APK + kredensial uji. Dua-duanya perlu tindakan kamu:
      APK harus diunggah ke tempat yang bisa diakses publik, dan kredensial uji berarti
      membuat akun sungguhan di Firebase project. Aku tidak melakukannya sendiri karena
      keduanya keluar dari mesin ini.
      Catatan: `android/app/build.gradle.kts` masih menandatangani build release dengan
      **kunci debug** (ada `TODO`-nya). Cukup untuk APK demo yang diunduh manual, tapi
      tidak bisa dipakai kalau nanti masuk Play Store.
- [ ] Jalankan `PENGUJIAN_FUNGSIONAL.md` di tablet nyata — **belum pernah dijalankan
      di perangkat sama sekali**, semua klaim sejauh ini dari unit test + analyze

## P4 — Rapikan UI ✅ SELESAI

Ditulis lengkap di `DESIGN.md`. Ringkasnya, dan temuannya lebih berat dari dugaan:

- [x] **Kontras gagal WCAG di seluruh tombol utama.** Teks putih di `peach500` = 2.74:1
      (butuh 4.5). Label bottom nav putih di `teal300` = **1.74:1**. Pesan error
      `peach500` = 2.64:1 — orang tua tidak bisa membaca kenapa simpanannya gagal.
      Perbaikannya **tidak butuh warna baru**: token level-700 sudah ada dan lulus
      (putih di `peach700` 6.47). Identitas Figma utuh, pasangannya yang dibetulkan.
- [x] **`neutral300` ternyata mauve** (`#DCCAD7`, spread 18) di ramp yang semuanya
      kehijauan — dan itu alas setiap gambar aktivitas, jadi seluruh ilustrasi anak
      duduk di kartu pink. Diganti netral sungguhan + token `imagePlate` sendiri.
- [x] **Nunito tidak pernah ada.** Tidak ada `fonts:` di pubspec, tidak ada
      `assets/fonts/`. Semua 76 `fontFamily: 'Nunito'` jatuh ke Roboto sejak awal.
      Nama font hantu dihapus; cara memasang Nunito sungguhan didokumentasikan di
      `AppTextStyles`. (Sempat coba `google_fonts`, dibatalkan: versi 8 menarik
      `jni`/`objective_c`/`code_assets` — native assets, terlalu berisiko.)
- [x] **41 warna mentah dan 62 `TextStyle` hardcode** dipetakan ke token. Sebagian besar
      beda tipis dari token yang sudah ada (`0xFF446860` vs `teal700` `0xFF446B60`) —
      di-eyedrop dari mockup, bukan diambil dari sistem.
- [x] **Bottom nav → Material `NavigationBar`, plus `NavigationRail` di ≥600dp.**
      `android.md` eksplisit: jangan kirim bottom bar ponsel apa adanya ke tablet.
- [x] Target sentuh 48dp minimum, diatur sekali di `AppTheme`.
- [x] Motion menghormati "Remove animations" lewat `AppTheme.motion()` — bukan
      formalitas untuk audiens yang sensitif gerakan.
- [x] Runner: indikator progres visual (segmen aktivitas + titik langkah), karena
      "Langkah 2 dari 6" itu teks yang anak belum tentu bisa baca. Prediktabilitas
      justru inti dari visual schedule.
- [x] Empty state mengajari antarmukanya, bukan bilang "tidak ada apa-apa".
- [x] `ActivityImage` dan `BoardTile` jadi komponen bersama (dulu 15 `Image.asset`
      terpisah dan 2 salinan tile yang sudah mulai beda).
- [x] Label enum diganti bahasa manusia: `meltdown` → "kewalahan", `high` → "sulit".

**`flutter analyze`: No issues found** — dari 48 issue saat audit awal jadi nol.
88 test lolos, build Android sukses.

Belum diputuskan: **tema gelap** (Material menganggapnya first-class, `AppTheme` baru
punya `light`) dan **screenshot §5.5/§5.6** yang sekarang sudah tidak terhalang lagi.
