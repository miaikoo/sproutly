import 'package:json_annotation/json_annotation.dart';
import 'enums.dart';

part 'recommendation.g.dart';

@JsonSerializable()
class Recommendation {
  final String id;

  final String childId;

  final String activityId;

  final String? recommendedRewardId;

  final PromptType recommendedPrompt;

  final double confidence;

  final String reason;

  const Recommendation({
    required this.id,
    required this.childId,
    required this.activityId,
    required this.recommendedRewardId,
    required this.recommendedPrompt,
    required this.confidence,
    required this.reason,
  });

  factory Recommendation.fromJson(Map<String, dynamic> json) =>
      _$RecommendationFromJson(json);

  Map<String, dynamic> toJson() => _$RecommendationToJson(this);
}