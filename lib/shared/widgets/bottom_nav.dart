import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../core/navigation/app_routes.dart';
import '../../core/theme/app_colors.dart';

/// The three top-level destinations.
class _Destination {
  const _Destination(this.route, this.label, this.asset);

  final String route;
  final String label;
  final String asset;
}

const _destinations = [
  _Destination(AppRoutes.home, 'Beranda', 'assets/icons/solar_home-bold.svg'),
  _Destination(AppRoutes.board, 'Papan', 'assets/icons/square-bold.svg'),
  _Destination(AppRoutes.buddy, 'Buddy', 'assets/icons/solar_smile-circle-bold.svg'),
];

int _selectedIndex(BuildContext context) {
  final location = GoRouterState.of(context).uri.path;
  final index = _destinations.indexWhere((d) => location.startsWith(d.route));
  return index < 0 ? 0 : index;
}

void _go(BuildContext context, int index) => context.go(_destinations[index].route);

Widget _icon(String asset, {required bool selected}) {
  return SvgPicture.asset(
    asset,
    width: 26,
    height: 26,
    colorFilter: ColorFilter.mode(
      selected ? AppColors.teal900 : AppColors.textSecondary,
      BlendMode.srcIn,
    ),
  );
}

/// Bottom navigation for compact widths (phones, tablet portrait).
///
/// This replaced a hand-rolled pill container that put white labels on
/// `teal300` — 1.74:1, the worst contrast in the app. Material's NavigationBar
/// carries the selected state with a tinted indicator instead of colour alone,
/// and gives 48dp targets for free.
class BottomNav extends StatelessWidget {
  const BottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    final selected = _selectedIndex(context);

    return NavigationBar(
      selectedIndex: selected,
      onDestinationSelected: (index) => _go(context, index),
      // Labels stay visible: an icon-only bar makes a parent guess, and this is
      // not an app anyone uses often enough to memorise glyphs.
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      destinations: [
        for (final d in _destinations)
          NavigationDestination(
            icon: _icon(d.asset, selected: false),
            selectedIcon: _icon(d.asset, selected: true),
            label: d.label,
            tooltip: d.label,
          ),
      ],
    );
  }
}

/// Side navigation for expanded widths (tablet landscape).
///
/// Material asks for a rail rather than a stretched bottom bar once there is
/// room, and it keeps the vertical space for the content — which matters on the
/// runner, where the child is looking at the activity picture.
class SideNav extends StatelessWidget {
  const SideNav({super.key});

  @override
  Widget build(BuildContext context) {
    final selected = _selectedIndex(context);

    return NavigationRail(
      selectedIndex: selected,
      onDestinationSelected: (index) => _go(context, index),
      labelType: NavigationRailLabelType.all,
      minWidth: 88,
      destinations: [
        for (final d in _destinations)
          NavigationRailDestination(
            icon: _icon(d.asset, selected: false),
            selectedIcon: _icon(d.asset, selected: true),
            label: Text(d.label),
            padding: const EdgeInsets.symmetric(vertical: 4),
          ),
      ],
    );
  }
}
