import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/navigation/app_routes.dart';
import '../../../core/services/child_service.dart';
import '../../../core/services/schedule_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/enums.dart';
import '../../../models/schedule.dart';
import '../../../shared/widgets/custom_icon.dart';
import 'board_editor.dart';

class BoardPage extends ConsumerStatefulWidget {
  const BoardPage({super.key});

  @override
  ConsumerState<BoardPage> createState() => _BoardPageState();
}

/// Filter chip label → the board type it shows. 'Semua' shows everything.
const _boardFilters = <String, BoardType?>{
  'Semua': null,
  'Jadwal': BoardType.schedule,
  'Pertama-Kemudian': BoardType.firstThen,
  'Menunggu': BoardType.waiting,
  'Emosi': BoardType.emotion,
};

class _BoardPageState extends ConsumerState<BoardPage> {
  String _selectedFilter = 'Semua';

  @override
  Widget build(BuildContext context) {
    final childAsync = ref.watch(currentChildProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: SingleChildScrollView(
              padding: AppSpacing.pagePadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  AppSpacing.gapMD,
                  _buildFilterChips(),
                  AppSpacing.gapXL,
                  childAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Text('Gagal memuat profil anak: $e', style: AppTextStyles.bodyM),
                    data: (child) {
                      if (child == null) {
                        return Text('Profil anak belum tersedia.', style: AppTextStyles.bodyM);
                      }
                      return _buildBoardList(child.id);
                    },
                  ),
                  AppSpacing.gapXXL,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBoardList(String childId) {
    final schedulesAsync = ref.watch(schedulesForChildProvider(childId));

    return schedulesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text('Gagal memuat papan: $e', style: AppTextStyles.bodyM),
      data: (schedules) {
        final wanted = _boardFilters[_selectedFilter];
        final visible =
            wanted == null ? schedules : schedules.where((s) => s.type == wanted).toList();

        if (visible.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Center(
              child: Text(
                schedules.isEmpty
                    ? 'Belum ada papan. Tekan + untuk membuat papan baru.'
                    : 'Belum ada papan $_selectedFilter.',
                style: AppTextStyles.bodyM,
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
        return _buildBoardGrid(visible);
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Papan saya', style: AppTextStyles.displayXL),
          GestureDetector(
            onTap: () => context.push(AppRoutes.createBoard),
            child: const CustomIcon(
              assetName: 'assets/icons/solar_clipboard-add-outline.svg',
              size: 32,
              color: AppColors.peach500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _boardFilters.keys.map((label) {
          final isSelected = _selectedFilter == label;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => setState(() => _selectedFilter = label),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF446860) : const Color(0xFF7EA29C),
                  borderRadius: BorderRadius.circular(36),
                ),
                child: Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 16,
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBoardGrid(List<Schedule> schedules) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemCount: schedules.length,
      itemBuilder: (context, index) {
        return _BoardCard(schedule: schedules[index]);
      },
    );
  }
}

class _BoardCard extends StatelessWidget {
  const _BoardCard({required this.schedule});
  final Schedule schedule;

  @override
  Widget build(BuildContext context) {
    final thumbnail = schedule.activities.isNotEmpty ? schedule.activities.first.icon : null;

    return GestureDetector(
      onTap: () => context.push(AppRoutes.boardDetailPath(schedule.id)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: boardColor(schedule.type),
                borderRadius: BorderRadius.circular(24),
              ),
              child: thumbnail != null
                  ? Image.asset(thumbnail, fit: BoxFit.contain)
                  : const Icon(Icons.event_note, color: AppColors.white, size: 40),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            schedule.title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
