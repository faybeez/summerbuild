// lib/core/router/app_router.dart

import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'features/pages/auth/login_page.dart';
import 'features/pages/auth/register_page.dart';
import '../../features/pages/wardrobe_page.dart';
import '../../features/pages/wardrobe_detail_page.dart';
import '../../features/pages/calendar_page.dart';
import '../../features/pages/explore_page.dart';
import '../../features/pages/account_page.dart';

import '../../features/pages/main_shell.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/wardrobe',

  redirect: (context, state) {
    final session = Supabase.instance.client.auth.currentSession;
    final isLoggedIn = session != null;

    final isAuthRoute =
        state.uri.path == '/login' || state.uri.path == '/register';

    if (!isLoggedIn && !isAuthRoute) return '/login';
    if (isLoggedIn && isAuthRoute) return '/wardrobe';
    return null; // no redirect
  },

  routes: [
    GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterPage(),
    ),

    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(
          path: '/wardrobe',
          builder: (context, state) => const WardrobePage(),
          // routes: [
          //   GoRoute(
          //     path: 'detail',
          //     builder: (context, state) {
          //       final item = state.extra;
          //       return WardrobeDetailPage(item: item);
          //     },
          //   ),
          // ],
        ),
        GoRoute(
          path: '/calendar',
          builder: (context, state) => const CalendarPage(),
        ),
        GoRoute(
          path: '/explore',
          builder: (context, state) => const ExplorePage(),
        ),
        GoRoute(
          path: '/account',
          builder: (context, state) => const AccountPage(),
        ),
      ],
    ),
  ],
);
