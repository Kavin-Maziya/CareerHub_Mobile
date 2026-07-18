import 'package:careerhub_mobile/features/applications/screens/applications_screen.dart';
import 'package:careerhub_mobile/screens/home_screen.dart';
import 'package:careerhub_mobile/screens/saved_screen.dart';
import 'package:careerhub_mobile/screens/job_detail_screen.dart';
import 'package:careerhub_mobile/widgets/scaffold_with_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// No longer private -- job_detail_screen's route needs to reference
// this key via parentNavigatorKey to render outside the shell.
final rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/jobs',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ScaffoldWithNavBar(navigationShell: navigationShell);
      },
      branches: [
        // Branch 0: Jobs tab
        StatefulShellBranch(
          navigatorKey: _shellNavigatorKey,
          routes: [
            GoRoute(
              path: '/jobs',
              builder: (context, state) => const HomeScreen(),
              routes: [
                // Job detail is a child route of /jobs (so it's part of
                // this branch's back stack), but rendered on the ROOT
                // navigator via parentNavigatorKey -- outside the shell --
                // so it takes over the full screen with no NavigationBar.
                GoRoute(
                  path: ':id', // resolves to the full path /jobs/:id
                  parentNavigatorKey: rootNavigatorKey,
                  builder: (context, state) {
                    final id = state.pathParameters['id']!;
                    return JobDetailScreen(jobId: id);
                  },
                ),
              ],
            ),
          ],
        ),
        // Branch 1: Saved tab
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/saved',
              builder: (context, state) => const SavedScreen(),
            ),
          ],
        ),
        // Branch 2: Applications tab (new)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/applications',
              builder: (context, state) => const ApplicationsScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);