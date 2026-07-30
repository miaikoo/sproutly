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

/// SproutGuide's read on how the child is progressing (RF-10). Not persisted —
/// it is regenerated from the logs whenever the parent asks for it.
class ProgressAnalysis {
  const ProgressAnalysis({
    required this.summary,
    required this.strengths,
    required this.concerns,
    required this.nextStep,
  });

  final String summary;
  final List<String> strengths;
  final List<String> concerns;
  final String nextStep;
}

class AiService {
  AiService(this._dio);

  final Dio _dio;

  Future<Recommendation> recommendActivity({
    required Child child,
    required List<BehaviourLog> recentLogs,
  }) async {
    if (ApiEndpoints.openRouterApiKey.isEmpty) {
      throw StateError(
        'API key SproutGuide belum diisi. Jalankan aplikasi dengan '
        '--dart-define=OPENROUTER_API_KEY=<kunci Anda>.',
      );
    }

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
    return parseRecommendation(
      content,
      childId: child.id,
      customActivities: child.customActivities,
    );
  }

  /// SproutGuide's development analysis (RF-10): a short read on how the child
  /// is progressing, as input for the next intervention step. Advice only — the
  /// parent and therapist still decide.
  Future<ProgressAnalysis> analyseProgress({
    required Child child,
    required List<BehaviourLog> recentLogs,
  }) async {
    if (ApiEndpoints.openRouterApiKey.isEmpty) {
      throw StateError(
        'API key SproutGuide belum diisi. Jalankan aplikasi dengan '
        '--dart-define=OPENROUTER_API_KEY=<kunci Anda>.',
      );
    }
    if (recentLogs.isEmpty) {
      throw StateError(
        'Belum ada aktivitas yang tercatat. Jalankan papan di SproutPlan terlebih dahulu.',
      );
    }

    final response = await _dio.post(
      ApiEndpoints.openRouterChatCompletions,
      options: Options(headers: {
        'Authorization': 'Bearer ${ApiEndpoints.openRouterApiKey}',
        'Content-Type': 'application/json',
      }),
      data: jsonEncode({
        'model': ApiEndpoints.openRouterModel,
        'messages': [
          {'role': 'system', 'content': _analysisSystemPrompt},
          {'role': 'user', 'content': buildAnalysisPrompt(child, recentLogs)},
        ],
      }),
    );

    final content = response.data['choices'][0]['message']['content'] as String;
    return parseAnalysis(content);
  }

  static const _analysisSystemPrompt =
      'Kamu adalah SproutGuide, asisten AI dalam aplikasi Sprout.ly yang membantu orang tua '
      'anak dengan Autism Spectrum Disorder (ASD) mengevaluasi perkembangan daily living skills. '
      'Kamu BUKAN alat diagnosis dan tidak boleh menyebut diagnosis atau obat. '
      'Balas HANYA dengan JSON valid tanpa teks lain, format persis: '
      '{"summary": "<ringkasan 2 kalimat dalam Bahasa Indonesia>", '
      '"strengths": ["<kekuatan singkat>", ...], '
      '"concerns": ["<hal yang perlu perhatian>", ...], '
      '"nextStep": "<satu saran konkret untuk periode berikutnya>"}';

