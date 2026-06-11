import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'features/pages/auth/login_page.dart';
import 'features/pages/auth/register_page.dart';
import 'features/pages/auth/verify_email_page.dart';

import 'features/pages/style_quiz/style_quiz_page.dart';

import 'features/pages/main_shell.dart';

import 'features/pages/wardrobe/wardrobe_page.dart';
import 'features/pages/wardrobe/add_item/wardrobe_add_page.dart';
import 'features/pages/wardrobe/wardrobe_detail_page.dart';

import 'features/pages/calendar/calendar_page.dart';

import 'features/pages/home/home_page.dart';

import 'features/pages/explore/explore_page.dart';

import 'features/pages/account/account_page.dart';

import 'features/data/tags_repository.dart';

TagsRepository? _tagsRepository;
String? _cachedUserId;

TagsRepository getTagsRepository() {
  final supabase = Supabase.instance.client;
  final user = supabase.auth.currentUser;

  if (user == null) {
    throw StateError(
      'TagsRepository cannot be created without a logged-in user.',
    );
  }

  final shouldCreateNewRepository =
      _tagsRepository == null || _cachedUserId != user.id;

  if (shouldCreateNewRepository) {
    _cachedUserId = user.id;
    _tagsRepository = TagsRepository(supabase);
  }

  return _tagsRepository!;
}

void clearUserScopedRepositories() {
  _tagsRepository = null;
  _cachedUserId = null;
}

final GoRouter appRouter = GoRouter(
  initialLocation: '/wardrobe',

  redirect: (context, state) {
    final session = Supabase.instance.client.auth.currentSession;
    final isLoggedIn = session != null;

    final isAuthRoute =
        state.uri.path == '/login' ||
        state.uri.path == '/register' ||
        state.uri.path == '/verify-email';

    if (!isLoggedIn) {
      clearUserScopedRepositories();
      if (!isAuthRoute) return '/login';
    }

    if (isLoggedIn && isAuthRoute) return '/wardrobe';

    return null;
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
          builder: (context, state) {
            return WardrobePage(tagsRepository: getTagsRepository());
          },
          routes: [
            GoRoute(
              path: 'add',
              builder: (context, state) {
                return WardrobeAddPage(tagsRepository: getTagsRepository());
              },
            ),
          ],
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
