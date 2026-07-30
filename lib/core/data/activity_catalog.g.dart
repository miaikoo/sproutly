// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_catalog.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ActivityCatalogItem _$ActivityCatalogItemFromJson(Map<String, dynamic> json) =>
    ActivityCatalogItem(
      id: json['id'] as String,
      title: json['title'] as String,
      image: json['image'] as String,
      category: $enumDecode(_$ActivityCategoryEnumMap, json['category']),
      steps:
          (json['steps'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          [],
    );

Map<String, dynamic> _$ActivityCatalogItemToJson(
  ActivityCatalogItem instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'image': instance.image,
  'category': _$ActivityCategoryEnumMap[instance.category]!,
  'steps': instance.steps,
};

const _$ActivityCategoryEnumMap = {
  ActivityCategory.morningRoutine: 'morningRoutine',
  ActivityCategory.selfCare: 'selfCare',
  ActivityCategory.meal: 'meal',
  ActivityCategory.study: 'study',
  ActivityCategory.therapy: 'therapy',
  ActivityCategory.play: 'play',
  ActivityCategory.exercise: 'exercise',
  ActivityCategory.bedtime: 'bedtime',
  ActivityCategory.emotion: 'emotion',
  ActivityCategory.waiting: 'waiting',
  ActivityCategory.other: 'other',
};
