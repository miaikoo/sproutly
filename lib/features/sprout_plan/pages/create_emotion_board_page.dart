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
import '../../../shared/widgets/activity_image.dart';
import '../../../core/theme/app_text_styles.dart';

class CreateEmotionBoardPage extends ConsumerStatefulWidget {
  const CreateEmotionBoardPage({super.key});

  @override
  ConsumerState<CreateEmotionBoardPage> createState() => _CreateEmotionBoardPageState();
}

class _CreateEmotionBoardPageState extends ConsumerState<CreateEmotionBoardPage> {
  String _title = 'Papan Emosi';
  String? _emotionId;
  String? _copingAId;
  String? _copingBId;
  String? _thenAId;
  String? _thenBId;
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
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              _buildTitleInput(),
                              const SizedBox(height: 32),

                              Text(
                                'Ketika aku merasa',
                                style: AppTextStyles.headingL,
                              ),
                              const SizedBox(height: 16),

                              _buildAddBox(
                                borderColor: AppColors.peach500,
                                activityId: _emotionId,
                                // Locked to emotion cards: this slot names the
                                // feeling the board is about.
                                onTap: () => _pick(
                                  (id) => _emotionId = id,
                                  only: ActivityCategory.emotion,
                                  title: 'Pilih Emosi',
                                ),
                              ),
                              const SizedBox(height: 24),

                              Column(
                                children: [
                                  Text(
                                    'aku bisa...',
                                    style: AppTextStyles.headingL,
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      _buildAddBox(
                                        borderColor: AppColors.peach500,
                                        activityId: _copingAId,
                                        onTap: () => _pick((id) => _copingAId = id),
                                      ),
                                      const Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 16),
                                        child: Text(
                                          'Atau',
                                          style: AppTextStyles.displayM,
                                        ),
                                      ),
                                      _buildAddBox(
                                        borderColor: AppColors.peach500,
                                        activityId: _copingBId,
                                        onTap: () => _pick((id) => _copingBId = id),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                _buildBottomSection(),
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
          GestureDetector(
            onTap: () => context.pop(),
            child: const CustomIcon(
              assetName: 'assets/icons/solar_alt-arrow-left-outline.svg',
              size: 28,
              color: AppColors.neutral800,
            ),
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
          GestureDetector(
            onTap: _editTitle,
            child: const CustomIcon(
              assetName: 'assets/icons/solar_pen-linear.svg',
              size: 28,
              color: AppColors.peach500,
            ),
          ),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const CustomIcon(
                    assetName: 'assets/icons/lucide_save.svg',
                    size: 28,
                    color: AppColors.peach500,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleInput() {
    return GestureDetector(
      onTap: _editTitle,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: AppColors.peach100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                _title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.displayM,
              ),
            ),
            const CustomIcon(
              assetName: 'assets/icons/solar_pen-linear.svg',
              size: 24,
              color: AppColors.neutral800,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: const BoxDecoration(
        color: AppColors.peach500,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          Text(
            'kemudian aku bisa melakukan...',
            textAlign: TextAlign.center,
            style: AppTextStyles.headingL.copyWith(color: AppColors.white),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildAddBox(
                borderColor: AppColors.white,
                activityId: _thenAId,
                onTap: () => _pick((id) => _thenAId = id),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Atau',
                  style: AppTextStyles.headingL.copyWith(color: AppColors.white),
                ),
              ),
              _buildAddBox(
                borderColor: AppColors.white,
                activityId: _thenBId,
                onTap: () => _pick((id) => _thenBId = id),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddBox({
    required Color borderColor,
    required String? activityId,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        height: 120,
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.3),
          border: Border.all(color: borderColor, width: 2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: activityId == null
            ? Center(child: Icon(Icons.add, size: 40, color: borderColor))
            : _slotPreview(activityId),
      ),
    );
  }

  Widget _slotPreview(String activityId) {
    final item = ActivityCatalog.byId(activityId);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(child: ActivityImage(item.image)),
        Text(
          item.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.caption,
        ),
      ],
    );
  }

  Future<void> _editTitle() async {
    final result = await promptForTitle(context, current: _title);
    if (result != null) setState(() => _title = result);
  }

  Future<void> _pick(
    void Function(String id) assign, {
    ActivityCategory? only,
    String? title,
  }) async {
    final result = await showActivityPicker(context, only: only, title: title);
    if (result != null) setState(() => assign(result));
  }

  Future<void> _save() async {
    if (_emotionId == null) {
      showBoardSnack(context, 'Pilih dulu emosi yang ingin didampingi.');
      return;
    }
    final coping = [_copingAId, _copingBId].whereType<String>().toList();
    if (coping.isEmpty) {
      showBoardSnack(context, 'Pilih minimal satu aktivitas untuk menenangkan diri.');
      return;
    }

    setState(() => _isSaving = true);
    try {
      final child = await ref.read(currentChildProvider.future);
      if (child == null) throw StateError('Profil anak belum tersedia.');

      // Card order carries the board's meaning: the emotion first, then the
      // coping options, then the reward activities.
      final ordered = [_emotionId!, ...coping, ...[_thenAId, _thenBId].whereType<String>()];
      final now = DateTime.now();

      await ref.read(scheduleServiceProvider).createBoard(
            childId: child.id,
            title: _title,
            type: BoardType.emotion,
            customActivities: child.customActivities,
            picks: [
              for (var i = 0; i < ordered.length; i++)
                (catalogId: ordered[i], start: now.add(Duration(minutes: i))),
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
