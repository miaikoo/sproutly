import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/data/activity_catalog.dart';
import '../../../core/navigation/app_routes.dart';
import '../../../core/services/child_service.dart';
import '../../../core/services/schedule_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/enums.dart';
import '../../../models/schedule.dart';
import '../../../shared/widgets/custom_icon.dart';
import '../../../shared/widgets/slot_box.dart';
import 'board_editor.dart';
import '../../../core/theme/app_text_styles.dart';

class CreateEmotionBoardPage extends ConsumerStatefulWidget {
  const CreateEmotionBoardPage({super.key, this.boardToEdit});

  final Schedule? boardToEdit;

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
  void initState() {
    super.initState();
    if (widget.boardToEdit != null) {
      _title = widget.boardToEdit!.title;
      final customList = ref.read(currentChildProvider).valueOrNull?.customActivities ?? const [];
      final list = widget.boardToEdit!.activities;
      if (list.isNotEmpty) {
        final emotionItem = ActivityCatalog.allWith(customList).firstWhere(
          (item) => item.image == list[0].icon || item.title == list[0].title,
          orElse: () => ActivityCatalog.items.first,
        );
        _emotionId = emotionItem.id;
      }
      
      final thenIds = widget.boardToEdit!.thenActivityIds;
      if (thenIds.isNotEmpty) {
        _thenAId = thenIds[0];
        if (thenIds.length > 1) {
          _thenBId = thenIds[1];
        }
        final copingActivities = list.sublist(1).where((act) {
          final catalogItem = ActivityCatalog.allWith(customList).firstWhere(
            (item) => item.image == act.icon || item.title == act.title,
            orElse: () => ActivityCatalog.items.first,
          );
          return !thenIds.contains(catalogItem.id);
        }).toList();
        
        if (copingActivities.isNotEmpty) {
          final copingA = ActivityCatalog.allWith(customList).firstWhere(
            (item) => item.image == copingActivities[0].icon || item.title == copingActivities[0].title,
            orElse: () => ActivityCatalog.items.first,
          );
          _copingAId = copingA.id;
        }
        if (copingActivities.length > 1) {
          final copingB = ActivityCatalog.allWith(customList).firstWhere(
            (item) => item.image == copingActivities[1].icon || item.title == copingActivities[1].title,
            orElse: () => ActivityCatalog.items.first,
          );
          _copingBId = copingB.id;
        }
      } else {
        final remaining = list.sublist(1);
        if (remaining.isNotEmpty) {
          final copingA = ActivityCatalog.allWith(customList).firstWhere(
            (item) => item.image == remaining[0].icon || item.title == remaining[0].title,
            orElse: () => ActivityCatalog.items.first,
          );
          _copingAId = copingA.id;
        }
        if (remaining.length == 2) {
          final thenA = ActivityCatalog.allWith(customList).firstWhere(
            (item) => item.image == remaining[1].icon || item.title == remaining[1].title,
            orElse: () => ActivityCatalog.items.first,
          );
          _thenAId = thenA.id;
        } else if (remaining.length == 3) {
          final copingB = ActivityCatalog.allWith(customList).firstWhere(
            (item) => item.image == remaining[1].icon || item.title == remaining[1].title,
            orElse: () => ActivityCatalog.items.first,
          );
          _copingBId = copingB.id;
          final thenA = ActivityCatalog.allWith(customList).firstWhere(
            (item) => item.image == remaining[2].icon || item.title == remaining[2].title,
            orElse: () => ActivityCatalog.items.first,
          );
          _thenAId = thenA.id;
        } else if (remaining.length >= 4) {
          final copingB = ActivityCatalog.allWith(customList).firstWhere(
            (item) => item.image == remaining[1].icon || item.title == remaining[1].title,
            orElse: () => ActivityCatalog.items.first,
          );
          _copingBId = copingB.id;
          final thenA = ActivityCatalog.allWith(customList).firstWhere(
            (item) => item.image == remaining[2].icon || item.title == remaining[2].title,
            orElse: () => ActivityCatalog.items.first,
          );
          _thenAId = thenA.id;
          final thenB = ActivityCatalog.allWith(customList).firstWhere(
            (item) => item.image == remaining[3].icon || item.title == remaining[3].title,
            orElse: () => ActivityCatalog.items.first,
          );
          _thenBId = thenB.id;
        }
      }
    }
  }

  /// The child's own activity cards, so a `custom-*` id in a slot
  /// resolves to the right picture.
  List<ActivityCatalogItem> get _custom =>
      ref.watch(currentChildProvider).valueOrNull?.customActivities ?? const [];

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

                              SlotBox(
                                activityId: _emotionId,
                                // Locked to emotion cards: this slot names the
                                // feeling the board is about.
                                onTap: () => _pick(
                                  (id) => _emotionId = id,
                                  only: ActivityCategory.emotion,
                                  title: 'Pilih Emosi',
                                ),
                                size: 120,
                                accent: AppColors.peach500,
                                customActivities: _custom,
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
                                      SlotBox(
                                        activityId: _copingAId,
                                        onTap: () => _pick((id) => _copingAId = id),
                                        size: 120,
                                        accent: AppColors.peach500,
                                        customActivities: _custom,
                                      ),
                                      const Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 16),
                                        child: Text(
                                          'Atau',
                                          style: AppTextStyles.displayM,
                                        ),
                                      ),
                                      SlotBox(
                                        activityId: _copingBId,
                                        onTap: () => _pick((id) => _copingBId = id),
                                        size: 120,
                                        accent: AppColors.peach500,
                                        customActivities: _custom,
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
            color: AppColors.peach500,
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
            color: AppColors.peach500,
            tooltip: 'Simpan papan',
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
              SlotBox(
                activityId: _thenAId,
                onTap: () => _pick((id) => _thenAId = id),
                size: 120,
                accent: AppColors.peach500,
                onLight: false,
                customActivities: _custom,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Atau',
                  style: AppTextStyles.headingL.copyWith(color: AppColors.white),
                ),
              ),
              SlotBox(
                activityId: _thenBId,
                onTap: () => _pick((id) => _thenBId = id),
                size: 120,
                accent: AppColors.peach500,
                onLight: false,
                customActivities: _custom,
              ),
            ],
          ),
        ],
      ),
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
            thenActivityIds: [?_thenAId, ?_thenBId],
            existingId: widget.boardToEdit?.id,
          );

      if (mounted) context.go(AppRoutes.board);
    } catch (e) {
      if (mounted) showBoardSnack(context, 'Gagal menyimpan: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
