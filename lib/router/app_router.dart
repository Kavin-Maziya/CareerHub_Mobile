import 'package:careerhub_mobile/screens/home_screen.dart';
import 'package:careerhub_mobile/screens/saved_screen.dart';
import 'package:careerhub_mobile/widgets/scaffold_with_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
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
              // Job detail is a child route of /jobs (so it's part of
              // this branch's back stack), but rendered on the root
              // navigator -- outside the shell -- so it takes over the
              // full screen with no NavigationBar.
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
      ],
    ),
  ],
);