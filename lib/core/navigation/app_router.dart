import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/pages/login_page.dart';
import '../../features/auth/pages/register_page.dart';

import '../../features/home/pages/home_page.dart';
import '../../features/profile/pages/profile_page.dart';
import '../../features/profile/pages/child_profile_page.dart';
import '../../features/settings/pages/settings_page.dart';
import '../../features/settings/pages/accessibility_settings_page.dart';
import '../../features/settings/pages/account_security_page.dart';
import '../../features/settings/pages/about_sproutly_page.dart';
import '../../features/settings/pages/privacy_policy_page.dart';
import '../../features/settings/pages/terms_of_service_page.dart';
import '../../features/settings/pages/customer_support_page.dart';
import '../../features/settings/pages/manage_activities_page.dart';
import '../../core/data/activity_catalog.dart';
import '../../models/schedule.dart';

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
import '../../features/sprout_buddy/pages/companion_store_page.dart';
import '../../features/sprout_track/pages/analytics_page.dart';
import '../../features/sprout_track/pages/report_page.dart';
import '../../features/sprout_track/pages/calendar_page.dart';
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

const _publicRoutes = {AppRoutes.login, AppRoutes.register};

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: AppRoutes.login,
  refreshListenable: GoRouterRefreshStream(fb.FirebaseAuth.instance.authStateChanges()),
  redirect: (context, state) {
    final loggedIn = fb.FirebaseAuth.instance.currentUser != null;
    // final loggedIn = true;
    final isPublicRoute = _publicRoutes.contains(state.matchedLocation);

    if (!loggedIn && !isPublicRoute) return AppRoutes.login;
    if (loggedIn && isPublicRoute) return AppRoutes.home;
    return null;
  },
  routes: [
    // Routes for authentication
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
          path: AppRoutes.analytics,
          builder: (_, _) => const AnalyticsPage(),
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
      builder: (_, state) => CreateScheduleBoardPage(boardToEdit: state.extra as Schedule?),
    ),
    GoRoute(
      path: AppRoutes.createActivity,
      builder: (_, state) {
        final activity = state.extra as ActivityCatalogItem?;
        return CreateActivityPage(activityToEdit: activity);
      },
    ),
    GoRoute(
      path: AppRoutes.createFirstThenBoard,
      builder: (_, state) => CreateFirstThenBoardPage(boardToEdit: state.extra as Schedule?),
    ),
    GoRoute(
      path: AppRoutes.createWaitingBoard,
      builder: (context, state) => CreateWaitingBoardPage(boardToEdit: state.extra as Schedule?),
    ),
    GoRoute(
      path: AppRoutes.createEmotionBoard,
      builder: (context, state) => CreateEmotionBoardPage(boardToEdit: state.extra as Schedule?),
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
      path: AppRoutes.manageActivities,
      builder: (_, _) => const ManageActivitiesPage(),
    ),
    GoRoute(
      path: AppRoutes.accessibility,
      builder: (_, _) => const AccessibilitySettingsPage(),
    ),
    GoRoute(
      path: AppRoutes.security,
      builder: (_, _) => const AccountSecurityPage(),
    ),
    GoRoute(
      path: AppRoutes.about,
      builder: (_, _) => const AboutSproutlyPage(),
    ),
    GoRoute(
      path: AppRoutes.privacy,
      builder: (_, _) => const PrivacyPolicyPage(),
    ),
    GoRoute(
      path: AppRoutes.terms,
      builder: (_, _) => const TermsOfServicePage(),
    ),
    GoRoute(
      path: AppRoutes.support,
      builder: (_, _) => const CustomerSupportPage(),
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
      path: AppRoutes.calendar,
      builder: (_, _) => const CalendarPage(),
    ),
    GoRoute(
      path: AppRoutes.therapist,
      builder: (_, _) => const TherapistPage(),
    ),
    GoRoute(
      path: AppRoutes.companionStore,
      builder: (_, _) => const CompanionStorePage(),
    ),
  ],
);