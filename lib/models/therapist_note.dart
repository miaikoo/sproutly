import 'package:json_annotation/json_annotation.dart';

part 'therapist_note.g.dart';

@JsonSerializable()
class TherapistNote {
  final String id;

  final String childId;

  final String therapistId;

  final DateTime sessionDate;

  final String observation;

  final String recommendation;

  const TherapistNote({
    required this.id,
    required this.childId,
    required this.therapistId,
    required this.sessionDate,
    required this.observation,
    required this.recommendation,
  });

  factory TherapistNote.fromJson(Map<String, dynamic> json) =>
      _$TherapistNoteFromJson(json);

  Map<String, dynamic> toJson() => _$TherapistNoteToJson(this);
}