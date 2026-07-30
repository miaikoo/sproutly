import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/navigation/app_routes.dart';
import '../../../core/services/child_service.dart';
import '../../../core/services/schedule_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
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
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 840),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title with a "+" affordance on the right, as in the design —
                // not a floating action button.
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    AppSpacing.md,
                    AppSpacing.md,
                    AppSpacing.md,
                  ),
                  child: Row(
                    children: [
                      Expanded(child: Text('Papan saya', style: AppTextStyles.displayL)),
                      IconButton(
                        onPressed: () => context.push(AppRoutes.createBoard),
                        icon: const Icon(Icons.add, size: 30),
                        color: AppColors.peach500,
                        tooltip: 'Buat papan',
                      ),
                    ],
                  ),
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
              AppSpacing.xxl,
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

  /// Filter pills sitting inside a tinted track, as in the design.
  ///
  /// The unselected pills keep the mockup's `teal500` fill but take dark ink
  /// instead of white — white on `teal500` measures 2.79:1. The selected pill is
  /// `teal700`, the step the design system's own contrast table asks for.
  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xs),
        decoration: const BoxDecoration(
          color: AppColors.teal100,
          borderRadius: BorderRadius.all(AppRadius.pill),
        ),
        child: Row(
          children: [
            for (final label in _boardFilters.keys)
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.xxs),
                child: _FilterPill(
                  label: label,
                  selected: _selectedFilter == label,
                  onTap: () => setState(() => _selectedFilter = label),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected ? AppColors.teal700 : AppColors.teal500,
        borderRadius: const BorderRadius.all(AppRadius.pill),
        child: InkWell(
          borderRadius: const BorderRadius.all(AppRadius.pill),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Text(
              label,
              style: AppTextStyles.buttonM.copyWith(
                color: selected ? AppColors.white : AppColors.teal900,
              ),
            ),
          ),
        ),
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
