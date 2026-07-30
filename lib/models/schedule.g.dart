// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Schedule _$ScheduleFromJson(Map<String, dynamic> json) => Schedule(
  id: json['id'] as String,
  childId: json['childId'] as String,
  title: json['title'] as String,
  date: DateTime.parse(json['date'] as String),
  activities: (json['activities'] as List<dynamic>)
      .map((e) => Activity.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$ScheduleToJson(Schedule instance) => <String, dynamic>{
  'id': instance.id,
  'childId': instance.childId,
  'title': instance.title,
  'date': instance.date.toIso8601String(),
  'activities': instance.activities.map((e) => e.toJson()).toList(),
};
