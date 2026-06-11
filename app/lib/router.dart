// lib/core/router/app_router.dart

import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'features/pages/auth/login_page.dart';
import 'features/pages/auth/register_page.dart';
import 'features/pages/auth/verify_email_page.dart';
import 'features/pages/style_quiz/style_quiz_page.dart';
import 'features/pages/wardrobe/wardrobe_page.dart';
import 'features/pages/wardrobe/wardrobe_detail_page.dart';
import 'features/pages/calendar/calendar_page.dart';
import 'features/pages/home/home_page.dart';
import 'features/pages/explore/explore_page.dart';
import 'features/pages/account/account_page.dart';

import '../../features/pages/main_shell.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/wardrobe',

  redirect: (context, state) {
    final session = Supabase.instance.client.auth.currentSession;
    final isLoggedIn = session != null;

    final isAuthRoute =
        state.uri.path == '/login' ||
        state.uri.path == '/register' ||
        state.uri.path == '/verify-email';

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
    GoRoute(
      path: '/verify-email',
      builder: (context, state) {
        final email = state.extra as String;
        return VerifyEmailPage(email: email);
      },
    ),
    GoRoute(
      path: '/style-quiz',
      builder: (context, state) => const StyleQuizPage(),
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
        GoRoute(path: '/home', builder: (context, state) => const HomePage()),
      ],
    ),
  ],
);
