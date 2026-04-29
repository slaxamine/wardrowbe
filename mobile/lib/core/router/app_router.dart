import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wardrowbe_app/features/auth/data/auth_service.dart';
import 'package:wardrowbe_app/features/auth/presentation/login_screen.dart';
import 'package:wardrowbe_app/features/dashboard/presentation/dashboard_screen.dart';
import 'package:wardrowbe_app/features/wardrobe/presentation/wardrobe_screen.dart';
import 'package:wardrowbe_app/features/outfits/presentation/suggest_screen.dart';
import 'package:wardrowbe_app/features/history/presentation/history_screen.dart';
import 'package:wardrowbe_app/features/settings/presentation/settings_screen.dart';
import 'package:wardrowbe_app/shared/widgets/app_shell.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/login',
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final isAuth = authState.status == AuthStatus.authenticated;
      final isLoggingIn = state.uri.toString() == '/login';

      if (!isAuth && !isLoggingIn) return '/login';
      if (isAuth && isLoggingIn) return '/dashboard';
      return null;
    },
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
});