  /// Compact, aggregated view of the logs. Sending raw entries would blow past
  /// what the free-tier model handles once a family has weeks of history.
  static String buildAnalysisPrompt(Child child, List<BehaviourLog> logs) {
    final completed = logs.where((l) => l.completed).length;
    final rate = (completed / logs.length * 100).round();

    final moodCounts = <Mood, int>{};
    for (final log in logs) {
      moodCounts[log.mood] = (moodCounts[log.mood] ?? 0) + 1;
    }
    final moods = (moodCounts.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value)))
        .map((e) => '${e.key.name} ${e.value}x')
        .join(', ');

    final hardTransitions =
        logs.where((l) => l.transitionDifficulty == TransitionDifficulty.high).length;

    // Per-activity completion shows which skills are actually sticking.
    final byActivity = <String, ({int total, int done})>{};
    for (final log in logs) {
      final current = byActivity[log.activityId] ?? (total: 0, done: 0);
      byActivity[log.activityId] =
          (total: current.total + 1, done: current.done + (log.completed ? 1 : 0));
    }
    final perActivity = byActivity.entries
        .map((e) => '${e.key}: ${e.value.done}/${e.value.total}')
        .join(', ');

    final profile = [
      'usia ${child.ageInYears(DateTime.now())} tahun',
      'tingkat perkembangan ${child.severity.name}',
      if (child.preferences.isNotEmpty) 'menyukai ${child.preferences.join(", ")}',
      if (child.interventionTargets.isNotEmpty)
        'target intervensi: ${child.interventionTargets.join(", ")}',
    ].join('; ');

    return 'Profil anak: $profile.\n'
        'Jumlah aktivitas tercatat: ${logs.length}.\n'
        'Tingkat penyelesaian: $rate%.\n'
        'Sebaran suasana hati: $moods.\n'
        'Transisi sulit: $hardTransitions kali.\n'
        'Penyelesaian per aktivitas: $perActivity.\n'
        'Buat analisis perkembangan singkat beserta satu saran untuk periode berikutnya.';
  }

  static ProgressAnalysis parseAnalysis(String content) {
    final match = RegExp(r'\{[\s\S]*\}').firstMatch(content);
    final data = jsonDecode(match?.group(0) ?? content) as Map<String, dynamic>;

    List<String> stringList(Object? value) => switch (value) {
          final List<dynamic> list =>
            list.map((e) => e.toString().trim()).where((e) => e.isNotEmpty).toList(),
          // Some models return a single string instead of a list.
          final String s when s.trim().isNotEmpty => [s.trim()],
          _ => const <String>[],
        };

    return ProgressAnalysis(
      summary: (data['summary'] as String?)?.trim() ?? '',
      strengths: stringList(data['strengths']),
      concerns: stringList(data['concerns']),
      nextStep: (data['nextStep'] as String?)?.trim() ?? '',
    );
  }

  static const _systemPrompt =
      'Kamu adalah SproutGuide, asisten AI dalam aplikasi Sprout.ly yang membantu orang tua '
      'anak dengan Autism Spectrum Disorder (ASD) memilih aktivitas daily living skills berikutnya. '
      'Balas HANYA dengan JSON valid tanpa teks lain, format persis: '
      '{"activityId": "<salah satu id dari daftar aktivitas>", "recommendedPrompt": "visual|voice|text", '
      '"confidence": <angka 0 sampai 1>, "reason": "<alasan singkat dalam Bahasa Indonesia, maks 2 kalimat>"}';

  static String _buildUserPrompt(Child child, List<BehaviourLog> recentLogs) {
    final catalog = ActivityCatalog.allWith(child.customActivities)
        .map((e) => '${e.id} (${e.title}, kategori ${e.category.name})')
        .join(', ');

    final history = recentLogs.isEmpty
        ? 'Belum ada riwayat aktivitas.'
        : recentLogs.take(10).map((l) {
            return '- aktivitas ${l.activityId}: mood ${l.mood.name}, '
                'transisi ${l.transitionDifficulty.name}, '
                '${l.completed ? "selesai" : "tidak selesai"}';
          }).join('\n');

    final profile = [
      'usia ${child.ageInYears(DateTime.now())} tahun',
      'tingkat perkembangan ${child.severity.name}',
      if (child.preferences.isNotEmpty) 'menyukai ${child.preferences.join(", ")}',
      if (child.interventionTargets.isNotEmpty)
        'target intervensi: ${child.interventionTargets.join(", ")}',
    ].join('; ');

    return 'Profil anak: $profile.\n'
        'Daftar aktivitas yang tersedia: $catalog.\n'
        'Riwayat aktivitas terbaru:\n$history\n'
        'Rekomendasikan satu aktivitas berikutnya yang paling sesuai.';
  }

  static Recommendation parseRecommendation(
    String content, {
    required String childId,
    List<ActivityCatalogItem> customActivities = const [],
  }) {
    final match = RegExp(r'\{[\s\S]*\}').firstMatch(content);
    final jsonStr = match?.group(0) ?? content;
    final data = jsonDecode(jsonStr) as Map<String, dynamic>;

    final catalog = ActivityCatalog.allWith(customActivities);
    final activityId = catalog.any((e) => e.id == data['activityId'])
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
