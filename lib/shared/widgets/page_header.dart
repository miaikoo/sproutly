import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

/// Back chevron plus title, as every secondary screen in the design has.
///
/// This existed as a hand-rolled `GestureDetector` around a 28px icon in nine
/// separate files — each with slightly different padding, and none of them
/// meeting the 48dp touch minimum. One component, one back affordance.
class PageHeader extends StatelessWidget {
  const PageHeader({
    super.key,
    required this.title,
    this.actions = const [],
    this.onBack,
  });

  final String title;

  /// Trailing controls (save, settings, overflow).
  final List<Widget> actions;

  /// Defaults to popping the route.
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.sm,
        AppSpacing.xs,
        AppSpacing.sm,
        AppSpacing.xs,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack ?? () => context.pop(),
            icon: const Icon(Icons.arrow_back_ios_new, size: 22),
            color: AppColors.textPrimary,
            tooltip: 'Kembali',
          ),
          AppSpacing.gapHXS,
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.displayM,
            ),
          ),
          ...actions,
        ],
      ),
    );
  }
}
