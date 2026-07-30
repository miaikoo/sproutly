import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprout_ly_app/core/data/activity_catalog.dart';
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

  group('ageInYears', () {
    Child born(DateTime date) => Child(
          id: 'c',
          parentId: 'p',
          name: 'Budi',
          birthDate: date,
          severity: Severity.mild,
          photoUrl: '',
        );

    test('counts a birthday that has already passed this year', () {
      expect(born(DateTime(2020, 3, 1)).ageInYears(DateTime(2026, 7, 30)), 6);
    });

    test('does not count a birthday still ahead this year', () {
      expect(born(DateTime(2020, 11, 1)).ageInYears(DateTime(2026, 7, 30)), 5);
    });

    test('handles the birthday itself and the day before', () {
      expect(born(DateTime(2020, 7, 30)).ageInYears(DateTime(2026, 7, 30)), 6);
      expect(born(DateTime(2020, 7, 31)).ageInYears(DateTime(2026, 7, 30)), 5);
    });
  });

  group('updateProfile', () {
    Future<void> seed() => firestore.collection('children').doc('child-1').set(
          Child(
            id: 'child-1',
            parentId: 'parent-1',
            name: 'Budi',
            birthDate: DateTime(2020, 5, 1),
            severity: Severity.moderate,
            photoUrl: '',
            preferences: const ['musik'],
          ).toJson(),
        );

    test('writes only the fields passed, leaving the rest intact', () async {
      await seed();

      await childService.updateProfile('child-1', name: 'Budi Santoso');

      final child = await childService.watchChildById('child-1').first;
      expect(child!.name, 'Budi Santoso');
      // Untouched fields must survive a partial edit.
      expect(child.severity, Severity.moderate);
      expect(child.preferences, ['musik']);
      expect(child.birthDate, DateTime(2020, 5, 1));
    });

    test('replaces preferences and intervention targets', () async {
      await seed();

      await childService.updateProfile(
        'child-1',
        preferences: const ['stiker', 'musik'],
        interventionTargets: const ['makan mandiri'],
      );

      final child = await childService.watchChildById('child-1').first;
      expect(child!.preferences, ['stiker', 'musik']);
      expect(child.interventionTargets, ['makan mandiri']);
    });

    test('severity round-trips through the enum name', () async {
      await seed();

      await childService.updateProfile('child-1', severity: Severity.severe);

      final child = await childService.watchChildById('child-1').first;
      expect(child!.severity, Severity.severe);
    });
  });

  group('customActivities', () {
    const item = ActivityCatalogItem(
      id: 'custom-1',
      title: 'Merapikan mainan',
      image: 'assets/images/Bermain.png',
      category: ActivityCategory.other,
    );

    Future<void> seedChild() => firestore.collection('children').doc('child-1').set(
          Child(
            id: 'child-1',
            parentId: 'parent-1',
            name: 'Budi',
            birthDate: DateTime(2020, 5, 1),
            severity: Severity.moderate,
            photoUrl: '',
          ).toJson(),
        );

    test('a child saved without the field reads back with an empty list', () async {
      // Children created before custom activities existed must still load.
      final legacy = Child(
        id: 'child-1',
        parentId: 'parent-1',
        name: 'Budi',
        birthDate: DateTime(2020, 5, 1),
        severity: Severity.moderate,
        photoUrl: '',
      ).toJson()
        ..remove('customActivities');
      await firestore.collection('children').doc('child-1').set(legacy);

      final child = await childService.watchChildById('child-1').first;
      expect(child!.customActivities, isEmpty);
    });

    test('addCustomActivity appends and round-trips', () async {
      await seedChild();

      await childService.addCustomActivity('child-1', item);

      final child = await childService.watchChildById('child-1').first;
      expect(child!.customActivities.single.title, 'Merapikan mainan');
      expect(child.customActivities.single.category, ActivityCategory.other);
    });

    test('removeCustomActivity takes it back out', () async {
      await seedChild();
      await childService.addCustomActivity('child-1', item);

      await childService.removeCustomActivity('child-1', item);

      final child = await childService.watchChildById('child-1').first;
      expect(child!.customActivities, isEmpty);
    });
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
