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
    if (ApiEndpoints.aiProxyUrl.isEmpty && ApiEndpoints.geminiApiKey.isEmpty) {
      throw StateError(
        'API key SproutGuide belum diisi. Jalankan aplikasi dengan '
        '--dart-define=GEMINI_API_KEY=<kunci Anda> atau siapkan AI_PROXY_URL.',
      );
    }

    try {
      final response = await executeWithRetry<Response<dynamic>>(
        request: () async => _dio.post(
          ApiEndpoints.aiProxyUrl.isEmpty
              ? '${ApiEndpoints.geminiApiUrl}?key=${ApiEndpoints.geminiApiKey}'
              : ApiEndpoints.aiProxyUrl,
          options: Options(headers: {'Content-Type': 'application/json'}),
          data: jsonEncode({
            'contents': [
              {
                'role': 'user',
                'parts': [
                  {'text': 'Kamu adalah SproutGuide.\n$_systemPrompt\n\n${_buildUserPrompt(child, recentLogs)}'}
                ],
              }
            ],
            'generationConfig': {
              'temperature': 0.2,
              'topP': 0.8,
            },
          }),
        ),
      );

      final content = _extractGeminiText(response.data);
      return parseRecommendation(
        content,
        childId: child.id,
        customActivities: child.customActivities,
      );
    } on DioException catch (_) {
      return buildFallbackRecommendation(child, recentLogs);
    }
  }

  /// SproutGuide's development analysis (RF-10): a short read on how the child
  /// is progressing, as input for the next intervention step. Advice only — the
  /// parent and therapist still decide.
  Future<ProgressAnalysis> analyseProgress({
    required Child child,
    required List<BehaviourLog> recentLogs,
  }) async {
    if (ApiEndpoints.aiProxyUrl.isEmpty && ApiEndpoints.geminiApiKey.isEmpty) {
      throw StateError(
        'API key SproutGuide belum diisi. Jalankan aplikasi dengan '
        '--dart-define=GEMINI_API_KEY=<kunci Anda> atau siapkan AI_PROXY_URL.',
      );
    }
    if (recentLogs.isEmpty) {
      throw StateError(
        'Belum ada aktivitas yang tercatat. Jalankan papan di SproutPlan terlebih dahulu.',
      );
    }

    try {
      final response = await executeWithRetry<Response<dynamic>>(
        request: () async => _dio.post(
          ApiEndpoints.aiProxyUrl.isEmpty
              ? '${ApiEndpoints.geminiApiUrl}?key=${ApiEndpoints.geminiApiKey}'
              : ApiEndpoints.aiProxyUrl,
          options: Options(headers: {'Content-Type': 'application/json'}),
          data: jsonEncode({
            'contents': [
              {
                'role': 'user',
                'parts': [
                  {'text': 'Kamu adalah SproutGuide.\n$_analysisSystemPrompt\n\n${buildAnalysisPrompt(child, recentLogs)}'}
                ],
              }
            ],
            'generationConfig': {
              'temperature': 0.2,
              'topP': 0.8,
            },
          }),
        ),
      );

      final content = _extractGeminiText(response.data);
      return parseAnalysis(content);
    } on DioException catch (_) {
      return buildFallbackAnalysis(child, recentLogs);
    }
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

  static Recommendation buildFallbackRecommendation(Child child, List<BehaviourLog> recentLogs) {
    final activityStats = <String, ({int completed, int total, int highTransitionHits, int lowMoodHits})>{};

    for (final log in recentLogs) {
      final current = activityStats[log.activityId] ?? (completed: 0, total: 0, highTransitionHits: 0, lowMoodHits: 0);
      activityStats[log.activityId] = (
        completed: current.completed + (log.completed ? 1 : 0),
        total: current.total + 1,
        highTransitionHits: current.highTransitionHits + (log.transitionDifficulty == TransitionDifficulty.high ? 1 : 0),
        lowMoodHits: current.lowMoodHits + (log.mood == Mood.upset || log.mood == Mood.meltdown || log.mood == Mood.anxious ? 1 : 0),
      );
    }

    final rankedActivities = activityStats.entries.toList()
      ..sort((a, b) {
        final aSuccess = a.value.completed / a.value.total;
        final bSuccess = b.value.completed / b.value.total;
        if ((aSuccess - bSuccess).abs() > 0.0001) {
          return bSuccess.compareTo(aSuccess);
        }
        return a.value.highTransitionHits.compareTo(b.value.highTransitionHits);
      });

    final bestActivity = rankedActivities.isNotEmpty
        ? rankedActivities.first.key
        : ActivityCatalog.items.first.id;

    final recentMood = recentLogs.isNotEmpty ? recentLogs.last.mood : Mood.neutral;
    final promptType = recentMood == Mood.upset || recentMood == Mood.meltdown || recentMood == Mood.anxious
        ? PromptType.visual
        : recentLogs.any((log) => log.completed)
            ? PromptType.voice
            : PromptType.visual;

    final reason = recentLogs.isEmpty
        ? 'Fallback: belum ada log cukup, jadi dipilih aktivitas rutin yang paling aman.'
        : 'Fallback: aktivitas dipilih dari pola keberhasilan, mood, dan transisi terbaru.';

    return Recommendation(
      id: '${child.id}-${DateTime.now().millisecondsSinceEpoch}',
      childId: child.id,
      activityId: bestActivity,
      recommendedRewardId: null,
      recommendedPrompt: promptType,
      confidence: 0.45,
      reason: reason,
    );
  }

  static ProgressAnalysis buildFallbackAnalysis(Child child, List<BehaviourLog> recentLogs) {
    final completed = recentLogs.where((log) => log.completed).length;
    final total = recentLogs.length;
    final successRate = total == 0 ? 0.0 : completed / total;
    final recentMood = recentLogs.isNotEmpty ? recentLogs.last.mood : Mood.neutral;
    final hardTransitions = recentLogs.where((log) => log.transitionDifficulty == TransitionDifficulty.high).length;

    final summary = total == 0
        ? 'Belum ada data cukup untuk analisis otomatis.'
        : 'Berdasarkan ${total} aktivitas terakhir, tingkat penyelesaian sekitar ${ (successRate * 100).round() }%. Mood terakhir ${recentMood.name} dan ada $hardTransitions transisi yang menantang.';

    final strengths = <String>[];
    final concerns = <String>[];

    if (successRate >= 0.7) {
      strengths.add('Konsistensi aktivitas cukup baik');
    } else if (successRate >= 0.4) {
      strengths.add('Anak masih bisa mengikuti rutinitas dengan dukungan');
    } else {
      strengths.add('Ada ruang untuk memperkuat rutinitas');
    }

    if (hardTransitions > 0) {
      concerns.add('Transisi masih menjadi titik tantangan');
    }

    if (recentMood == Mood.upset || recentMood == Mood.meltdown || recentMood == Mood.anxious) {
      concerns.add('Mood terakhir cenderung menurun');
    }

    return ProgressAnalysis(
      summary: summary,
      strengths: strengths,
      concerns: concerns.isEmpty ? const ['Perlu dukungan yang lebih konsisten'] : concerns,
      nextStep: 'Gunakan rutinitas yang sederhana dan konsisten, lalu periksa kembali setelah beberapa aktivitas.',
    );
  }

  static Future<T> executeWithRetry<T>({
    required Future<T> Function() request,
    int maxAttempts = 3,
    Duration baseDelay = const Duration(seconds: 1),
  }) async {
    var attempt = 0;
    while (true) {
      try {
        return await request();
      } on DioException catch (error) {
        attempt += 1;
        final isRetryable = error.response?.statusCode == 429 ||
            error.type == DioExceptionType.connectionTimeout ||
            error.type == DioExceptionType.receiveTimeout ||
            error.type == DioExceptionType.sendTimeout;

        if (!isRetryable || attempt >= maxAttempts) {
          rethrow;
        }

        await Future<void>.delayed(baseDelay * attempt);
      }
    }
  }

  static String _extractGeminiText(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      final candidates = responseData['candidates'];
      if (candidates is List && candidates.isNotEmpty) {
        final firstCandidate = candidates.first;
        if (firstCandidate is Map<String, dynamic>) {
          final content = firstCandidate['content'];
          if (content is Map<String, dynamic>) {
            final parts = content['parts'];
            if (parts is List && parts.isNotEmpty) {
              final firstPart = parts.first;
              if (firstPart is Map<String, dynamic>) {
                final text = firstPart['text'];
                if (text is String && text.trim().isNotEmpty) {
                  return text;
                }
              }
            }
          }
        }
      }
    }

    if (responseData is Map<String, dynamic>) {
      final text = responseData['text'];
      if (text is String && text.trim().isNotEmpty) {
        return text;
      }
    }

    throw StateError('Respons Gemini tidak mengandung teks yang valid.');
  }

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
    final data = _decodeJsonObject(content);

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
    final data = _decodeJsonObject(content);

    final catalog = ActivityCatalog.allWith(customActivities);
    final rawActivityId = data['activityId']?.toString() ?? '';
    final activityId = catalog.any((e) => e.id == rawActivityId)
        ? rawActivityId
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

  static Map<String, dynamic> _decodeJsonObject(String content) {
    final normalized = content.trim();

    if (normalized.isEmpty) {
      return const <String, dynamic>{};
    }

    final fenced = RegExp(r'```(?:json)?\s*([\s\S]*?)\s*```').firstMatch(normalized);
    final candidate = fenced?.group(1) ?? normalized;

    final direct = _tryDecodeJson(candidate);
    if (direct is Map) {
      final map = _normalizeMap(direct);
      final nested = _extractNestedMap(map);
      if (nested != null) {
        return nested;
      }
      return map;
    }

    final text = _extractTextFromPayload(direct);
    if (text != null) {
      final nested = _tryDecodeJson(text);
      if (nested is Map) {
        return _normalizeMap(nested);
      }
    }

    final match = RegExp(r'\{[\s\S]*\}').firstMatch(candidate);
    final jsonStr = match?.group(0) ?? candidate;
    final fallback = _tryDecodeJson(jsonStr);
    if (fallback is Map) {
      return _normalizeMap(fallback);
    }

    return const <String, dynamic>{};
  }

  static Object? _tryDecodeJson(String value) {
    try {
      return jsonDecode(value);
    } catch (_) {
      return null;
    }
  }

  static String? _extractTextFromPayload(Object? payload) {
    if (payload is String && payload.trim().isNotEmpty) {
      return payload.trim();
    }

    if (payload is Map) {
      final map = payload as Map;
      final text = map['text'];
      if (text is String && text.trim().isNotEmpty) {
        return text.trim();
      }

      final candidates = map['candidates'];
      if (candidates is List && candidates.isNotEmpty) {
        for (final item in candidates) {
          final nested = _extractTextFromPayload(item);
          if (nested != null) {
            return nested;
          }
        }
      }

      for (final value in map.values) {
        final nested = _extractTextFromPayload(value);
        if (nested != null) {
          return nested;
        }
      }
    }

    if (payload is List) {
      for (final item in payload) {
        final nested = _extractTextFromPayload(item);
        if (nested != null) {
          return nested;
        }
      }
    }

    return null;
  }

  static Map<String, dynamic>? _extractNestedMap(Map<String, dynamic> payload) {
    final text = _extractTextFromPayload(payload);
    if (text == null) {
      return null;
    }

    final decoded = _tryDecodeJson(text);
    if (decoded is Map) {
      return _normalizeMap(decoded);
    }

    return null;
  }

  static Map<String, dynamic> _normalizeMap(Object payload) {
    if (payload is Map) {
      return Map<String, dynamic>.from(
        payload.map((key, value) => MapEntry(key.toString(), value)),
      );
    }
    return const <String, dynamic>{};
  }
}

final aiServiceProvider = Provider<AiService>((ref) => AiService(ref.watch(dioProvider)));
