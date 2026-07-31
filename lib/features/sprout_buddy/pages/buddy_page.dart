import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/data/activity_catalog.dart';
import '../../../core/navigation/app_routes.dart';
import '../../../core/services/ai_service.dart';
import '../../../core/services/child_service.dart';
import '../../../core/services/behaviour_log_service.dart';
import '../../../core/services/schedule_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/activity.dart';
import '../../../models/child.dart';
import '../../../models/enums.dart';
import '../../../models/recommendation.dart';
import '../../../models/schedule.dart';
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
    final childAsync = ref.watch(currentChildProvider);
    final child = childAsync.valueOrNull;

    return Scaffold(
      backgroundColor: const Color(0xFF7EA29C),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Stack(
              children: [
                // 1. Winding Map & Path Background
                Positioned.fill(
                  child: _buildMapCanvas(context),
                ),

                // 2. Header (Child Name, Date, Coin Pill, Shop Button)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: _buildHeader(child),
                ),

                // 3. SproutGuide AI Action Button / Card overlay
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: _buildSproutGuideTrigger(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Child? child) {
    final name = child?.name ?? 'John Doe';
    const dateStr = 'Perjalanan sejak 16/07/2026';
    final points = child?.points ?? 28;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF7EA29C).withValues(alpha: 0.95),
            const Color(0xFF7EA29C).withValues(alpha: 0.6),
            const Color(0xFF7EA29C).withValues(alpha: 0.0),
          ],
          stops: const [0.0, 0.6, 1.0],
        ),
      ),
      padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 28),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: AppTextStyles.displayL.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                dateStr,
                style: AppTextStyles.bodyM.copyWith(
                  color: const Color(0xFF2C3E3A),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Row(
            children: [
              // Coin Pill Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF70938D),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      offset: const Offset(0, 3),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🪙', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 6),
                    Text(
                      '$points',
                      style: AppTextStyles.headingM.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Shop Circle Button
              GestureDetector(
                onTap: () => context.push(AppRoutes.companionStore),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFC4806C), // Terracotta / Peach 500
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        offset: const Offset(0, 4),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.storefront_rounded,
                    color: AppColors.white,
                    size: 26,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMapCanvas(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);

        // Node locations (normalized offset 0..1)
        final nodePosList = [
          const Offset(0.50, 0.16),
          const Offset(0.80, 0.32),
          const Offset(0.20, 0.48),
          const Offset(0.50, 0.64),
          const Offset(0.78, 0.80),
        ];

        return Stack(
          children: [
            // Custom Painter for winding road, dashed line & sprouts
            CustomPaint(
              size: size,
              painter: BuddyPathPainter(),
            ),

            // Stepping Stone Nodes
            for (int i = 0; i < nodePosList.length; i++)
              _buildNodeDisk(
                pos: nodePosList[i],
                size: size,
                isActive: i == 4, // 5th node is active
              ),

            // Sproutly Buddy Mascot standing on Node 5 (active node)
            Positioned(
              left: nodePosList[4].dx * size.width - 65,
              top: nodePosList[4].dy * size.height - 115,
              child: SizedBox(
                width: 130,
                height: 130,
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    Image.asset(
                      'assets/images/Bahagia.png',
                      width: 120,
                      height: 120,
                      fit: BoxFit.contain,
                    ),
                    const Positioned(
                      top: 10,
                      left: -2,
                      child: Text('✨', style: TextStyle(fontSize: 20)),
                    ),
                    const Positioned(
                      top: 18,
                      right: -2,
                      child: Text('✨', style: TextStyle(fontSize: 20)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildNodeDisk({required Offset pos, required Size size, bool isActive = false}) {
    final x = pos.dx * size.width;
    final y = pos.dy * size.height;

    return Positioned(
      left: x - 45,
      top: y - 25,
      child: Container(
        width: 90,
        height: 50,
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF9ABCB6) : const Color(0xFFB5CCDE),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: isActive ? const Color(0xFF6C8B85) : const Color(0xFF869EAF),
              offset: const Offset(0, 8),
              blurRadius: 0,
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              offset: const Offset(0, 10),
              blurRadius: 6,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSproutGuideTrigger() {
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${catalogItem.title} berhasil ditambahkan ke ${schedule.title}!')),
      );
      setState(() => _recommendation = null);
    }
  }
}

class BuddyPathPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Background fill
    final bgPaint = Paint()..color = const Color(0xFF7EA29C);
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), bgPaint);

    // 2. Define path control points
    final p0 = Offset(w * 0.40, -h * 0.05);
    final p1 = Offset(w * 0.50, h * 0.16); // Node 1
    final p2 = Offset(w * 0.80, h * 0.32); // Node 2
    final p3 = Offset(w * 0.20, h * 0.48); // Node 3
    final p4 = Offset(w * 0.50, h * 0.64); // Node 4
    final p5 = Offset(w * 0.78, h * 0.80); // Node 5 (active)
    final p6 = Offset(w * 0.50, h * 1.05);

    final path = Path();
    path.moveTo(p0.dx, p0.dy);

    path.cubicTo(w * 0.45, h * 0.05, w * 0.45, h * 0.09, p1.dx, p1.dy);
    path.cubicTo(w * 0.65, h * 0.22, w * 0.85, h * 0.25, p2.dx, p2.dy);
    path.cubicTo(w * 0.75, h * 0.40, w * 0.25, h * 0.40, p3.dx, p3.dy);
    path.cubicTo(w * 0.15, h * 0.56, w * 0.35, h * 0.58, p4.dx, p4.dy);
    path.cubicTo(w * 0.70, h * 0.70, w * 0.85, h * 0.74, p5.dx, p5.dy);
    path.cubicTo(w * 0.70, h * 0.90, w * 0.55, h * 0.98, p6.dx, p6.dy);

    // Cream Ribbon path
    final ribbonPaint = Paint()
      ..color = const Color(0xFFE8DFC0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w > 600 ? 160 : 110
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, ribbonPaint);

    // Dashed center line in terracotta color
    final dashedPaint = Paint()
      ..color = const Color(0xFFC4806C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;

    final pathMetrics = path.computeMetrics();
    for (final metric in pathMetrics) {
      double distance = 0.0;
      const double dashWidth = 14.0;
      const double dashSpace = 10.0;
      bool draw = true;
      while (distance < metric.length) {
        final len = draw ? dashWidth : dashSpace;
        if (draw) {
          canvas.drawPath(
            metric.extractPath(distance, (distance + len).clamp(0, metric.length)),
            dashedPaint,
          );
        }
        distance += len;
        draw = !draw;
      }
    }

    // Sprouts decoration in grass areas
    _drawSprout(canvas, Offset(w * 0.12, h * 0.28));
    _drawSprout(canvas, Offset(w * 0.85, h * 0.46));
    _drawSprout(canvas, Offset(w * 0.10, h * 0.74));
    _drawSprout(canvas, Offset(w * 0.48, h * 0.75));
  }

  void _drawSprout(Canvas canvas, Offset center) {
    final paint = Paint()
      ..color = const Color(0xFF6B8B75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = const Color(0xFF9DB8A0)
      ..style = PaintingStyle.fill;

    // Stem
    canvas.drawLine(center, Offset(center.dx, center.dy - 20), paint);

    // Left leaf
    final leftLeaf = Path()
      ..moveTo(center.dx, center.dy - 16)
      ..cubicTo(center.dx - 12, center.dy - 24, center.dx - 16, center.dy - 12, center.dx, center.dy - 16);
    canvas.drawPath(leftLeaf, fillPaint);
    canvas.drawPath(leftLeaf, paint);

    // Right leaf
    final rightLeaf = Path()
      ..moveTo(center.dx, center.dy - 18)
      ..cubicTo(center.dx + 12, center.dy - 26, center.dx + 16, center.dy - 14, center.dx, center.dy - 18);
    canvas.drawPath(rightLeaf, fillPaint);
    canvas.drawPath(rightLeaf, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
