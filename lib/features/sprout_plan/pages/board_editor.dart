import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/navigation/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/enums.dart';
import '../../../models/schedule.dart';
import '../../../shared/widgets/activity_image.dart';
import '../../../shared/widgets/add_activity_bottom_sheet.dart';

/// Small pieces shared by the board pages, so all four board types behave and
/// look identical when picking a card, renaming a board, or being listed.

/// Card colour per board type, matching each create page's palette.
const _boardColors = {
  BoardType.schedule: AppColors.boardSchedule,
  BoardType.firstThen: AppColors.boardFirstThen,
  BoardType.waiting: AppColors.boardWaiting,
  BoardType.emotion: AppColors.boardEmotion,
};

Color boardColor(BoardType type) => _boardColors[type] ?? _boardColors[BoardType.schedule]!;

const _boardTypeLabels = {
  BoardType.schedule: 'Jadwal',
  BoardType.firstThen: 'Pertama-Kemudian',
  BoardType.waiting: 'Menunggu',
  BoardType.emotion: 'Emosi',
};

String boardTypeLabel(BoardType type) => _boardTypeLabels[type] ?? 'Papan';

/// Opens the catalog picker and returns the chosen catalog id, or null when
/// dismissed. Pass [only] to restrict the picker to one category.
Future<String?> showActivityPicker(
  BuildContext context, {
  ActivityCategory? only,
  String? title,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (context) => Align(
      alignment: Alignment.bottomCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: SafeArea(
          bottom: false,
          child: AddActivityBottomSheet(only: only, title: title),
        ),
      ),
    ),
  );
}

/// Asks for a board name. Returns the trimmed name, or null when cancelled or
/// left blank.
Future<String?> promptForTitle(BuildContext context, {required String current}) async {
  final controller = TextEditingController(text: current);
  final result = await showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Nama Papan'),
      content: TextField(controller: controller, autofocus: true),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text('Batal')),
        TextButton(
          onPressed: () => Navigator.pop(context, controller.text),
          child: Text('Simpan'),
        ),
      ],
    ),
  );

  final trimmed = result?.trim();
  return (trimmed == null || trimmed.isEmpty) ? null : trimmed;
}

/// Lets the parent choose how long the child waits on a waiting board.
Future<int?> promptForWaitMinutes(BuildContext context, {required int current}) {
  const options = [1, 2, 3, 5, 10, 15];
  return showDialog<int>(
    context: context,
    builder: (context) => SimpleDialog(
      title: Text('Lama menunggu'),
      children: [
        for (final minutes in options)
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, minutes),
            child: Text(
              '$minutes menit',
              style: TextStyle(fontWeight: minutes == current ? FontWeight.w800 : FontWeight.w400),
            ),
          ),
      ],
    ),
  );
}

void showBoardSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

/// mm:ss label for a whole number of minutes.
String formatWait(int minutes) => '${minutes.toString().padLeft(2, '0')}:00';

/// A board in a grid. Shared by Home and the Papan tab, which had two copies of
/// this that had already drifted apart on colour and aspect ratio.
class BoardTile extends StatelessWidget {
  const BoardTile({super.key, required this.schedule});

  final Schedule schedule;

  @override
  Widget build(BuildContext context) {
    final thumbnail = schedule.activities.isNotEmpty ? schedule.activities.first.icon : null;
    final count = schedule.activities.length;

    return Semantics(
      button: true,
      label: '${schedule.title}, ${boardTypeLabel(schedule.type)}, $count kartu',
      child: Material(
        color: AppColors.transparent,
        borderRadius: AppRadius.tile,
        child: InkWell(
          borderRadius: AppRadius.tile,
          onTap: () => context.push(AppRoutes.boardDetailPath(schedule.id)),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: boardColor(schedule.type),
                    borderRadius: AppRadius.tile,
                  ),
                  // The artwork sits on its own white card inside the coloured
                  // tile, as in the mockups — it keeps the illustration readable
                  // whatever hue the board type carries.
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.xs),
                    decoration: const BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: AppRadius.card,
                    ),
                    child: thumbnail != null
                        ? ActivityImage(thumbnail)
                        : Icon(
                            Icons.event_note_outlined,
                            color: AppColors.textSecondary,
                            size: 28,
                          ),
                  ),
                ),
              ),
              AppSpacing.gapSM,
              // Centred under the tile, matching the design.
              Text(
                schedule.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: AppTextStyles.headingS,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
