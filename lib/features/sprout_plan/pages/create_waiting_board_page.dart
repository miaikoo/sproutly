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

class CreateWaitingBoardPage extends ConsumerStatefulWidget {
  const CreateWaitingBoardPage({super.key, this.boardToEdit});

  final Schedule? boardToEdit;

  @override
  ConsumerState<CreateWaitingBoardPage> createState() => _CreateWaitingBoardPageState();
}

class _CreateWaitingBoardPageState extends ConsumerState<CreateWaitingBoardPage> {
  String _title = 'Menunggu';
  String? _waitingForId;
  String? _thenAId;
  String? _thenBId;
  int _waitMinutes = 5;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.boardToEdit != null) {
      _title = widget.boardToEdit!.title;
      _waitMinutes = widget.boardToEdit!.waitMinutes ?? 5;
      final customList = ref.read(currentChildProvider).valueOrNull?.customActivities ?? const [];
      final list = widget.boardToEdit!.activities;
      if (list.isNotEmpty) {
        final waitingFor = ActivityCatalog.allWith(customList).firstWhere(
          (item) => item.image == list[0].icon || item.title == list[0].title,
          orElse: () => ActivityCatalog.items.first,
        );
        _waitingForId = waitingFor.id;
      }
      if (list.length > 1) {
        final thenA = ActivityCatalog.allWith(customList).firstWhere(
          (item) => item.image == list[1].icon || item.title == list[1].title,
          orElse: () => ActivityCatalog.items.first,
        );
        _thenAId = thenA.id;
      }
      if (list.length > 2) {
        final thenB = ActivityCatalog.allWith(customList).firstWhere(
          (item) => item.image == list[2].icon || item.title == list[2].title,
          orElse: () => ActivityCatalog.items.first,
        );
        _thenBId = thenB.id;
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
                                'Aku',
                                style: AppTextStyles.displayM,
                              ),
                              const SizedBox(height: 16),

                              SlotBox(
                                activityId: _waitingForId,
                                onTap: () => _pick((id) => _waitingForId = id),
                                size: 120,
                                accent: AppColors.olive500,
                                customActivities: _custom,
                              ),
                              const SizedBox(height: 16),

                              Text(
                                'selama',
                                style: AppTextStyles.displayM,
                              ),
                              const SizedBox(height: 24),

                              _buildTimerCircle(),
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
            color: AppColors.olive500,
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
            color: AppColors.olive500,
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
          color: AppColors.olive100,
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

  Widget _buildTimerCircle() {
    return GestureDetector(
      onTap: () async {
        final picked = await promptForWaitMinutes(context, current: _waitMinutes);
        if (picked != null) setState(() => _waitMinutes = picked);
      },
      child: Container(
        width: 200,
        height: 200,
        decoration: const BoxDecoration(
          color: AppColors.olive100,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.olive700,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              formatWait(_waitMinutes),
              style: AppTextStyles.displayL.copyWith(color: AppColors.white),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: const BoxDecoration(
        color: AppColors.olive500,
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
                accent: AppColors.olive500,
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
                accent: AppColors.olive500,
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

  Future<void> _pick(void Function(String id) assign) async {
    final result = await showActivityPicker(context);
    if (result != null) setState(() => assign(result));
  }

  Future<void> _save() async {
    if (_waitingForId == null) {
      showBoardSnack(context, 'Pilih dulu aktivitas yang sedang ditunggu.');
      return;
    }
    // At least one reward option must exist, otherwise the board has no payoff
    // to show the child after the wait.
    final rewards = [_thenAId, _thenBId].whereType<String>().toList();
    if (rewards.isEmpty) {
      showBoardSnack(context, 'Pilih minimal satu aktivitas untuk setelah menunggu.');
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
            type: BoardType.waiting,
            waitMinutes: _waitMinutes,
            customActivities: child.customActivities,
            picks: [
              (catalogId: _waitingForId!, start: now),
              for (var i = 0; i < rewards.length; i++)
                (catalogId: rewards[i], start: now.add(Duration(minutes: _waitMinutes + i))),
            ],
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
