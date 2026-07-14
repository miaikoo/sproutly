// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'therapist_note.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TherapistNote _$TherapistNoteFromJson(Map<String, dynamic> json) =>
    TherapistNote(
      id: json['id'] as String,
      childId: json['childId'] as String,
      therapistId: json['therapistId'] as String,
      sessionDate: DateTime.parse(json['sessionDate'] as String),
      observation: json['observation'] as String,
      recommendation: json['recommendation'] as String,
    );

Map<String, dynamic> _$TherapistNoteToJson(TherapistNote instance) =>
    <String, dynamic>{
      'id': instance.id,
      'childId': instance.childId,
      'therapistId': instance.therapistId,
      'sessionDate': instance.sessionDate.toIso8601String(),
      'observation': instance.observation,
      'recommendation': instance.recommendation,
    };
