import 'package:json_annotation/json_annotation.dart';
import 'enums.dart';

part 'child.g.dart';

@JsonSerializable()
class Child {
  final String id;

  final String parentId;

  final String name;

  final DateTime birthDate;

  final Severity severity;

  final String photoUrl;

  final String? therapistId;

  const Child({
    required this.id,
    required this.parentId,
    required this.name,
    required this.birthDate,
    required this.severity,
    required this.photoUrl,
    this.therapistId,
  });

  factory Child.fromJson(Map<String, dynamic> json) =>
      _$ChildFromJson(json);

  Map<String, dynamic> toJson() => _$ChildToJson(this);
}