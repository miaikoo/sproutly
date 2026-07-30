import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/notification_service.dart';
import '../../core/theme/app_colors.dart';
import 'bottom_nav.dart';

/// Width at which Material switches from a bottom navigation bar to a rail.
/// 600dp is Material's compact/medium boundary, so a tablet in landscape gets
/// the rail and a phone never does.
const _expandedBreakpoint = 600.0;

class AppShell extends ConsumerWidget {
  final Widget child;

  const AppShell({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Single place that keeps activity reminders in step with the boards.
    ref.watch(reminderSyncProvider);

    final useRail = MediaQuery.sizeOf(context).width >= _expandedBreakpoint;

    if (!useRail) {
      return Scaffold(
        body: child,
        bottomNavigationBar: const BottomNav(),
      );
    }

    return Scaffold(
      body: Row(
        children: [
          const SideNav(),
          const VerticalDivider(width: 1, color: AppColors.divider),
          Expanded(child: child),
        ],
      ),
    );
  }
}
