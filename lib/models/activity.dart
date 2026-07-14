import 'package:json_annotation/json_annotation.dart';

part 'activity.g.dart';

@JsonSerializable()
class Activity {
  final String id;
  final String title;
  final String icon;

  final String category;

  final DateTime startTime;
  final DateTime endTime;

  final bool completed;

  const Activity({
    required this.id,
    required this.title,
    required this.icon,
    required this.category,
    required this.startTime,
    required this.endTime,
    this.completed = false,
  });

  factory Activity.fromJson(Map<String, dynamic> json) =>
      _$ActivityFromJson(json);

  Map<String, dynamic> toJson() => _$ActivityToJson(this);
}