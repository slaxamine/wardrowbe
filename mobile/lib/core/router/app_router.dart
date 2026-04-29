import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wardrowbe_app/features/auth/presentation/login_screen.dart';
import 'package:wardrowbe_app/features/dashboard/presentation/dashboard_screen.dart';
import 'package:wardrowbe_app/features/wardrobe/presentation/wardrobe_screen.dart';
import 'package:wardrowbe_app/features/outfits/presentation/suggest_screen.dart';
import 'package:wardrowbe_app/features/history/presentation/history_screen.dart';
import 'package:wardrowbe_app/features/settings/presentation/settings_screen.dart';
import 'package:wardrowbe_app/shared/widgets/app_shell.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/dashboard',
  routes: [
    // Login (no bottom nav)
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    // Main app with bottom navigation shell
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(
          path: '/dashboard',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: DashboardScreen(),
          ),
        ),
        GoRoute(
          path: '/wardrobe',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: WardrobeScreen(),
          ),
        ),
        GoRoute(
          path: '/suggest',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: SuggestScreen(),
          ),
        ),
        GoRoute(
          path: '/history',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: HistoryScreen(),
          ),
        ),
        GoRoute(
          path: '/settings',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: SettingsScreen(),
          ),
        ),
      ],
    ),
  ],
);
