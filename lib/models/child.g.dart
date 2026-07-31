// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'child.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Child _$ChildFromJson(Map<String, dynamic> json) => Child(
  id: json['id'] as String,
  parentId: json['parentId'] as String,
  name: json['name'] as String,
  birthDate: DateTime.parse(json['birthDate'] as String),
  severity: $enumDecode(_$SeverityEnumMap, json['severity']),
  photoUrl: json['photoUrl'] as String,
  therapistId: json['therapistId'] as String?,
  customActivities:
      (json['customActivities'] as List<dynamic>?)
          ?.map((e) => ActivityCatalogItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  preferences:
      (json['preferences'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      [],
  interventionTargets:
      (json['interventionTargets'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      [],
  points: (json['points'] as num?)?.toInt() ?? 0,
  exp: (json['exp'] as num?)?.toInt() ?? 0,
  unlockedItemIds:
      (json['unlockedItemIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      [],
);

Map<String, dynamic> _$ChildToJson(Child instance) => <String, dynamic>{
  'id': instance.id,
  'parentId': instance.parentId,
  'name': instance.name,
  'birthDate': instance.birthDate.toIso8601String(),
  'severity': _$SeverityEnumMap[instance.severity]!,
  'photoUrl': instance.photoUrl,
  'therapistId': instance.therapistId,
  'customActivities': instance.customActivities.map((e) => e.toJson()).toList(),
  'preferences': instance.preferences,
  'interventionTargets': instance.interventionTargets,
  'points': instance.points,
  'exp': instance.exp,
  'unlockedItemIds': instance.unlockedItemIds,
};

const _$SeverityEnumMap = {
  Severity.mild: 'mild',
  Severity.moderate: 'moderate',
  Severity.severe: 'severe',
};
