import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../core/navigation/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

class BottomNav extends StatelessWidget {
  const BottomNav({super.key});

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;

    if (location.startsWith(AppRoutes.home)) return 0;
    if (location.startsWith(AppRoutes.board)) return 1;
    if (location.startsWith(AppRoutes.buddy)) return 2;
    return 0;
  }

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(AppRoutes.home);
        break;
      case 1:
        context.go(AppRoutes.board);
        break;
      case 2:
        context.go(AppRoutes.buddy);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _calculateSelectedIndex(context);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.teal300,
                borderRadius: BorderRadius.circular(48),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(3, (index) {
                  final selected = selectedIndex == index;
                  final label = index == 0 ? 'Beranda' : index == 1 ? 'Papan' : 'Buddy';

                  final assetName = index == 0
                      ? 'assets/icons/solar_home-bold.svg'
                      : index == 1
                          ? 'assets/icons/square-bold.svg'
                          : 'assets/icons/solar_smile-circle-bold.svg';

                  return Expanded(
                    child: GestureDetector(
                      onTap: () => _onItemTapped(context, index),
                      behavior: HitTestBehavior.opaque,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: selected ? AppColors.peach500 : AppColors.transparent,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: SvgPicture.asset(
                              assetName,
                              width: 24,
                              height: 24,
                              colorFilter: const ColorFilter.mode(AppColors.white, BlendMode.srcIn),
                            ),
                          ),
                          AppSpacing.gapXS,
                          Text(label, style: AppTextStyles.headingM.copyWith(color: AppColors.white)),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
