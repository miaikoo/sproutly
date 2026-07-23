// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recommendation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Recommendation _$RecommendationFromJson(Map<String, dynamic> json) =>
    Recommendation(
      id: json['id'] as String,
      childId: json['childId'] as String,
      activityId: json['activityId'] as String,
      recommendedRewardId: json['recommendedRewardId'] as String?,
      recommendedPrompt: $enumDecode(
        _$PromptTypeEnumMap,
        json['recommendedPrompt'],
      ),
      confidence: (json['confidence'] as num).toDouble(),
      reason: json['reason'] as String,
    );

Map<String, dynamic> _$RecommendationToJson(Recommendation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'childId': instance.childId,
      'activityId': instance.activityId,
      'recommendedRewardId': instance.recommendedRewardId,
      'recommendedPrompt': _$PromptTypeEnumMap[instance.recommendedPrompt]!,
      'confidence': instance.confidence,
      'reason': instance.reason,
    };

const _$PromptTypeEnumMap = {
  PromptType.visual: 'visual',
  PromptType.voice: 'voice',
  PromptType.text: 'text',
};
