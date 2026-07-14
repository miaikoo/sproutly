import 'package:json_annotation/json_annotation.dart';

part 'reward.g.dart';

@JsonSerializable()
class Reward {
  final String id;

  final String title;

  final String icon;

  final int cost;

  final bool owned;

  const Reward({
    required this.id,
    required this.title,
    required this.icon,
    required this.cost,
    this.owned = false,
  });

  factory Reward.fromJson(Map<String, dynamic> json) =>
      _$RewardFromJson(json);

  Map<String, dynamic> toJson() => _$RewardToJson(this);
}