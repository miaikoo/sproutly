import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/pages/landing_page.dart';
import '../../features/auth/pages/login_page.dart';
import '../../features/auth/pages/register_page.dart';

import '../../features/home/pages/home_page.dart';
import '../../features/profile/pages/profile_page.dart';
import '../../features/profile/pages/child_profile_page.dart';
import '../../features/settings/pages/settings_page.dart';

import '../../features/sprout_plan/pages/board_page.dart';
import '../../features/sprout_plan/pages/create_board_page.dart';
import '../../features/sprout_plan/pages/create_activity_board_page.dart';
import '../../features/sprout_plan/pages/create_schedule_board_page.dart';
import '../../features/sprout_plan/pages/create_activity_page.dart';
import '../../features/sprout_plan/pages/create_first_then_board_page.dart';
import '../../features/sprout_plan/pages/create_waiting_board_page.dart';
import '../../features/sprout_plan/pages/create_emotion_board_page.dart';

import '../../features/sprout_plan/pages/board_detail_page.dart';
import '../../features/sprout_plan/pages/activity_detail_page.dart';
import '../../features/sprout_plan/pages/run_board_page.dart';

import '../../features/sprout_buddy/pages/buddy_page.dart';
import '../../features/sprout_track/pages/analytics_page.dart';
import '../../features/sprout_track/pages/report_page.dart';
import '../../features/sprout_link/pages/therapist_page.dart';

import 'app_routes.dart';
import '../../shared/widgets/app_shell.dart';

// Navigator keys
final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

/// Notifies GoRouter to re-evaluate `redirect` whenever auth state changes.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

const _publicRoutes = {AppRoutes.landing, AppRoutes.login, AppRoutes.register};

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: AppRoutes.landing,
  refreshListenable: GoRouterRefreshStream(fb.FirebaseAuth.instance.authStateChanges()),
  redirect: (context, state) {
    final loggedIn = fb.FirebaseAuth.instance.currentUser != null;
    final isPublicRoute = _publicRoutes.contains(state.matchedLocation);

    if (!loggedIn && !isPublicRoute) return AppRoutes.landing;
    if (loggedIn && isPublicRoute) return AppRoutes.home;
    return null;
  },
  routes: [
    // Routes for authentication
    GoRoute(
      path: AppRoutes.landing,
      builder: (_, _) => const LandingPage(),
    ),
    GoRoute(
      path: AppRoutes.login,
      builder: (_, _) => const LoginPage(),
    ),
    GoRoute(
      path: AppRoutes.register,
      builder: (_, _) => const RegisterPage(),
    ),
    
    // Shell route
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return AppShell(child: child); 
      },
      routes: [
        GoRoute(
          path: AppRoutes.home,
          builder: (_, _) => const Home(),
        ),
        GoRoute(
          path: AppRoutes.board,
          builder: (_, _) => const BoardPage(),
        ),
        GoRoute(
          path: AppRoutes.buddy,
          builder: (_, _) => const BuddyPage(),
        ),
      ],
    ),

    // Routes for create board
    GoRoute(
      path: AppRoutes.createBoard,
      builder: (_, _) => const CreateBoardPage(),
    ),
    GoRoute(
      path: AppRoutes.createBoardActivity,
      builder: (_, _) => const CreateActivityBoardPage(),
    ),
    GoRoute(
      path: AppRoutes.createScheduleBoard,
      builder: (_, _) => const CreateScheduleBoardPage(),
    ),
    GoRoute(
      path: AppRoutes.createActivity,
      builder: (_, _) => const CreateActivityPage(),
    ),
    GoRoute(
      path: AppRoutes.createFirstThenBoard,
      builder: (_, _) => const CreateFirstThenBoardPage(),
    ),
    GoRoute(
      path: AppRoutes.createWaitingBoard,
      builder: (context, state) => const CreateWaitingBoardPage(),
    ),
    GoRoute(
      path: AppRoutes.createEmotionBoard,
      builder: (context, state) => const CreateEmotionBoardPage(),
    ),

    // Routes for other pages
    GoRoute(
      path: AppRoutes.profile,
      builder: (_, _) => const ProfilePage(),
    ),
    GoRoute(
      path: AppRoutes.childProfile,
      builder: (_, state) =>
          ChildProfilePage(childId: state.pathParameters['childId']!),
    ),
    GoRoute(
      path: AppRoutes.settings,
      builder: (_, _) => const SettingsPage(),
    ),
    GoRoute(
      path: AppRoutes.boardDetail,
      builder: (_, state) => BoardDetailPage(scheduleId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: AppRoutes.runBoard,
      builder: (_, state) => RunBoardPage(scheduleId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: AppRoutes.activity,
      builder: (_, state) => ActivityDetailPage(
        scheduleId: state.pathParameters['scheduleId']!,
        activityId: state.pathParameters['activityId']!,
      ),
    ),
    GoRoute(
      path: AppRoutes.analytics,
      builder: (_, _) => const AnalyticsPage(),
    ),
    GoRoute(
      path: AppRoutes.report,
      builder: (_, _) => const ReportPage(),
    ),
    GoRoute(
      path: AppRoutes.therapist,
      builder: (_, _) => const TherapistPage(),
    ),
  ],
);