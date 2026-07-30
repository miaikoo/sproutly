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
import 'board_editor.dart';

/// Filter chip label → the board type it shows. 'Semua' shows everything.
const _boardFilters = <String, BoardType?>{
  'Semua': null,
  'Jadwal': BoardType.schedule,
  'Pertama-Kemudian': BoardType.firstThen,
  'Menunggu': BoardType.waiting,
  'Emosi': BoardType.emotion,
};

class BoardPage extends ConsumerStatefulWidget {
  const BoardPage({super.key});

  @override
  ConsumerState<BoardPage> createState() => _BoardPageState();
}

class _BoardPageState extends ConsumerState<BoardPage> {
  String _selectedFilter = 'Semua';

  @override
  Widget build(BuildContext context) {
    final childAsync = ref.watch(currentChildProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      // One primary action on this screen, which is what a FAB is for.
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.createBoard),
        backgroundColor: AppColors.actionPrimary,
        foregroundColor: AppColors.onFilled,
        icon: Icon(Icons.add),
        label: Text('Buat papan'),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 840),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    AppSpacing.md,
                    AppSpacing.xl,
                    AppSpacing.sm,
                  ),
                  child: Text('Papan saya', style: AppTextStyles.displayL),
                ),
                _buildFilterChips(),
                AppSpacing.gapMD,
                Expanded(
                  child: childAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => _message('Gagal memuat profil anak: $e'),
                    data: (child) => child == null
                        ? _message('Profil anak belum tersedia.')
                        : _buildBoardList(child.id),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _message(String text) {
    return Padding(
      padding: AppSpacing.pagePadding,
      child: Text(text, style: AppTextStyles.bodyM, textAlign: TextAlign.center),
    );
  }

  Widget _buildBoardList(String childId) {
    final schedulesAsync = ref.watch(schedulesForChildProvider(childId));

    return schedulesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => _message('Gagal memuat papan: $e'),
      data: (schedules) {
        final wanted = _boardFilters[_selectedFilter];
        final visible =
            wanted == null ? schedules : schedules.where((s) => s.type == wanted).toList();

        if (visible.isEmpty) {
          return _EmptyBoards(
            isFirstEver: schedules.isEmpty,
            filterLabel: _selectedFilter,
            onCreate: () => context.push(AppRoutes.createBoard),
          );
        }

        return LayoutBuilder(builder: (context, constraints) {
          final columns = (constraints.maxWidth / 168).floor().clamp(2, 5);

          return GridView.builder(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              0,
              AppSpacing.xl,
              // Clear of the FAB.
              88,
            ),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: AppSpacing.md,
              mainAxisSpacing: AppSpacing.md,
              childAspectRatio: 0.82,
            ),
            itemCount: visible.length,
            itemBuilder: (context, index) => BoardTile(schedule: visible[index]),
          );
        });
      },
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Row(
        children: _boardFilters.keys.map((label) {
          final isSelected = _selectedFilter == label;
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.xs),
            child: ChoiceChip(
              label: Text(label),
              selected: isSelected,
              onSelected: (_) => setState(() => _selectedFilter = label),
              labelStyle: AppTextStyles.bodyS.copyWith(
                color: isSelected ? AppColors.onFilled : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Teaches what a board is on first run, rather than saying "nothing here".
class _EmptyBoards extends StatelessWidget {
  const _EmptyBoards({
    required this.isFirstEver,
    required this.filterLabel,
    required this.onCreate,
  });

  final bool isFirstEver;
  final String filterLabel;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: AppColors.teal100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.dashboard_customize_outlined,
                color: AppColors.teal900,
                size: 32,
              ),
            ),
            AppSpacing.gapLG,
            Text(
              isFirstEver ? 'Belum ada papan' : 'Belum ada papan $filterLabel',
              style: AppTextStyles.headingL,
              textAlign: TextAlign.center,
            ),
            AppSpacing.gapXS,
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),
              child: Text(
                isFirstEver
                    ? 'Papan adalah kumpulan kartu bergambar yang menuntun anak '
                        'menjalani rutinitas — satu langkah pada satu waktu.'
                    : 'Buat papan jenis ini, atau pilih filter Semua untuk melihat '
                        'papan yang sudah ada.',
                style: AppTextStyles.bodyM.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
            ),
            AppSpacing.gapLG,
            FilledButton.icon(
              onPressed: onCreate,
              icon: Icon(Icons.add),
              label: Text('Buat papan'),
            ),
          ],
        ),
      ),
    );
  }
}
