import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/data/activity_catalog.dart';
import '../../../core/navigation/app_routes.dart';
import '../../../core/services/child_service.dart';
import '../../../core/services/schedule_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/enums.dart';
import '../../../shared/widgets/custom_icon.dart';
import 'board_editor.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/slot_box.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';

class CreateFirstThenBoardPage extends ConsumerStatefulWidget {
  const CreateFirstThenBoardPage({super.key});

  @override
  ConsumerState<CreateFirstThenBoardPage> createState() => _CreateFirstThenBoardPageState();
}

class _CreateFirstThenBoardPageState extends ConsumerState<CreateFirstThenBoardPage> {
  String _title = 'Papan Pertama-Kemudian';
  String? _firstId;
  String? _thenId;
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        _buildStepCard(
                          'pertama aku perlu...',
                          _firstId,
                          () => _pick((id) => _firstId = id),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: CustomIcon(
                            assetName: 'assets/icons/down_arrow.svg',
                            size: 40,
                            color: AppColors.actionPrimary,
                          ),
                        ),
                        _buildStepCard(
                          'kemudian aku bisa...',
                          _thenId,
                          () => _pick((id) => _thenId = id),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back_ios_new, size: 22),
            color: AppColors.textPrimary,
            tooltip: 'Kembali',
          ),
          const SizedBox(width: 16),
          Expanded(
            child: GestureDetector(
              onTap: _editTitle,
              child: Text(
                _title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.displayL,
              ),
            ),
          ),
          IconButton(
            onPressed: _editTitle,
            icon: const Icon(Icons.edit_outlined),
            color: AppColors.neutral800,
            tooltip: 'Ubah nama',
          ),
          const SizedBox(width: 16),
          IconButton(
            onPressed: _isSaving ? null : _save,
            icon: _isSaving
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save_outlined),
            color: AppColors.neutral800,
            tooltip: 'Simpan papan',
          ),
        ],
      ),
    );
  }

  Widget _buildStepCard(String label, String? activityId, VoidCallback onTap) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: const BoxDecoration(
        color: AppColors.steel100,
        borderRadius: BorderRadius.all(AppRadius.xl),
      ),
      child: Column(
        children: [
          Text(label, style: AppTextStyles.displayM),
          AppSpacing.gapLG,
          SizedBox(
            width: double.infinity,
            height: 160,
            child: SlotBox(
              activityId: activityId,
              onTap: onTap,
              accent: AppColors.steel500,
              customActivities: _custom,
            ),
          ),
        ],
      ),
    );
  }

  /// The child's own activity cards, so a `custom-*` id in a slot resolves to
  /// the right picture.
  List<ActivityCatalogItem> get _custom =>
      ref.watch(currentChildProvider).valueOrNull?.customActivities ?? const [];

  Future<void> _editTitle() async {
    final result = await promptForTitle(context, current: _title);
    if (result != null) setState(() => _title = result);
  }

  Future<void> _pick(void Function(String id) assign) async {
    final result = await showActivityPicker(context);
    if (result != null) setState(() => assign(result));
  }

  Future<void> _save() async {
    if (_firstId == null || _thenId == null) {
      showBoardSnack(context, 'Pilih aktivitas untuk kedua langkah sebelum menyimpan.');
      return;
    }

    setState(() => _isSaving = true);
    try {
      final child = await ref.read(currentChildProvider.future);
      if (child == null) throw StateError('Profil anak belum tersedia.');

      final now = DateTime.now();
      await ref.read(scheduleServiceProvider).createBoard(
            childId: child.id,
            title: _title,
            type: BoardType.firstThen,
            customActivities: child.customActivities,
            picks: [
              (catalogId: _firstId!, start: now),
              (catalogId: _thenId!, start: now.add(const Duration(minutes: 15))),
            ],
          );

      if (mounted) context.go(AppRoutes.board);
    } catch (e) {
      if (mounted) showBoardSnack(context, 'Gagal menyimpan: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
