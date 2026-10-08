import 'package:aniweb/features/bookmarks/presentation/bookmark_group_screen.dart';
import 'package:aniweb/features/bookmarks/presentation/bookmarks_screen.dart';
import 'package:aniweb/features/browser/presentation/browser_screen.dart';
import 'package:aniweb/features/downloads/presentation/downloads_screen.dart';
import 'package:aniweb/features/gallery/presentation/gallery_screen.dart';
import 'package:aniweb/features/history/presentation/browser_history_screen.dart';
import 'package:aniweb/features/home/presentation/home_screen.dart';
import 'package:aniweb/features/settings/presentation/settings_screen.dart';
import 'package:aniweb/features/shell/presentation/navigation_shell.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/home',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => NavigationShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/browser',
                builder: (context, state) {
                  final url = state.uri.queryParameters['url'];
                  return BrowserScreen(initialUrl: url);
                },
                routes: [
                  GoRoute(
                    path: 'history',
                    builder: (context, state) => const BrowserHistoryScreen(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/downloads',
                builder: (context, state) => const DownloadsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/gallery',
                builder: (context, state) => const GalleryScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/bookmarks',
                builder: (context, state) => const BookmarksScreen(),
                routes: [
                  GoRoute(
                    path: 'group/:id',
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      final name = state.extra as String? ?? 'Group';
                      return BookmarkGroupScreen(groupId: id, groupName: name);
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
