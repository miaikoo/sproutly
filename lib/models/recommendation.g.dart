// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recommendation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Recommendation _$RecommendationFromJson(Map<String, dynamic> json) =>
    Recommendation(
      activityId: json['activityId'] as String,
      recommendedRewardId: json['recommendedRewardId'] as String?,
      recommendedPrompt: json['recommendedPrompt'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      reason: json['reason'] as String,
    );

Map<String, dynamic> _$RecommendationToJson(Recommendation instance) =>
    <String, dynamic>{
      'activityId': instance.activityId,
      'recommendedRewardId': instance.recommendedRewardId,
      'recommendedPrompt': instance.recommendedPrompt,
      'confidence': instance.confidence,
      'reason': instance.reason,
    };
