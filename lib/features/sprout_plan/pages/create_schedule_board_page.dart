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

class _ScheduleSlot {
  String? activityId;
  TimeOfDay time;
  _ScheduleSlot({required this.time});
}

class CreateScheduleBoardPage extends ConsumerStatefulWidget {
  const CreateScheduleBoardPage({super.key});

  @override
  ConsumerState<CreateScheduleBoardPage> createState() => _CreateScheduleBoardPageState();
}

class _CreateScheduleBoardPageState extends ConsumerState<CreateScheduleBoardPage> {
  final _titleCtrl = TextEditingController(text: 'Rutinitas Pagi');
  final List<_ScheduleSlot> _slots = [
    _ScheduleSlot(time: const TimeOfDay(hour: 5, minute: 0)),
  ];
  bool _isSaving = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTitleCard(),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.steel100,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            children: [
                              const Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Text('Aktivitas', style: AppTextStyles.bodyS),
                                  Text('Waktu', style: AppTextStyles.bodyS),
                                ],
                              ),
                              const SizedBox(height: 12),
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _slots.length,
                                separatorBuilder: (context, index) => const SizedBox(height: 16),
                                itemBuilder: (context, index) => _buildScheduleRow(context, index),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildAddButton(),
                        const SizedBox(height: 24),
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
            child: Text(
              _titleCtrl.text,
              style: AppTextStyles.displayM,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (_isSaving)
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            GestureDetector(
              onTap: _save,
              child: const CustomIcon(
                assetName: 'assets/icons/lucide_save.svg',
                size: 28,
                color: AppColors.neutral800,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTitleCard() {
    return Row(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.neutral300,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Image.asset('assets/images/Bahagia.png', fit: BoxFit.contain),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: GestureDetector(
            onTap: _editTitle,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              decoration: BoxDecoration(
                color: AppColors.steel100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      _titleCtrl.text,
                      style: AppTextStyles.displayM,
                      overflow: TextOverflow.ellipsis,
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
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleRow(BuildContext context, int index) {
    final slot = _slots[index];
    final catalogItem = slot.activityId == null ? null : ActivityCatalog.byId(slot.activityId!);

    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => _pickActivity(index),
            child: Container(
              height: 100,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.5),
                border: Border.all(color: AppColors.steel500, width: 1.5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: catalogItem == null
                  ? const Center(
                      child: CustomIcon(
                        assetName: 'assets/icons/solar_clipboard-add-outline.svg',
                        size: 28,
                        color: AppColors.steel500,
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(child: ActivityImage(catalogItem.image)),
                        Text(
                          catalogItem.title,
                          style: AppTextStyles.caption,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        GestureDetector(
          onTap: () => _pickTime(index),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            decoration: BoxDecoration(
              color: AppColors.steel500,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              slot.time.format(context),
              style: AppTextStyles.displayM.copyWith(color: AppColors.white),
            ),
          ),
        ),
        if (_slots.length > 1) ...[
          const SizedBox(width: 8),
          IconButton(
            onPressed: () => setState(() => _slots.removeAt(index)),
            icon: Icon(Icons.close, color: AppColors.error),
          ),
        ],
      ],
    );
  }

  Widget _buildAddButton() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _slots.add(_ScheduleSlot(time: const TimeOfDay(hour: 7, minute: 0)));
        });
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.mauve500,
          borderRadius: BorderRadius.circular(32),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIcon(
              assetName: 'assets/icons/solar_clipboard-add-outline.svg',
              size: 24,
              color: AppColors.white,
            ),
            SizedBox(width: 8),
            Text(
              'Tambahkan Kegiatan',
              style: AppTextStyles.headingL.copyWith(color: AppColors.white),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editTitle() async {
    final result = await promptForTitle(context, current: _titleCtrl.text);
    if (result != null) setState(() => _titleCtrl.text = result);
  }

  Future<void> _pickActivity(int index) async {
    final result = await showActivityPicker(context);
    if (result != null) {
      setState(() => _slots[index].activityId = result);
    }
  }

  Future<void> _pickTime(int index) async {
    final picked = await showTimePicker(context: context, initialTime: _slots[index].time);
    if (picked != null) {
      setState(() => _slots[index].time = picked);
    }
  }

  Future<void> _save() async {
    final filledSlots = _slots.where((s) => s.activityId != null).toList();
    if (filledSlots.isEmpty) {
      showBoardSnack(context, 'Tambahkan minimal satu aktivitas sebelum menyimpan.');
      return;
    }

    setState(() => _isSaving = true);
    try {
      final child = await ref.read(currentChildProvider.future);
      if (child == null) {
        throw StateError('Profil anak belum tersedia.');
      }

      final now = DateTime.now();
      await ref.read(scheduleServiceProvider).createBoard(
            childId: child.id,
            title: _titleCtrl.text.trim().isEmpty ? 'Papan Baru' : _titleCtrl.text.trim(),
            type: BoardType.schedule,
            customActivities: child.customActivities,
            picks: [
              for (final slot in filledSlots)
                (
                  catalogId: slot.activityId!,
                  start: DateTime(now.year, now.month, now.day, slot.time.hour, slot.time.minute),
                ),
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
