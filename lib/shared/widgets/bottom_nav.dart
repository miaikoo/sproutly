import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../core/navigation/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';

class _Destination {
  const _Destination(this.route, this.label, this.asset);

  final String route;
  final String label;
  final String asset;
}

const _destinations = [
  _Destination(AppRoutes.home, 'Beranda', 'assets/icons/solar_home-bold.svg'),
  _Destination(AppRoutes.board, 'Papan', 'assets/icons/square-bold.svg'),
  _Destination(AppRoutes.analytics, 'Analytics', 'assets/icons/solar_running-2-bold.svg'),
  _Destination(AppRoutes.buddy, 'Buddy', 'assets/icons/solar_smile-circle-bold.svg'),
];

int _selectedIndex(BuildContext context) {
  final location = GoRouterState.of(context).uri.path;
  final index = _destinations.indexWhere((d) => location.startsWith(d.route));
  return index < 0 ? 0 : index;
}

/// The floating pill navigation from the Figma design: a rounded teal bar with
/// a filled circle marking the active destination.
///
/// The bar is `teal700` rather than the mockup's `teal500`. The design system's
/// own contrast table asks for 6.2:1 on its primary filled pair, and `teal700`
/// is the step that actually delivers it (6.19:1) — `teal500` measures 2.79:1,
/// which would leave these labels unreadable.
class BottomNav extends StatelessWidget {
  const BottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    final selected = _selectedIndex(context);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.xs,
          AppSpacing.md,
          AppSpacing.sm,
        ),
        child: Center(
          heightFactor: 1,
          // Capped so the bar stays a pill on a tablet instead of stretching
          // into a full-width band.
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.teal700,
                borderRadius: BorderRadius.all(AppRadius.pill),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                children: [
                  for (var i = 0; i < _destinations.length; i++)
                    Expanded(
                      child: _NavItem(
                        destination: _destinations[i],
                        selected: i == selected,
                        onTap: () => context.go(_destinations[i].route),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  final _Destination destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: destination.label,
      child: InkWell(
        onTap: onTap,
        borderRadius: const BorderRadius.all(AppRadius.pill),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: AppTheme.motion(context, AppTheme.motionFast),
                curve: AppTheme.motionCurve,
                width: 52,
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  // The terracotta disc from the mockup marks the active tab.
                  // Selection is carried by the disc, not by colour alone.
                  color: selected ? AppColors.peach500 : AppColors.transparent,
                  shape: BoxShape.circle,
                ),
                child: SvgPicture.asset(
                  destination.asset,
                  width: 24,
                  height: 24,
                  colorFilter: ColorFilter.mode(
                    selected ? AppColors.white : AppColors.teal100,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              AppSpacing.gapXXS,
              Text(
                destination.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.labelM.copyWith(
                  color: AppColors.white,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
