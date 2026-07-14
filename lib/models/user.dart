import 'package:json_annotation/json_annotation.dart';
import 'enums.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final String id;

  final String email;

  final String name;

  final UserRole role;

  const User({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) =>
      _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}