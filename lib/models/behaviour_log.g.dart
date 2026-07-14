// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'behaviour_log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BehaviourLog _$BehaviourLogFromJson(Map<String, dynamic> json) => BehaviourLog(
  id: json['id'] as String,
  childId: json['childId'] as String,
  activityId: json['activityId'] as String,
  timestamp: DateTime.parse(json['timestamp'] as String),
  mood: $enumDecode(_$MoodEnumMap, json['mood']),
  promptType: $enumDecode(_$PromptTypeEnumMap, json['promptType']),
  rewardId: json['rewardId'] as String?,
  transitionDifficulty: $enumDecode(
    _$TransitionDifficultyEnumMap,
    json['transitionDifficulty'],
  ),
  completed: json['completed'] as bool,
  durationMinutes: (json['durationMinutes'] as num).toInt(),
);

Map<String, dynamic> _$BehaviourLogToJson(BehaviourLog instance) =>
    <String, dynamic>{
      'id': instance.id,
      'childId': instance.childId,
      'activityId': instance.activityId,
      'timestamp': instance.timestamp.toIso8601String(),
      'mood': _$MoodEnumMap[instance.mood]!,
      'promptType': _$PromptTypeEnumMap[instance.promptType]!,
      'rewardId': instance.rewardId,
      'transitionDifficulty':
          _$TransitionDifficultyEnumMap[instance.transitionDifficulty]!,
      'completed': instance.completed,
      'durationMinutes': instance.durationMinutes,
    };

const _$MoodEnumMap = {
  Mood.happy: 'happy',
  Mood.calm: 'calm',
  Mood.neutral: 'neutral',
  Mood.anxious: 'anxious',
  Mood.upset: 'upset',
  Mood.meltdown: 'meltdown',
};

const _$PromptTypeEnumMap = {
  PromptType.visual: 'visual',
  PromptType.voice: 'voice',
  PromptType.text: 'text',
};

const _$TransitionDifficultyEnumMap = {
  TransitionDifficulty.low: 'low',
  TransitionDifficulty.medium: 'medium',
  TransitionDifficulty.high: 'high',
};
