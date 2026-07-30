import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprout_ly_app/core/services/behaviour_log_service.dart';
import 'package:sprout_ly_app/core/services/child_service.dart';
import 'package:sprout_ly_app/core/services/therapist_note_service.dart';
import 'package:sprout_ly_app/models/behaviour_log.dart';
import 'package:sprout_ly_app/models/child.dart';
import 'package:sprout_ly_app/models/enums.dart';
import 'package:sprout_ly_app/models/therapist_note.dart';
import 'package:sprout_ly_app/models/user.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late ChildService childService;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    childService = ChildService(firestore);
  });

  test('linkTherapistByEmail finds the therapist and sets therapistId', () async {
    await firestore.collection('children').doc('child-1').set(
          Child(
            id: 'child-1',
            parentId: 'parent-1',
            name: 'Budi',
            birthDate: DateTime(2020, 1, 1),
            severity: Severity.mild,
            photoUrl: '',
          ).toJson(),
        );
    await firestore.collection('users').doc('therapist-1').set(
          const User(
            id: 'therapist-1',
            email: 'terapis@example.com',
            name: 'Bu Rina',
            role: UserRole.therapist,
          ).toJson(),
        );

    await childService.linkTherapistByEmail(childId: 'child-1', email: 'terapis@example.com');

    final child = await childService.watchChildById('child-1').first;
    expect(child!.therapistId, 'therapist-1');

    final linked = await childService.watchChildrenForTherapist('therapist-1').first;
    expect(linked.map((c) => c.id), contains('child-1'));
  });

  test('linkTherapistByEmail throws when no therapist matches', () async {
    await firestore.collection('children').doc('child-1').set(
          Child(
            id: 'child-1',
            parentId: 'parent-1',
            name: 'Budi',
            birthDate: DateTime(2020, 1, 1),
            severity: Severity.mild,
            photoUrl: '',
          ).toJson(),
        );

    expect(
      () => childService.linkTherapistByEmail(childId: 'child-1', email: 'nobody@example.com'),
      throwsA(isA<StateError>()),
    );
  });

  test('behaviour log and therapist note write/read round-trip', () async {
    final logService = BehaviourLogService(firestore);
    final noteService = TherapistNoteService(firestore);

    final logId = logService.newLogId();
    await logService.addLog(BehaviourLog(
      id: logId,
      childId: 'child-1',
      activityId: 'activity-1',
      timestamp: DateTime(2026, 1, 1),
      mood: Mood.happy,
      promptType: PromptType.visual,
      rewardId: null,
      transitionDifficulty: TransitionDifficulty.low,
      completed: true,
      durationMinutes: 15,
    ));

    final logs = await logService.watchLogsForChild('child-1').first;
    expect(logs, hasLength(1));
    expect(logs.first.mood, Mood.happy);

    final noteId = noteService.newNoteId();
    await noteService.addNote(TherapistNote(
      id: noteId,
      childId: 'child-1',
      therapistId: 'therapist-1',
      sessionDate: DateTime(2026, 1, 2),
      observation: 'Anak lebih tenang',
      recommendation: 'Lanjutkan rutinitas pagi',
    ));

    final notes = await noteService.watchNotesForChild('child-1').first;
    expect(notes, hasLength(1));
    expect(notes.first.recommendation, 'Lanjutkan rutinitas pagi');
  });
}
