import 'package:go_router/go_router.dart';

import '../../features/auth/pages/landing_page.dart';
import '../../features/auth/pages/login_page.dart';
import '../../features/auth/pages/register_page.dart';

import '../../features/home/pages/home_page.dart';

import '../../features/profile/pages/profile_page.dart';
import '../../features/settings/pages/settings_page.dart';

import '../../features/sprout_plan/pages/board_page.dart';
import '../../features/sprout_plan/pages/board_detail_page.dart';
import '../../features/sprout_plan/pages/activity_detail_page.dart';

import '../../features/sprout_buddy/pages/buddy_page.dart';

import '../../features/sprout_track/pages/analytics_page.dart';
import '../../features/sprout_track/pages/report_page.dart';

import '../../features/sprout_link/pages/therapist_page.dart';

import 'app_routes.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.landing,
  routes: [
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
    GoRoute(
      path: AppRoutes.home,
      builder: (_, __) => const HomePage(),
    ),
    GoRoute(
      path: AppRoutes.profile,
      builder: (_, __) => const ProfilePage(),
    ),
    GoRoute(
      path: AppRoutes.settings,
      builder: (_, __) => const SettingsPage(),
    ),
    GoRoute(
      path: AppRoutes.board,
      builder: (_, __) => const BoardPage(),
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
      path: AppRoutes.buddy,
      builder: (_, __) => const BuddyPage(),
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