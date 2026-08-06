import 'package:flutter_test/flutter_test.dart';
import 'package:sprout_ly_app/core/services/behaviour_log_service.dart';
import 'package:sprout_ly_app/models/behaviour_log.dart';
import 'package:sprout_ly_app/models/enums.dart';

void main() {
  group('BehaviourLogService.normalizeLogsForAnalytics', () {
    test('returns an empty list when no behaviour logs are available', () {
      expect(BehaviourLogService.normalizeLogsForAnalytics([]), isEmpty);
    });

    test('keeps fetched logs and orders them by newest first', () {
      final earlier = BehaviourLog(
        id: 'older',
        childId: 'child-1',
        activityId: 'activity-1',
        timestamp: DateTime(2026, 8, 1, 9),
        mood: Mood.calm,
        promptType: PromptType.voice,
        rewardId: null,
        transitionDifficulty: TransitionDifficulty.low,
        completed: true,
        durationMinutes: 10,
      );

      final later = BehaviourLog(
        id: 'newer',
        childId: 'child-1',
        activityId: 'activity-2',
        timestamp: DateTime(2026, 8, 2, 9),
        mood: Mood.happy,
        promptType: PromptType.visual,
        rewardId: null,
        transitionDifficulty: TransitionDifficulty.medium,
        completed: true,
        durationMinutes: 15,
      );

      final normalized = BehaviourLogService.normalizeLogsForAnalytics([earlier, later]);

      expect(normalized, hasLength(2));
      expect(normalized.first.id, 'newer');
      expect(normalized.last.id, 'older');
    });

    test('skips malformed Firestore payloads instead of crashing', () {
      final parsed = BehaviourLogService.parseLogsFromFirestore([
        {
          'id': 'valid',
          'childId': 'child-1',
          'activityId': 'activity-1',
          'timestamp': '2026-08-02T09:00:00.000',
          'mood': 'happy',
          'promptType': 'visual',
          'rewardId': null,
          'transitionDifficulty': 'low',
          'completed': true,
          'durationMinutes': 15,
        },
        {
          'id': 'broken',
          'childId': 'child-1',
          'activityId': 'activity-2',
          'timestamp': 'not-a-date',
          'mood': 'happy',
          'promptType': 'visual',
          'rewardId': null,
          'transitionDifficulty': 'low',
          'completed': true,
          'durationMinutes': 15,
        },
      ]);

      expect(parsed, hasLength(1));
      expect(parsed.single.id, 'valid');
    });
  });
}
