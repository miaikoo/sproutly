import 'package:json_annotation/json_annotation.dart';

import '../../models/enums.dart';

part 'activity_catalog.g.dart';

/// A card the parent can drop onto a board. Doubles as the persisted shape for
/// parent-made activities, which are stored on the child document.
@JsonSerializable()
class ActivityCatalogItem {
  final String id;
  final String title;
  final String image;
  final ActivityCategory category;

  /// Step-by-step instructions SproutVoice reads out one at a time (RF-06).
  /// Empty for cards that aren't a task, such as emotion cards.
  @JsonKey(defaultValue: <String>[])
  final List<String> steps;

  const ActivityCatalogItem({
    required this.id,
    required this.title,
    required this.image,
    required this.category,
    this.steps = const [],
  });

  factory ActivityCatalogItem.fromJson(Map<String, dynamic> json) =>
      _$ActivityCatalogItemFromJson(json);

  Map<String, dynamic> toJson() => _$ActivityCatalogItemToJson(this);
}

/// Preset daily-living activities available when building a schedule board.
class ActivityCatalog {
  ActivityCatalog._();

  static const items = [
    ActivityCatalogItem(
      id: 'belajar',
      title: 'Belajar',
      image: 'assets/images/Belajar.png',
      category: ActivityCategory.study,
      steps: [
        'Duduk di meja belajar.',
        'Siapkan buku dan alat tulis.',
        'Kerjakan satu halaman.',
        'Rapikan kembali buku dan alat tulis.',
      ],
    ),
    ActivityCatalogItem(
      id: 'bermain',
      title: 'Bermain',
      image: 'assets/images/Bermain.png',
      category: ActivityCategory.play,
      steps: [
        'Pilih satu mainan.',
        'Bermain di tempat yang sudah disepakati.',
        'Simpan mainan ke tempatnya setelah selesai.',
      ],
    ),
    ActivityCatalogItem(
      id: 'makan',
      title: 'Makan',
      image: 'assets/images/Makan.png',
      category: ActivityCategory.meal,
      steps: [
        'Cuci tangan sampai bersih.',
        'Duduk di meja makan.',
        'Ambil sendok, lalu makan sedikit-sedikit.',
        'Minum air.',
        'Bawa piring ke tempat cuci.',
      ],
    ),
    ActivityCatalogItem(
      id: 'mandi',
      title: 'Mandi',
      image: 'assets/images/Mandi.png',
      category: ActivityCategory.selfCare,
      steps: [
        'Siapkan handuk dan baju ganti.',
        'Buka pakaian.',
        'Basahi badan dengan air.',
        'Pakai sabun ke seluruh badan.',
        'Bilas sampai tidak ada sabun.',
        'Keringkan badan dengan handuk.',
      ],
    ),
    ActivityCatalogItem(
      id: 'memakai_baju',
      title: 'Memakai baju',
      image: 'assets/images/Memakai baju.png',
      category: ActivityCategory.selfCare,
      steps: [
        'Ambil baju yang sudah disiapkan.',
        'Masukkan kepala ke lubang baju.',
        'Masukkan tangan kanan, lalu tangan kiri.',
        'Tarik baju ke bawah sampai rapi.',
      ],
    ),
    ActivityCatalogItem(
      id: 'memakai_sepatu',
      title: 'Memakai sepatu',
      image: 'assets/images/Memakai sepatu.png',
      category: ActivityCategory.selfCare,
      steps: [
        'Duduk di kursi.',
        'Pakai kaus kaki.',
        'Masukkan kaki kanan ke sepatu kanan.',
        'Masukkan kaki kiri ke sepatu kiri.',
        'Rapatkan perekat atau ikat talinya.',
      ],
    ),
    ActivityCatalogItem(
      id: 'sikat_gigi',
      title: 'Sikat Gigi',
      image: 'assets/images/Sikat Gigi.png',
      category: ActivityCategory.selfCare,
      steps: [
        'Ambil sikat gigi dan pasta gigi.',
        'Beri pasta gigi sedikit saja di sikat.',
        'Sikat gigi depan dengan gerakan memutar.',
        'Sikat gigi samping kanan dan kiri.',
        'Kumur dengan air sampai bersih.',
        'Simpan sikat gigi ke tempatnya.',
      ],
    ),
    ActivityCatalogItem(
      id: 'terapi',
      title: 'Terapi',
      image: 'assets/images/Terapi.png',
      category: ActivityCategory.therapy,
      steps: [
        'Siapkan barang yang dibawa ke terapi.',
        'Duduk bersama terapis.',
        'Ikuti kegiatan sampai selesai.',
      ],
    ),
    ActivityCatalogItem(
      id: 'tidur',
      title: 'Tidur',
      image: 'assets/images/Tidur.png',
      category: ActivityCategory.bedtime,
      steps: [
        'Ganti ke piyama.',
        'Matikan lampu besar.',
        'Berbaring di tempat tidur.',
        'Tutup mata dan tarik napas perlahan.',
      ],
    ),

    // Emotion cards — used by emotion boards ("ketika aku merasa ...").
    ActivityCatalogItem(
      id: 'bahagia',
      title: 'Bahagia',
      image: 'assets/images/Bahagia.png',
      category: ActivityCategory.emotion,
    ),
    ActivityCatalogItem(
      id: 'berpikir',
      title: 'Berpikir',
      image: 'assets/images/Berpikir.png',
      category: ActivityCategory.emotion,
    ),
    ActivityCatalogItem(
      id: 'ceria',
      title: 'Ceria',
      image: 'assets/images/Ceria.png',
      category: ActivityCategory.emotion,
    ),
    ActivityCatalogItem(
      id: 'kesal',
      title: 'Kesal',
      image: 'assets/images/Kesal.png',
      category: ActivityCategory.emotion,
    ),
    ActivityCatalogItem(
      id: 'sedih',
      title: 'Sedih',
      image: 'assets/images/Sedih.png',
      category: ActivityCategory.emotion,
    ),
    ActivityCatalogItem(
      id: 'semangat',
      title: 'Semangat',
      image: 'assets/images/Semangat.png',
      category: ActivityCategory.emotion,
    ),
    ActivityCatalogItem(
      id: 'tenang',
      title: 'Tenang',
      image: 'assets/images/Tenang.png',
      category: ActivityCategory.emotion,
    ),

    ActivityCatalogItem(
      id: 'menunggu',
      title: 'Menunggu',
      image: 'assets/images/Menunggu.png',
      category: ActivityCategory.waiting,
    ),
  ];

  /// Presets plus the parent's own activities, which win on id collision.
  static List<ActivityCatalogItem> allWith(List<ActivityCatalogItem> custom) =>
      [...items, ...custom];

  /// Falls back to the first preset rather than throwing, so a board never
  /// fails to build because a card was renamed or removed.
  static ActivityCatalogItem byId(String id, [List<ActivityCatalogItem> custom = const []]) =>
      allWith(custom).firstWhere((e) => e.id == id, orElse: () => items.first);

  static List<ActivityCatalogItem> byCategory(
    ActivityCategory category, [
    List<ActivityCatalogItem> custom = const [],
  ]) =>
      allWith(custom).where((e) => e.category == category).toList();

  /// Distinct artwork bundled with the app, offered when making a new activity.
  static List<String> get availableImages =>
      {for (final item in items) item.image}.toList();
}
