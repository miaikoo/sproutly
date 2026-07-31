import 'package:json_annotation/json_annotation.dart';

import '../core/data/activity_catalog.dart';
import 'enums.dart';

part 'child.g.dart';

@JsonSerializable(explicitToJson: true)
class Child {
  final String id;

  final String parentId;

  final String name;

  final DateTime birthDate;

  final Severity severity;

  final String photoUrl;

  final String? therapistId;

  /// Activities this parent created for their child, alongside the presets.
  /// Kept on the child document rather than a collection of its own — there are
  /// only ever a handful, and it avoids a second query on every board edit.
  @JsonKey(defaultValue: <ActivityCatalogItem>[])
  final List<ActivityCatalogItem> customActivities;

  /// What the child likes or responds to — feeds SproutGuide's prompt so
  /// recommendations and reinforcement match the child. (RF-02)
  @JsonKey(defaultValue: <String>[])
  final List<String> preferences;

  /// Daily-living-skill goals the parent and therapist are working towards.
  @JsonKey(defaultValue: <String>[])
  final List<String> interventionTargets;

  /// Spendable in the Sprout Store. Goes up on activity completion, down on
  /// purchase — unlike [exp], this can shrink.
  @JsonKey(defaultValue: 0)
  final int points;

  /// Lifetime total, never spent. Drives the companion's level — see
  /// [levelForExp] in `companion_progress.dart`.
  @JsonKey(defaultValue: 0)
  final int exp;

  /// Ids of store items already bought, so they render as owned instead of
  /// purchasable again.
  @JsonKey(defaultValue: <String>[])
  final List<String> unlockedItemIds;

  const Child({
    required this.id,
    required this.parentId,
    required this.name,
    required this.birthDate,
    required this.severity,
    required this.photoUrl,
    this.therapistId,
    this.customActivities = const [],
    this.preferences = const [],
    this.interventionTargets = const [],
    this.points = 0,
    this.exp = 0,
    this.unlockedItemIds = const [],
  });

  int ageInYears(DateTime now) {
    var age = now.year - birthDate.year;
    // Not had this year's birthday yet.
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  factory Child.fromJson(Map<String, dynamic> json) =>
      _$ChildFromJson(json);

  Map<String, dynamic> toJson() => _$ChildToJson(this);
}