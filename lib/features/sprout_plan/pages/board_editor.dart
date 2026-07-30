import 'package:flutter/material.dart';

import '../../../models/enums.dart';
import '../../../shared/widgets/add_activity_bottom_sheet.dart';

/// Small pieces shared by the board pages, so all four board types behave and
/// look identical when picking a card, renaming a board, or being listed.

/// Card colour per board type, matching each create page's palette.
const _boardColors = {
  BoardType.schedule: Color(0xFFBCA0B0),
  BoardType.firstThen: Color(0xFF98B6CE),
  BoardType.waiting: Color(0xFFDDD1A4),
  BoardType.emotion: Color(0xFFE0A896),
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
      title: const Text('Nama Papan'),
      content: TextField(controller: controller, autofocus: true),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
        TextButton(
          onPressed: () => Navigator.pop(context, controller.text),
          child: const Text('Simpan'),
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
      title: const Text('Lama menunggu'),
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
