import 'package:careerhub_mobile/models/auth_state.dart';
import 'package:careerhub_mobile/providers/auth_notifier.dart';
import 'package:careerhub_mobile/providers/auth_provider.dart';
import 'package:careerhub_mobile/screens/home_screen.dart';
import 'package:careerhub_mobile/screens/job_detail_screen.dart';
import 'package:careerhub_mobile/screens/login_screen.dart';
import 'package:careerhub_mobile/screens/saved_screen.dart';
import 'package:careerhub_mobile/widgets/scaffold_with_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:careerhub_mobile/screens/apply_screen.dart';

part 'app_router.g.dart';

// No longer private -- job_detail_screen's route needs to reference
// this key via parentNavigatorKey to render outside the shell.
final rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

@riverpod
GoRouter appRouter(Ref ref) {
  final authListenable = ref.watch(authStateListenableProvider);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/jobs',
    refreshListenable: authListenable,

    redirect: (context, state) {
      final auth = ref.read(authProvider);

      // Allow AuthNotifier.build() to complete before redirecting.
      if (auth.isLoading) {
        return null;
      }

      final isAuthenticated =
          auth is AsyncData<AuthState> && auth.value is Authenticated;

      final isLoginRoute = state.matchedLocation == '/login';

      if (!isAuthenticated && !isLoginRoute) {
        return '/login';
      }

      if (isAuthenticated && isLoginRoute) {
        return '/jobs';
      }

      return null;
    },

    routes: [
      // Login route sits outside the shell so it has no bottom navigation.
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),

      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: [
          // Branch 0: Jobs
          StatefulShellBranch(
            navigatorKey: _shellNavigatorKey,
            routes: [
              GoRoute(
                path: '/jobs',
                builder: (context, state) => const HomeScreen(),
                routes: [
                  GoRoute(
                    path: ':id',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return JobDetailScreen(jobId: id);
                    },
                    routes: [
                      GoRoute(
                        path: 'apply',
                        builder: (context, state) {
                          final id = state.pathParameters['id']!;
                          return ApplyScreen(jobId: id);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          // Branch 1: Saved
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/saved',
                builder: (context, state) => const SavedScreen(),
              ),
            ],
          ),

          // Branch 2: Applications
          // StatefulShellBranch(
          //   routes: [
          //     GoRoute(
          //       path: '/applications',
          //       builder: (context, state) =>
          //           const ApplicationsScreen(),
          //     ),
          //   ],
          // ),
        ],
      ),
    ],
  );
}
