import 'package:json_annotation/json_annotation.dart';
import 'enums.dart';

part 'activity.g.dart';

@JsonSerializable()
class Activity {
  final String id;
  final String title;
  final String icon;

  final ActivityCategory category;

  final DateTime startTime;
  final DateTime endTime;

  final bool completed;

  /// Copied from the catalog when the board is built, so editing a catalog card
  /// later never rewrites the instructions a child is already used to.
  @JsonKey(defaultValue: <String>[])
  final List<String> steps;

  const Activity({
    required this.id,
    required this.title,
    required this.icon,
    required this.category,
    required this.startTime,
    required this.endTime,
    this.completed = false,
    this.steps = const [],
  });

  Activity copyWith({bool? completed}) => Activity(
        id: id,
        title: title,
        icon: icon,
        category: category,
        startTime: startTime,
        endTime: endTime,
        completed: completed ?? this.completed,
        steps: steps,
      );

  factory Activity.fromJson(Map<String, dynamic> json) =>
      _$ActivityFromJson(json);

  Map<String, dynamic> toJson() => _$ActivityToJson(this);
}