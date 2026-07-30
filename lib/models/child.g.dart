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
);

Map<String, dynamic> _$ChildToJson(Child instance) => <String, dynamic>{
  'id': instance.id,
  'parentId': instance.parentId,
  'name': instance.name,
  'birthDate': instance.birthDate.toIso8601String(),
  'severity': _$SeverityEnumMap[instance.severity]!,
  'photoUrl': instance.photoUrl,
  'therapistId': instance.therapistId,
};

const _$SeverityEnumMap = {
  Severity.mild: 'mild',
  Severity.moderate: 'moderate',
  Severity.severe: 'severe',
};
