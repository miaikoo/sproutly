import '../../models/enums.dart';

class ActivityCatalogItem {
  final String id;
  final String title;
  final String image;
  final ActivityCategory category;

  const ActivityCatalogItem({
    required this.id,
    required this.title,
    required this.image,
    required this.category,
  });
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
    ),
    ActivityCatalogItem(
      id: 'bermain',
      title: 'Bermain',
      image: 'assets/images/Bermain.png',
      category: ActivityCategory.play,
    ),
    ActivityCatalogItem(
      id: 'makan',
      title: 'Makan',
      image: 'assets/images/Makan.png',
      category: ActivityCategory.meal,
    ),
    ActivityCatalogItem(
      id: 'mandi',
      title: 'Mandi',
      image: 'assets/images/Mandi.png',
      category: ActivityCategory.selfCare,
    ),
    ActivityCatalogItem(
      id: 'memakai_baju',
      title: 'Memakai baju',
      image: 'assets/images/Memakai baju.png',
      category: ActivityCategory.selfCare,
    ),
    ActivityCatalogItem(
      id: 'memakai_sepatu',
      title: 'Memakai sepatu',
      image: 'assets/images/Memakai sepatu.png',
      category: ActivityCategory.selfCare,
    ),
    ActivityCatalogItem(
      id: 'sikat_gigi',
      title: 'Sikat Gigi',
      image: 'assets/images/Sikat Gigi.png',
      category: ActivityCategory.selfCare,
    ),
    ActivityCatalogItem(
      id: 'terapi',
      title: 'Terapi',
      image: 'assets/images/Terapi.png',
      category: ActivityCategory.therapy,
    ),
    ActivityCatalogItem(
      id: 'tidur',
      title: 'Tidur',
      image: 'assets/images/Tidur.png',
      category: ActivityCategory.bedtime,
    ),
  ];

  static ActivityCatalogItem byId(String id) =>
      items.firstWhere((e) => e.id == id, orElse: () => items.first);
}
