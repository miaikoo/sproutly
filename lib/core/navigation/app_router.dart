import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/pages/landing_page.dart';
import '../../features/auth/pages/login_page.dart';
import '../../features/auth/pages/register_page.dart';

import '../../features/home/pages/home_page.dart';
import '../../features/profile/pages/profile_page.dart';
import '../../features/settings/pages/settings_page.dart';

import '../../features/sprout_plan/pages/board_page.dart';
import '../../features/sprout_plan/pages/create_board_page.dart';
import '../../features/sprout_plan/pages/create_activity_board_page.dart';
import '../../features/sprout_plan/pages/create_schedule_board_page.dart';
import '../../features/sprout_plan/pages/create_activity_page.dart';
import '../../features/sprout_plan/pages/create_first_then_board_page.dart';

import '../../features/sprout_plan/pages/board_detail_page.dart';
import '../../features/sprout_plan/pages/activity_detail_page.dart';

import '../../features/sprout_buddy/pages/buddy_page.dart';
import '../../features/sprout_track/pages/analytics_page.dart';
import '../../features/sprout_track/pages/report_page.dart';
import '../../features/sprout_link/pages/therapist_page.dart';

import 'app_routes.dart';
import '../../shared/widgets/app_shell.dart';

// Navigator keys
final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: AppRoutes.landing,
  routes: [
    // Routes for authentication
    GoRoute(
      path: AppRoutes.landing,
      builder: (_, __) => const LandingPage(),
    ),
    GoRoute(
      path: AppRoutes.login,
      builder: (_, __) => const LoginPage(),
    ),
    GoRoute(
      path: AppRoutes.register,
      builder: (_, __) => const RegisterPage(),
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
          builder: (_, __) => const Home(),
        ),
        GoRoute(
          path: AppRoutes.board,
          builder: (_, __) => const BoardPage(),
        ),
        GoRoute(
          path: AppRoutes.buddy,
          builder: (_, __) => const BuddyPage(),
        ),
      ],
    ),

    // Routes for create board
    GoRoute(
      path: AppRoutes.createBoard,
      builder: (_, __) => const CreateBoardPage(),
    ),
    GoRoute(
      path: AppRoutes.createBoardActivity,
      builder: (_, __) => const CreateActivityBoardPage(),
    ),
    GoRoute(
      path: AppRoutes.createScheduleBoard,
      builder: (_, __) => const CreateScheduleBoardPage(),
    ),
    GoRoute(
      path: AppRoutes.createActivity,
      builder: (_, __) => const CreateActivityPage(),
    ),
    GoRoute(
      path: AppRoutes.createFirstThenBoard,
      builder: (_, __) => const CreateFirstThenBoardPage(),
    ),

    // Routes for other pages
    GoRoute(
      path: AppRoutes.profile,
      builder: (_, __) => const ProfilePage(),
    ),
    GoRoute(
      path: AppRoutes.settings,
      builder: (_, __) => const SettingsPage(),
    ),
    GoRoute(
      path: AppRoutes.boardDetail,
      builder: (_, __) => const BoardDetailPage(),
    ),
    GoRoute(
      path: AppRoutes.activity,
      builder: (_, __) => const ActivityDetailPage(),
    ),
    GoRoute(
      path: AppRoutes.analytics,
      builder: (_, __) => const AnalyticsPage(),
    ),
    GoRoute(
      path: AppRoutes.report,
      builder: (_, __) => const ReportPage(),
    ),
    GoRoute(
      path: AppRoutes.therapist,
      builder: (_, __) => const TherapistPage(),
    ),
  ],
);