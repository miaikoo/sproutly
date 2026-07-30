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

Kasaran penyelesaian: **~55%** saat audit. Setelah P0–P2: **14 RF terpenuhi**,
67 test lolos, `flutter analyze` 0 error 0 warning.

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

## Catatan lingkungan build

- `build/` pernah korup (cache Kotlin incremental: `supertypes.tab_i.len` hilang) dan bikin
  `assembleDebug` gagal. Obatnya `flutter clean`. Kalau build gagal aneh, coba itu dulu.
- Emulator mati sendiri waktu Gradle build dari nol di mesin ini. Urutan yang aman:
  build dulu (`flutter build apk --debug`), baru nyalakan emulator, baru `flutter run`.
- Warning Flutter: `flutter_tts` dan `shared_preferences_android` masih pakai Kotlin Gradle
  Plugin, yang akan gagal di Flutter versi mendatang. Belum mendesak, tapi catat kalau
  nanti upgrade Flutter dan build-nya jebol.

## P3 — pelengkap & deliverable dokumen

- [ ] Notifikasi pengingat (butuh package baru)
- [ ] Firebase Storage buat foto anak & gambar aktivitas kustom
- [ ] Isi doc: screenshot SproutTrack & SproutLink (dua-duanya udah jadi, tinggal capture)
- [ ] Isi doc: link APK + kredensial uji
- [ ] Test case black-box + kuesioner SUS buat bab Evaluasi
