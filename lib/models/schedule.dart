import 'package:json_annotation/json_annotation.dart';

import 'activity.dart';
import 'enums.dart';

part 'schedule.g.dart';

@JsonSerializable(explicitToJson: true)
class Schedule {
  final String id;

  final String childId;

  final String title;

  final DateTime date;

  /// Which kind of visual support board this is. Defaults to
  /// [BoardType.schedule] so documents written before the field existed still
  /// deserialize.
  @JsonKey(defaultValue: BoardType.schedule)
  final BoardType type;

  final List<Activity> activities;

  /// How long the child waits, in minutes. Only meaningful for
  /// [BoardType.waiting]; null everywhere else.
  final int? waitMinutes;

  const Schedule({
    required this.id,
    required this.childId,
    required this.title,
    required this.date,
    required this.activities,
    this.type = BoardType.schedule,
    this.waitMinutes,
  });

  Schedule copyWith({
    String? title,
    DateTime? date,
    List<Activity>? activities,
    int? waitMinutes,
  }) {
    return Schedule(
      id: id,
      childId: childId,
      title: title ?? this.title,
      date: date ?? this.date,
      type: type,
      activities: activities ?? this.activities,
      waitMinutes: waitMinutes ?? this.waitMinutes,
    );
  }

  factory Schedule.fromJson(Map<String, dynamic> json) =>
      _$ScheduleFromJson(json);

  Map<String, dynamic> toJson() => _$ScheduleToJson(this);
}
