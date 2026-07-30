import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/notification_service.dart';
import 'bottom_nav.dart';

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

    return Scaffold(
      body: child,
      bottomNavigationBar: const BottomNav(),
    );
  }
}
