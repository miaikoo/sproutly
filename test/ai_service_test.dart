import 'package:flutter_test/flutter_test.dart';
import 'package:sprout_ly_app/core/data/activity_catalog.dart';
import 'package:sprout_ly_app/core/services/ai_service.dart';
import 'package:sprout_ly_app/models/behaviour_log.dart';
import 'package:sprout_ly_app/models/child.dart';
import 'package:sprout_ly_app/models/enums.dart';

void main() {
  test('parses a clean JSON response', () {
    const content = '{"activityId": "mandi", "recommendedPrompt": "voice", '
        '"confidence": 0.8, "reason": "Anak menunjukkan konsistensi tinggi."}';

    final rec = AiService.parseRecommendation(content, childId: 'child-1');

    expect(rec.activityId, 'mandi');
    expect(rec.recommendedPrompt, PromptType.voice);
    expect(rec.confidence, 0.8);
    expect(rec.reason, 'Anak menunjukkan konsistensi tinggi.');
    expect(rec.childId, 'child-1');
  });

  test('extracts JSON from a markdown-fenced response', () {
    const content = 'Berikut rekomendasinya:\n```json\n'
        '{"activityId": "sikat_gigi", "recommendedPrompt": "visual", '
        '"confidence": 0.6, "reason": "Rutinitas pagi."}\n```';

    final rec = AiService.parseRecommendation(content, childId: 'child-1');

    expect(rec.activityId, 'sikat_gigi');
    expect(rec.recommendedPrompt, PromptType.visual);
  });

  test('falls back to a valid catalog id when activityId is unknown', () {
    const content = '{"activityId": "not_real", "recommendedPrompt": "text", '
        '"confidence": 0.5, "reason": "x"}';

    final rec = AiService.parseRecommendation(content, childId: 'child-1');

    expect(rec.activityId, isNotEmpty);
    expect(rec.activityId, isNot('not_real'));
  });

  test('falls back to visual prompt when recommendedPrompt is invalid', () {
    const content = '{"activityId": "makan", "recommendedPrompt": "shout", '
        '"confidence": 1.5, "reason": "x"}';

    final rec = AiService.parseRecommendation(content, childId: 'child-1');

    expect(rec.recommendedPrompt, PromptType.visual);
    expect(rec.confidence, 1.0); // clamped
  });

  test('accepts a parent-made activity id when it is in the custom list', () {
    const content = '{"activityId": "custom-1", "recommendedPrompt": "voice", '
        '"confidence": 0.7, "reason": "Sesuai target."}';

    final rec = AiService.parseRecommendation(
      content,
      childId: 'child-1',
      customActivities: const [
        ActivityCatalogItem(
          id: 'custom-1',
          title: 'Merapikan mainan',
          image: 'assets/images/Bermain.png',
          category: ActivityCategory.other,
        ),
      ],
    );

    expect(rec.activityId, 'custom-1');
  });

  test('rejects a custom id that the child does not own', () {
    const content = '{"activityId": "custom-1", "recommendedPrompt": "voice", '
        '"confidence": 0.7, "reason": "x"}';

    final rec = AiService.parseRecommendation(content, childId: 'child-1');

    expect(rec.activityId, isNot('custom-1'));
  });

  group('parseAnalysis', () {
    test('reads a full analysis', () {
      const content = '{"summary": "Budi konsisten pada rutinitas pagi.", '
          '"strengths": ["Sikat gigi mandiri", "Mood stabil"], '
          '"concerns": ["Transisi ke belajar masih sulit"], '
          '"nextStep": "Tambahkan papan pertama-kemudian sebelum belajar."}';

      final analysis = AiService.parseAnalysis(content);

      expect(analysis.summary, 'Budi konsisten pada rutinitas pagi.');
      expect(analysis.strengths, hasLength(2));
      expect(analysis.concerns, ['Transisi ke belajar masih sulit']);
      expect(analysis.nextStep, contains('pertama-kemudian'));
    });

    test('extracts JSON wrapped in prose or a code fence', () {
      const content = 'Ini analisisnya:\n```json\n'
          '{"summary": "Baik.", "strengths": [], "concerns": [], "nextStep": "Lanjutkan."}\n```';

      final analysis = AiService.parseAnalysis(content);

      expect(analysis.summary, 'Baik.');
      expect(analysis.nextStep, 'Lanjutkan.');
    });

    test('accepts a single string where a list was asked for', () {
      // Smaller models often return a bare string instead of a list.
      const content = '{"summary": "Baik.", "strengths": "Mandi mandiri", '
          '"concerns": "", "nextStep": "Lanjutkan."}';

      final analysis = AiService.parseAnalysis(content);

      expect(analysis.strengths, ['Mandi mandiri']);
      expect(analysis.concerns, isEmpty);
    });

    test('missing fields come back empty rather than throwing', () {
      const content = '{"summary": "Baik."}';

      final analysis = AiService.parseAnalysis(content);

      expect(analysis.summary, 'Baik.');
      expect(analysis.strengths, isEmpty);
      expect(analysis.concerns, isEmpty);
      expect(analysis.nextStep, isEmpty);
    });

    test('drops blank entries inside a list', () {
      const content = '{"summary": "x", "strengths": ["Mandi", "", "  "], '
          '"concerns": [], "nextStep": "y"}';

      final analysis = AiService.parseAnalysis(content);

      expect(analysis.strengths, ['Mandi']);
    });
  });

  group('buildAnalysisPrompt', () {
    test('aggregates instead of listing every log, and includes the profile', () {
      final child = Child(
        id: 'child-1',
        parentId: 'parent-1',
        name: 'Budi',
        birthDate: DateTime(2020, 1, 1),
        severity: Severity.moderate,
        photoUrl: '',
        preferences: const ['stiker'],
        interventionTargets: const ['makan mandiri'],
      );

      final logs = [
        for (var i = 0; i < 20; i++)
          BehaviourLog(
            id: 'log-$i',
            childId: 'child-1',
            activityId: i.isEven ? 'mandi' : 'makan',
            timestamp: DateTime(2026, 7, 30).subtract(Duration(hours: i)),
            mood: Mood.happy,
            promptType: PromptType.voice,
            rewardId: null,
            transitionDifficulty:
                i == 0 ? TransitionDifficulty.high : TransitionDifficulty.low,
            completed: i != 1,
            durationMinutes: 15,
          ),
      ];

      final prompt = AiService.buildAnalysisPrompt(child, logs);

      expect(prompt, contains('stiker'));
      expect(prompt, contains('makan mandiri'));
      expect(prompt, contains('Jumlah aktivitas tercatat: 20'));
      expect(prompt, contains('95%'));
      expect(prompt, contains('Transisi sulit: 1 kali'));
      // Per-activity rollup, not one line per log.
      expect(prompt, contains('mandi: 10/10'));
      expect(prompt, contains('makan: 9/10'));
      expect(prompt.split('\n').length, lessThan(12));
    });
  });
}
