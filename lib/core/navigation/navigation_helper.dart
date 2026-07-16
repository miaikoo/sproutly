import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'app_routes.dart';

extension NavigationHelper on BuildContext {
  void goHome() => go(AppRoutes.home);

  void goBoard() => go(AppRoutes.board);

  void goBuddy() => go(AppRoutes.buddy);

  void goProfile() => push(AppRoutes.profile);

  void goSettings() => push(AppRoutes.settings);

  void goAnalytics() => push(AppRoutes.analytics);

  void goTherapist() => push(AppRoutes.therapist);

  void goActivity() => push(AppRoutes.activity);

  void goBoardDetail() => push(AppRoutes.boardDetail);
}