import 'package:json_annotation/json_annotation.dart';

part 'behaviour_log.g.dart';

enum Mood {
  happy,
  calm,
  neutral,
  anxious,
  meltdown,
}

enum PromptType {
  visual,
  voice,
  text,
}

enum TransitionDifficulty {
  low,
  medium,
  high,
}

@JsonSerializable()
class BehaviourLog {
  final String id;

  final String childId;

  final String activityId;

  final DateTime timestamp;

  final Mood mood;

  final PromptType promptType;

  final String? rewardId;

  final TransitionDifficulty transitionDifficulty;

  final bool completed;

  final int durationMinutes;

  const BehaviourLog({
    required this.id,
    required this.childId,
    required this.activityId,
    required this.timestamp,
    required this.mood,
    required this.promptType,
    required this.rewardId,
    required this.transitionDifficulty,
    required this.completed,
    required this.durationMinutes,
  });

  factory BehaviourLog.fromJson(Map<String, dynamic> json) =>
      _$BehaviourLogFromJson(json);

  Map<String, dynamic> toJson() => _$BehaviourLogToJson(this);
}