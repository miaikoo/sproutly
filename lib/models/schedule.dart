import 'package:json_annotation/json_annotation.dart';

import 'activity.dart';

part 'schedule.g.dart';

@JsonSerializable(explicitToJson: true)
class Schedule {
  final String id;

  final String childId;

  final DateTime date;

  final List<Activity> activities;

  const Schedule({
    required this.id,
    required this.childId,
    required this.date,
    required this.activities,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) =>
      _$ScheduleFromJson(json);

  Map<String, dynamic> toJson() => _$ScheduleToJson(this);
}