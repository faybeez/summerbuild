import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';

import 'features/pages/auth/login_page.dart';
import 'features/pages/auth/register_page.dart';
import 'features/pages/auth/verify_email_page.dart';

import 'features/pages/style_quiz/style_quiz_page.dart';

import 'features/pages/main_shell.dart';

import 'features/pages/outfit_creator/pages/outfit_creator_page.dart';
import 'features/pages/outfit_creator/pages/outfit_results_page.dart';
import 'features/pages/outfit_creator/pages/outfit_detail_page.dart';
import 'features/pages/outfit_creator/models/outfit_suggestion.dart';
import 'features/pages/outfit_creator/state/outfit_creator_controller.dart';

import 'features/pages/studio/studio_page.dart';
import 'features/pages/studio/add_outfit/manual_build_page.dart';
import 'features/pages/studio/add_outfit/review_build_page.dart';

import 'features/pages/wardrobe/wardrobe_page.dart';
import 'features/pages/wardrobe/add_item/wardrobe_add_page.dart';
import 'features/pages/wardrobe/wardrobe_detail_page.dart';

import 'features/pages/home/home_page.dart';

import 'features/pages/explore/explore_page.dart';

import 'features/pages/account/account_page.dart';

import 'features/data/tags_repository.dart';
import 'features/data/wardrobe_repository.dart';
import 'features/data/outfit_repository.dart';

import 'features/pages/calendar/calendar_page.dart';
import 'features/pages/calendar/calendar_day_recap_page.dart';
import 'features/pages/calendar/event_edit_page.dart';
import 'features/pages/calendar/ootd_edit_page.dart';
import 'features/data/calendar_repository.dart';

CalendarRepository? _calendarRepository;
TagsRepository? _tagsRepository;
WardrobeRepository? _wardrobeRepository;
OutfitRepository? _outfitRepository;
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

WardrobeRepository getWardrobeRepository() {
  final supabase = Supabase.instance.client;
  final user = supabase.auth.currentUser;

  if (user == null) {
    throw StateError(
      'WardrobeRepository cannot be created without a logged-in user.',
    );
  }

  final shouldCreateNewRepository =
      _wardrobeRepository == null || _cachedUserId != user.id;

  if (shouldCreateNewRepository) {
    _cachedUserId = user.id;
    _wardrobeRepository = WardrobeRepository(supabase);
  }

  return _wardrobeRepository!;
}

OutfitRepository getOutfitRepository() {
  final supabase = Supabase.instance.client;
  final user = supabase.auth.currentUser;

  if (user == null) {
    throw StateError(
      'OutfitRepository cannot be created without a logged-in user.',
    );
  }

  final shouldCreateNewRepository =
      _outfitRepository == null || _cachedUserId != user.id;

  if (shouldCreateNewRepository) {
    _cachedUserId = user.id;
    _outfitRepository = OutfitRepository(supabase);
  }

  return _outfitRepository!;
}

CalendarRepository getCalendarRepository() {
  final supabase = Supabase.instance.client;
  final user = supabase.auth.currentUser;
  if (user == null) {
    throw StateError(
      'CalendarRepository cannot be created without a logged-in user.',
    );
  }
  final shouldCreate = _calendarRepository == null || _cachedUserId != user.id;
  if (shouldCreate) {
    _cachedUserId = user.id;
    _calendarRepository = CalendarRepository(supabase);
  }
  return _calendarRepository!;
}

void clearUserScopedRepositories() {
  _tagsRepository = null;
  _wardrobeRepository = null;
  _outfitRepository = null;
  _calendarRepository = null;
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
            GoRoute(
              path: ':id',
              builder: (context, state) {
                final id = int.tryParse(state.pathParameters['id'] ?? '');
                if (id == null) {
                  return const Scaffold(
                    body: Center(child: Text('Invalid item ID')),
                  );
                }
                return WardrobeDetailPage(clothesId: id);
              },
            ),
          ],
        ),

        GoRoute(
          path: '/calendar',
          builder: (context, state) => const CalendarPage(),
          routes: [
            GoRoute(
              path: 'day',
              builder: (context, state) {
                final date = state.extra as DateTime? ?? DateTime.now();
                return CalendarDayRecapPage(date: date);
              },
            ),
            GoRoute(
              path: 'event/new',
              builder: (context, state) {
                final prefillDate = state.extra as DateTime?;
                return EventEditPage(prefillDate: prefillDate);
              },
            ),
            GoRoute(
              path: 'event/:id/edit',
              builder: (context, state) {
                final id = int.tryParse(state.pathParameters['id'] ?? '');
                if (id == null) {
                  return const Scaffold(
                    body: Center(child: Text('Invalid event ID')),
                  );
                }
                return EventEditPage(eventId: id);
              },
            ),
            GoRoute(
              path: 'ootd/new',
              builder: (context, state) {
                final prefillDate = state.extra as DateTime?;
                return OotdEditPage(prefillDate: prefillDate);
              },
            ),
            GoRoute(
              path: 'ootd/:id/edit',
              builder: (context, state) {
                final id = int.tryParse(state.pathParameters['id'] ?? '');
                if (id == null) {
                  return const Scaffold(
                    body: Center(child: Text('Invalid OOTD ID')),
                  );
                }
                return OotdEditPage(ootdId: id);
              },
            ),
          ],
        ),
        GoRoute(
          path: '/studio',
          builder: (context, state) {
            return StudioPage(outfitRepository: getOutfitRepository());
          },
          routes: [
            GoRoute(
              path: 'add/manual',
              builder: (context, state) {
                return ManualBuildPage(
                  wardrobeRepository: getWardrobeRepository(),
                  tagsRepository: getTagsRepository(),
                );
              },
            ),
            GoRoute(
              path: 'add/review',
              builder: (context, state) {
                final selectedItems = state.extra as List<WardrobeClothingItem>;
                return ReviewBuildPage(
                  selectedItems: selectedItems,
                  tagsRepository: getTagsRepository(),
                );
              },
            ),
            GoRoute(
              path: 'add/ai',
              builder: (context, state) {
                return OutfitCreatorPage(
                  wardrobeRepository: getWardrobeRepository(),
                  tagsRepository: getTagsRepository(),
                );
              },
            ),
            GoRoute(
              path: 'ai/results',
              builder: (context, state) {
                final controller = state.extra as OutfitCreatorController;
                return OutfitResultsPage(controller: controller);
              },
            ),
            GoRoute(
              path: 'ai/detail',
              builder: (context, state) {
                final suggestion = state.extra as OutfitSuggestion;
                return OutfitDetailPage(suggestion: suggestion);
              },
            ),
          ],
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
