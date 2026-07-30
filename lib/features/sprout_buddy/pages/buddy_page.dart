import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/activity_catalog.dart';
import '../../../core/services/ai_service.dart';
import '../../../core/services/child_service.dart';
import '../../../core/services/behaviour_log_service.dart';
import '../../../core/services/schedule_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/activity.dart';
import '../../../models/enums.dart';
import '../../../models/recommendation.dart';
import '../../../models/schedule.dart';
import '../../../shared/widgets/custom_icon.dart';
import '../../../shared/widgets/activity_image.dart';

/// How the AI's suggested prompting strategy reads to a parent.
const _promptStrategyLabels = {
  PromptType.visual: 'tunjukkan kartu visual',
  PromptType.voice: 'bacakan instruksi dengan suara',
  PromptType.text: 'beri instruksi singkat tertulis',
};

class BuddyPage extends ConsumerStatefulWidget {
  const BuddyPage({super.key});

  @override
  ConsumerState<BuddyPage> createState() => _BuddyPageState();
}

class _BuddyPageState extends ConsumerState<BuddyPage> {
  Recommendation? _recommendation;
  ProgressAnalysis? _analysis;
  bool _isLoading = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Stack(
              children: [
                _buildMapArea(),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: _buildHeader(),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _buildRecommendationPanel(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.background,
            AppColors.background.withValues(alpha: 0.8),
            AppColors.background.withValues(alpha: 0.0),
          ],
          stops: const [0.3, 0.7, 1.0],
        ),
      ),
      padding: const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 48),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SproutGuide',
                style: AppTextStyles.displayL,
              ),
              const SizedBox(height: 4),
              Text(
                'Rekomendasi aktivitas berbasis AI',
                style: AppTextStyles.headingS,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMapArea() {
    return ListView.builder(
      reverse: true,
      itemCount: 5,
      itemBuilder: (context, index) {
        return _buildMapChunk(context, chunkIndex: index);
      },
    );
  }

  Widget _buildMapChunk(BuildContext context, {required int chunkIndex}) {
    return AspectRatio(
      aspectRatio: 10 / 16,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final h = constraints.maxHeight;

          final nodes = [
            const Offset(0.65, 0.85),
            const Offset(0.18, 0.60),
            const Offset(0.78, 0.35),
            const Offset(0.20, 0.10),
          ];

          return Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  'assets/images/buddy_background.png',
                  fit: BoxFit.cover,
                ),
              ),
              ...nodes.asMap().entries.map((e) {
                final isActive = chunkIndex == 0 && e.key == 0;

                return Positioned(
                  left: e.value.dx * w - 45,
                  top: e.value.dy * h - 30,
                  child: _buildNode(isActive: isActive),
                );
              }),
              if (chunkIndex == 0)
                Positioned(
                  left: nodes[0].dx * w - 100,
                  top: nodes[0].dy * h - 220,
                  child: Image.asset(
                    'assets/images/Bahagia.png',
                    width: 200,
                    height: 250,
                    fit: BoxFit.contain,
                  ),
                ),
            ],
          );
        }
      ),
    );
  }

  Widget _buildNode({bool isActive = false}) {
    return Container(
      width: 100,
      height: 70,
      decoration: ShapeDecoration(
        color: isActive ? AppColors.neutral100 : AppColors.teal300,
        shape: OvalBorder(
          side: BorderSide(
            color: isActive ? AppColors.neutral300 : AppColors.teal500,
            width: 3,
          ),
        ),
        shadows: [
          BoxShadow(
            color: isActive ? AppColors.neutral300 : AppColors.teal500,
            offset: const Offset(0, 8),
            blurRadius: 0,
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationPanel() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 12)],
      ),
      child: switch ((_recommendation, _analysis)) {
        (final Recommendation rec, _) => _buildRecommendationCard(rec),
        (_, final ProgressAnalysis analysis) => _buildAnalysisCard(analysis),
        _ => _buildIdleState(),
      },
    );
  }

  Widget _buildIdleState() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_error != null) ...[
          Text(_error!, style: AppTextStyles.bodyS.copyWith(color: AppColors.error)),
          const SizedBox(height: 8),
        ],
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.peach500),
            onPressed: _fetchRecommendation,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CustomIcon(
                  assetName: 'assets/icons/solar_clipboard-add-outline.svg',
                  size: 20,
                  color: AppColors.white,
                ),
                const SizedBox(width: 8),
                Text('Dapatkan Rekomendasi', style: AppTextStyles.headingM.copyWith(color: AppColors.white)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _fetchAnalysis,
            icon: Icon(Icons.insights_outlined, size: 20),
            label: Text('Analisis Perkembangan'),
          ),
        ),
      ],
    );
  }

  /// RF-10. Framed as input for the parent's decision, never as a verdict.
  Widget _buildAnalysisCard(ProgressAnalysis analysis) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
            child: Text('Tutup'),
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
        // The AI advises a prompting strategy; the parent decides whether to use
        // it. Showing it is the whole point of a decision-support system.
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
                child: Text('Abaikan'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                style: FilledButton.styleFrom(backgroundColor: AppColors.teal500),
                onPressed: () => _acceptRecommendation(rec),
                child: Text('Tambahkan'),
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

    final schedule = schedules.first;
    final catalogItem = ActivityCatalog.byId(rec.activityId, child.customActivities);
    final start = DateTime.now().add(const Duration(hours: 1));
    final newActivity = Activity(
      id: '${schedule.id}-${schedule.activities.length}-${DateTime.now().millisecondsSinceEpoch}',
      title: catalogItem.title,
      icon: catalogItem.image,
      category: catalogItem.category,
      startTime: start,
      endTime: start.add(const Duration(minutes: 15)),
    );
    final updated = Schedule(
      id: schedule.id,
      childId: schedule.childId,
      title: schedule.title,
      date: schedule.date,
      activities: [...schedule.activities, newActivity],
    );
    await ref.read(scheduleServiceProvider).saveSchedule(updated);

    if (mounted) {
      setState(() => _recommendation = null);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${catalogItem.title} ditambahkan ke ${schedule.title}.')),
      );
    }
  }
}
