import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/activity_catalog.dart';
import '../network/api_endpoints.dart';
import '../network/dio_client.dart';
import '../../models/behaviour_log.dart';
import '../../models/child.dart';
import '../../models/enums.dart';
import '../../models/recommendation.dart';

class AiService {
  AiService(this._dio);

  final Dio _dio;

  Future<Recommendation> recommendActivity({
    required Child child,
    required List<BehaviourLog> recentLogs,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.openRouterChatCompletions,
      options: Options(headers: {
        'Authorization': 'Bearer ${ApiEndpoints.openRouterApiKey}',
        'Content-Type': 'application/json',
      }),
      data: jsonEncode({
        'model': ApiEndpoints.openRouterModel,
        'messages': [
          {'role': 'system', 'content': _systemPrompt},
          {'role': 'user', 'content': _buildUserPrompt(child, recentLogs)},
        ],
      }),
    );

    final content = response.data['choices'][0]['message']['content'] as String;
    return parseRecommendation(content, childId: child.id);
  }

  static const _systemPrompt =
      'Kamu adalah SproutGuide, asisten AI dalam aplikasi Sprout.ly yang membantu orang tua '
      'anak dengan Autism Spectrum Disorder (ASD) memilih aktivitas daily living skills berikutnya. '
      'Balas HANYA dengan JSON valid tanpa teks lain, format persis: '
      '{"activityId": "<salah satu id dari daftar aktivitas>", "recommendedPrompt": "visual|voice|text", '
      '"confidence": <angka 0 sampai 1>, "reason": "<alasan singkat dalam Bahasa Indonesia, maks 2 kalimat>"}';

  static String _buildUserPrompt(Child child, List<BehaviourLog> recentLogs) {
    final catalog = ActivityCatalog.items
        .map((e) => '${e.id} (${e.title}, kategori ${e.category.name})')
        .join(', ');

    final history = recentLogs.isEmpty
        ? 'Belum ada riwayat aktivitas.'
        : recentLogs.take(10).map((l) {
            return '- aktivitas ${l.activityId}: mood ${l.mood.name}, '
                'transisi ${l.transitionDifficulty.name}, '
                '${l.completed ? "selesai" : "tidak selesai"}';
          }).join('\n');

    return 'Profil anak: tingkat perkembangan ${child.severity.name}.\n'
        'Daftar aktivitas yang tersedia: $catalog.\n'
        'Riwayat aktivitas terbaru:\n$history\n'
        'Rekomendasikan satu aktivitas berikutnya yang paling sesuai.';
  }

  static Recommendation parseRecommendation(String content, {required String childId}) {
    final match = RegExp(r'\{[\s\S]*\}').firstMatch(content);
    final jsonStr = match?.group(0) ?? content;
    final data = jsonDecode(jsonStr) as Map<String, dynamic>;

    final activityId = ActivityCatalog.items.any((e) => e.id == data['activityId'])
        ? data['activityId'] as String
        : ActivityCatalog.items.first.id;

    final promptType = PromptType.values.firstWhere(
      (p) => p.name == data['recommendedPrompt'],
      orElse: () => PromptType.visual,
    );

    final confidence = (data['confidence'] as num?)?.toDouble() ?? 0.5;

    return Recommendation(
      id: '$childId-${DateTime.now().millisecondsSinceEpoch}',
      childId: childId,
      activityId: activityId,
      recommendedRewardId: null,
      recommendedPrompt: promptType,
      confidence: confidence.clamp(0, 1),
      reason: data['reason'] as String? ?? '',
    );
  }
}

final aiServiceProvider = Provider<AiService>((ref) => AiService(ref.watch(dioProvider)));
