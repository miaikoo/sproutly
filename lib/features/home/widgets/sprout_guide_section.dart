import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/data/activity_catalog.dart';
import '../../../../core/services/ai_service.dart';
import '../../../../core/services/child_service.dart';
import '../../../../core/services/behaviour_log_service.dart';
import '../../../../core/services/schedule_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../models/activity.dart';
import '../../../../models/enums.dart';
import '../../../../models/recommendation.dart';
import '../../../../models/schedule.dart';
import '../../../../shared/widgets/activity_image.dart';

const _promptStrategyLabels = {
  PromptType.visual: 'tunjukkan kartu visual',
  PromptType.voice: 'bacakan instruksi dengan suara',
  PromptType.text: 'beri instruksi singkat tertulis',
};

String _boardTypeLabel(BoardType type) {
  switch (type) {
    case BoardType.schedule: return 'Papan jadwal';
    case BoardType.firstThen: return 'Papan pertama-lalu';
    case BoardType.waiting: return 'Papan menunggu';
    case BoardType.emotion: return 'Papan perasaan';
  }
}

class SproutGuideSection extends ConsumerStatefulWidget {
  const SproutGuideSection({super.key});

  @override
  ConsumerState<SproutGuideSection> createState() => _SproutGuideSectionState();
}

class _SproutGuideSectionState extends ConsumerState<SproutGuideSection> {
  Recommendation? _recommendation;
  ProgressAnalysis? _analysis;
  bool _isLoading = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    if (_recommendation != null || _analysis != null) {
      return _buildRecommendationPanel();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.peach100,
              shape: BoxShape.circle,
            ),
            child: const Text('✨', style: TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('SproutGuide AI', style: AppTextStyles.headingS),
                Text('Rekomendasi aktivitas & analisis', style: AppTextStyles.bodyS),
                if (_error != null)
                  Text(_error!, style: AppTextStyles.caption.copyWith(color: AppColors.error)),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: _isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.peach500),
                  )
                : Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.peach500,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.auto_awesome, size: 16, color: Colors.white),
                        const SizedBox(width: 6),
                        Text('Tanya AI', style: AppTextStyles.labelL.copyWith(color: Colors.white)),
                      ],
                    ),
                  ),
            onSelected: (val) {
              if (val == 'rec') _fetchRecommendation();
              if (val == 'analysis') _fetchAnalysis();
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'rec', child: Text('Rekomendasi Aktivitas')),
              PopupMenuItem(value: 'analysis', child: Text('Analisis Perkembangan')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 12)],
      ),
      child: switch ((_recommendation, _analysis)) {
        (final Recommendation rec, _) => _buildRecommendationCard(rec),
        (_, final ProgressAnalysis analysis) => _buildAnalysisCard(analysis),
        _ => const SizedBox.shrink(),
      },
    );
  }

  Widget _buildAnalysisCard(ProgressAnalysis analysis) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Analisis Perkembangan', style: AppTextStyles.headingM),
        const SizedBox(height: 8),
        Text(analysis.summary, style: AppTextStyles.bodyM),
        if (analysis.strengths.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text('Sudah berkembang', style: AppTextStyles.labelL),
          for (final item in analysis.strengths) Text('• $item', style: AppTextStyles.bodyS),
        ],
        if (analysis.concerns.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text('Perlu perhatian', style: AppTextStyles.labelL),
          for (final item in analysis.concerns) Text('• $item', style: AppTextStyles.bodyS),
        ],
        if (analysis.nextStep.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text('Saran periode berikutnya', style: AppTextStyles.labelL),
          Text(analysis.nextStep, style: AppTextStyles.bodyM),
        ],
        const SizedBox(height: 12),
        Text(
          'Analisis ini bersifat pendukung keputusan, bukan diagnosis. '
          'Diskusikan dengan terapis pendamping.',
          style: AppTextStyles.caption,
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => setState(() => _analysis = null),
            child: const Text('Tutup'),
          ),
        ),
      ],
    );
  }

  Future<void> _fetchAnalysis() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final child = await ref.read(currentChildProvider.future);
      if (child == null) throw StateError('Profil anak belum tersedia.');
      final logs = await ref.read(logsForChildProvider(child.id).future);
      final analysis =
          await ref.read(aiServiceProvider).analyseProgress(child: child, recentLogs: logs);
      if (mounted) setState(() => _analysis = analysis);
    } catch (e) {
      if (mounted) setState(() => _error = 'Gagal membuat analisis: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildRecommendationCard(Recommendation rec) {
    final custom = ref.watch(currentChildProvider).valueOrNull?.customActivities ?? const [];
    final catalogItem = ActivityCatalog.byId(rec.activityId, custom);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.neutral200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ActivityImage(catalogItem.image),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(catalogItem.title, style: AppTextStyles.headingM),
                  Text(
                    'Keyakinan: ${(rec.confidence * 100).round()}%',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(rec.reason, style: AppTextStyles.bodyM),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.tips_and_updates_outlined, size: 18, color: AppColors.teal500),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'Saran strategi: ${_promptStrategyLabels[rec.recommendedPrompt]}',
                style: AppTextStyles.bodyS,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _recommendation = null),
                child: const Text('Abaikan'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                style: FilledButton.styleFrom(backgroundColor: AppColors.teal500),
                onPressed: () => _acceptRecommendation(rec),
                child: const Text('Tambahkan'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _fetchRecommendation() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final child = await ref.read(currentChildProvider.future);
      if (child == null) throw StateError('Profil anak belum tersedia.');
      final logs = await ref.read(logsForChildProvider(child.id).future);
      final rec = await ref.read(aiServiceProvider).recommendActivity(child: child, recentLogs: logs);
      if (mounted) setState(() => _recommendation = rec);
    } catch (e) {
      if (mounted) setState(() => _error = 'Gagal mendapatkan rekomendasi: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _acceptRecommendation(Recommendation rec) async {
    final child = await ref.read(currentChildProvider.future);
    if (child == null) return;
    
    final schedules = await ref.read(schedulesForChildProvider(child.id).future);
    if (schedules.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Buat papan jadwal terlebih dahulu di SproutPlan.')),
        );
      }
      return;
    }

    final selectedSchedule = await showDialog<Schedule>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Pilih Papan Target', style: AppTextStyles.headingM),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: schedules.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final schedule = schedules[index];
                return ListTile(
                  title: Text(schedule.title, style: AppTextStyles.headingS),
                  subtitle: Text(_boardTypeLabel(schedule.type), style: AppTextStyles.bodyS),
                  onTap: () => Navigator.of(context).pop(schedule),
                );
              }
            )
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
          ]
        );
      }
    );

    if (selectedSchedule == null) return;

    final catalogItem = ActivityCatalog.byId(rec.activityId, child.customActivities);
    final start = DateTime.now().add(const Duration(hours: 1));
    final newActivity = Activity(
      id: '${selectedSchedule.id}-${selectedSchedule.activities.length}-${DateTime.now().millisecondsSinceEpoch}',
      title: catalogItem.title,
      icon: catalogItem.image,
      category: catalogItem.category,
      startTime: start,
      endTime: start.add(const Duration(minutes: 15)),
    );
    
    final updated = selectedSchedule.copyWith(
      activities: [...selectedSchedule.activities, newActivity]
    );
    
    await ref.read(scheduleServiceProvider).saveSchedule(updated);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${catalogItem.title} berhasil ditambahkan ke ${selectedSchedule.title}!')),
      );
      setState(() => _recommendation = null);
    }
  }
}
