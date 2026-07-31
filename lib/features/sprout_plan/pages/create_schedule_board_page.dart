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
import '../../../shared/widgets/activity_image.dart';
import '../../../core/theme/app_text_styles.dart';

class _ScheduleSlot {
  String? activityId;
  TimeOfDay time;
  _ScheduleSlot({required this.time});
}

/// A couple of hand-picked routines a parent can drop straight onto the board
/// instead of building one card by card.
class _Template {
  const _Template(this.title, this.picks);
  final String title;
  final List<(String catalogId, TimeOfDay time)> picks;
}

const _templates = [
  _Template('Rutinitas Pagi', [
    ('sikat_gigi', TimeOfDay(hour: 6, minute: 30)),
    ('mandi', TimeOfDay(hour: 6, minute: 45)),
    ('memakai_baju', TimeOfDay(hour: 7, minute: 15)),
    ('makan', TimeOfDay(hour: 7, minute: 30)),
  ]),
  _Template('Rutinitas Malam', [
    ('makan', TimeOfDay(hour: 18, minute: 30)),
    ('mandi', TimeOfDay(hour: 19, minute: 0)),
    ('sikat_gigi', TimeOfDay(hour: 19, minute: 30)),
    ('tidur', TimeOfDay(hour: 20, minute: 0)),
  ]),
];

class CreateScheduleBoardPage extends ConsumerStatefulWidget {
  const CreateScheduleBoardPage({super.key, this.boardToEdit});

  final Schedule? boardToEdit;

  @override
  ConsumerState<CreateScheduleBoardPage> createState() => _CreateScheduleBoardPageState();
}

class _CreateScheduleBoardPageState extends ConsumerState<CreateScheduleBoardPage> {
  late final TextEditingController _titleCtrl;
  final List<_ScheduleSlot> _slots = [];
  final List<String?> _thenIds = [null, null];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(
      text: widget.boardToEdit != null ? widget.boardToEdit!.title : 'Rutinitas Pagi',
    );
    if (widget.boardToEdit != null) {
      for (final act in widget.boardToEdit!.activities) {
        final slot = _ScheduleSlot(time: TimeOfDay.fromDateTime(act.startTime));
        final customList = ref.read(currentChildProvider).valueOrNull?.customActivities ?? const [];
        final catalogItem = ActivityCatalog.allWith(customList).firstWhere(
          (item) => item.image == act.icon || item.title == act.title,
          orElse: () => ActivityCatalog.items.first,
        );
        slot.activityId = catalogItem.id;
        _slots.add(slot);
      }
      if (_slots.isEmpty) {
        _slots.add(_ScheduleSlot(time: const TimeOfDay(hour: 5, minute: 0)));
      }
      _thenIds.clear();
      for (var i = 0; i < 2; i++) {
        _thenIds.add(
          widget.boardToEdit!.thenActivityIds.length > i
              ? widget.boardToEdit!.thenActivityIds[i]
              : null,
        );
      }
    } else {
      _slots.add(_ScheduleSlot(time: const TimeOfDay(hour: 5, minute: 0)));
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  /// The child's own activity cards, so a `custom-*` id in a slot resolves to
  /// the right picture.
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
                              // Column headings phrased as the child reads the
                              // board, matching the design.
                              const Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      'Pertama, aku harus',
                                      style: AppTextStyles.bodyS,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      'Timer',
                                      textAlign: TextAlign.center,
                                      style: AppTextStyles.bodyS,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 56,
                                    child: Text(
                                      'Selesai',
                                      textAlign: TextAlign.center,
                                      style: AppTextStyles.bodyS,
                                    ),
                                  ),
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
                        const SizedBox(height: 12),
                        Center(
                          child: TextButton(
                            onPressed: _useTemplate,
                            child: Text(
                              'Gunakan Template',
                              style: AppTextStyles.bodyM.copyWith(
                                color: AppColors.mauve600,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildThenPanel(),
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
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back_ios_new, size: 22),
            color: AppColors.textPrimary,
            tooltip: 'Kembali',
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              _titleCtrl.text,
              style: AppTextStyles.displayM,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            onPressed: _openSettings,
            icon: const CustomIcon(
              assetName: 'assets/icons/solar_settings-bold.svg',
              color: AppColors.steel700,
            ),
            tooltip: 'Pengaturan papan',
          ),
          IconButton(
            onPressed: _isSaving ? null : _save,
            icon: _isSaving
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save_outlined),
            color: AppColors.steel700,
            tooltip: 'Simpan papan',
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
      crossAxisAlignment: CrossAxisAlignment.center,
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
        const SizedBox(width: 16),
        // Preview of the completion mark the child will tap while running the
        // board — nothing to do here yet, so it stays unchecked and inert.
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.steel200,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(Icons.check, color: AppColors.steel500),
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

  Widget _buildThenPanel() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.steel500,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Text(
            'kemudian aku bisa melakukan...',
            textAlign: TextAlign.center,
            style: AppTextStyles.headingM.copyWith(color: AppColors.white),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: SizedBox(
                  height: 120,
                  child: SlotBox(
                    activityId: _thenIds[0],
                    onTap: () => _pickThen(0),
                    customActivities: _custom,
                    accent: AppColors.white,
                    onLight: false,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text('Atau', style: AppTextStyles.bodyM.copyWith(color: AppColors.white)),
              ),
              Expanded(
                child: SizedBox(
                  height: 120,
                  child: SlotBox(
                    activityId: _thenIds[1],
                    onTap: () => _pickThen(1),
                    customActivities: _custom,
                    accent: AppColors.white,
                    onLight: false,
                  ),
                ),
              ),
            ],
          ),
        ],
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

  Future<void> _pickThen(int index) async {
    final result = await showActivityPicker(context, title: 'Kemudian aku bisa...');
    if (result != null) setState(() => _thenIds[index] = result);
  }

  Future<void> _pickTime(int index) async {
    final picked = await showTimePicker(context: context, initialTime: _slots[index].time);
    if (picked != null) {
      setState(() => _slots[index].time = picked);
    }
  }

  Future<void> _useTemplate() async {
    final picked = await showModalBottomSheet<_Template>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Pilih Template', style: AppTextStyles.headingL),
            ),
            for (final template in _templates)
              ListTile(
                title: Text(template.title),
                subtitle: Text('${template.picks.length} kegiatan'),
                onTap: () => Navigator.pop(context, template),
              ),
          ],
        ),
      ),
    );
    if (picked == null) return;

    setState(() {
      _titleCtrl.text = picked.title;
      _slots
        ..clear()
        ..addAll([
          for (final pick in picked.picks)
            _ScheduleSlot(time: pick.$2)..activityId = pick.$1,
        ]);
    });
  }

  Future<void> _openSettings() async {
    final reset = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pengaturan Papan'),
        content: const Text('Kosongkan semua kegiatan yang sudah dipilih dan mulai dari awal?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Reset papan')),
        ],
      ),
    );
    if (reset != true) return;

    setState(() {
      _titleCtrl.text = 'Rutinitas Pagi';
      _slots
        ..clear()
        ..add(_ScheduleSlot(time: const TimeOfDay(hour: 5, minute: 0)));
      _thenIds[0] = null;
      _thenIds[1] = null;
    });
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
            thenActivityIds: [for (final id in _thenIds) ?id],
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
