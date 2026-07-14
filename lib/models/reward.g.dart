// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reward.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Reward _$RewardFromJson(Map<String, dynamic> json) => Reward(
  id: json['id'] as String,
  title: json['title'] as String,
  icon: json['icon'] as String,
  cost: (json['cost'] as num).toInt(),
  owned: json['owned'] as bool? ?? false,
);

Map<String, dynamic> _$RewardToJson(Reward instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'icon': instance.icon,
  'cost': instance.cost,
  'owned': instance.owned,
};
