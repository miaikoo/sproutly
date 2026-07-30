import 'package:flutter_test/flutter_test.dart';
import 'package:sprout_ly_app/core/services/ai_service.dart';
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
}
