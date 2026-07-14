// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Activity _$ActivityFromJson(Map<String, dynamic> json) => Activity(
  id: json['id'] as String,
  title: json['title'] as String,
  icon: json['icon'] as String,
  category: $enumDecode(_$ActivityCategoryEnumMap, json['category']),
  startTime: DateTime.parse(json['startTime'] as String),
  endTime: DateTime.parse(json['endTime'] as String),
  completed: json['completed'] as bool? ?? false,
);

Map<String, dynamic> _$ActivityToJson(Activity instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'icon': instance.icon,
  'category': _$ActivityCategoryEnumMap[instance.category]!,
  'startTime': instance.startTime.toIso8601String(),
  'endTime': instance.endTime.toIso8601String(),
  'completed': instance.completed,
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
  ActivityCategory.other: 'other',
};
