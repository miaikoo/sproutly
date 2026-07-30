import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';

import '../../core/data/activity_catalog.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import 'activity_image.dart';

/// An activity slot on a board being built: a dashed outline while empty, the
/// chosen card once filled.
///
/// This shape appears on every create-board screen in the design. It was
/// hand-rolled four times with different sizes, borders and empty icons; one
/// component keeps the four boards looking like one product.
class SlotBox extends StatelessWidget {
  const SlotBox({
    super.key,
    required this.activityId,
    required this.onTap,
    this.customActivities = const [],
    this.size,
    this.accent = AppColors.steel500,
    this.onLight = true,
  });

  /// Catalog id of the chosen activity, or null while the slot is empty.
  final String? activityId;

  final VoidCallback onTap;

  /// The child's own cards, so a `custom-*` id resolves to the right picture.
  final List<ActivityCatalogItem> customActivities;

  /// Square side. Null lets the slot fill whatever space it is given.
  final double? size;

  /// Colour of the dashed outline and the plus.
  final Color accent;

  /// False when the slot sits on a filled panel, where the outline needs to be
  /// light rather than dark to stay visible.
  final bool onLight;

  @override
  Widget build(BuildContext context) {
    final item = activityId == null
        ? null
        : ActivityCatalog.byId(activityId!, customActivities);
    final outline = onLight ? accent : AppColors.white;

    return Semantics(
      button: true,
      label: item == null ? 'Slot kosong, ketuk untuk memilih aktivitas' : item.title,
      child: SizedBox(
        width: size,
        height: size,
        child: Material(
          color: AppColors.transparent,
          borderRadius: AppRadius.card,
          child: InkWell(
            borderRadius: AppRadius.card,
            onTap: onTap,
            child: item == null ? _empty(outline) : _filled(item),
          ),
        ),
      ),
    );
  }

  Widget _empty(Color outline) {
    return DottedBorder(
      options: RoundedRectDottedBorderOptions(
        radius: AppRadius.lg,
        color: outline,
        strokeWidth: 2,
        dashPattern: const [8, 6],
        padding: EdgeInsets.zero,
      ),
      child: Center(
        child: Icon(Icons.add, size: 32, color: outline),
      ),
    );
  }

  Widget _filled(ActivityCatalogItem item) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.card,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(child: ActivityImage(item.image)),
          AppSpacing.gapXXS,
          Text(
            item.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: AppTextStyles.labelM,
          ),
        ],
      ),
    );
  }
}
