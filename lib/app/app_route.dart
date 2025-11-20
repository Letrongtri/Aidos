import 'package:ct312h_project/models/post.dart';
import 'package:ct312h_project/ui/activity/notification_screen.dart';
import 'package:ct312h_project/ui/auth/auth_screen.dart';
import 'package:ct312h_project/ui/home/home_page_screen.dart';
import 'package:ct312h_project/ui/posts/detail_post_screen.dart';
import 'package:ct312h_project/ui/posts/feed_screen.dart';
import 'package:ct312h_project/ui/posts/post_screen.dart';
import 'package:ct312h_project/ui/search/search_screen.dart';
import 'package:ct312h_project/ui/splash_screen.dart';
import 'package:ct312h_project/ui/user/profile_screen.dart';
import 'package:ct312h_project/viewmodels/auth_manager.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppRoute {
  static final rootNavKey = GlobalKey<NavigatorState>();

  static GoRouter createRouter(AuthManager authManager) {
    return GoRouter(
      initialLocation: '/auto-login',
      refreshListenable: authManager,
      redirect: (context, state) {
        final isAtAuthScreen = state.fullPath == '/auth';

        if (!authManager.isAuth && !isAtAuthScreen) return '/auth';
        if (authManager.isAuth && isAtAuthScreen) return '/home/feed';
        return null;
      },
      navigatorKey: rootNavKey,
      routes: [
        GoRoute(path: '/auth', builder: (context, state) => AuthScreen()),
        GoRoute(
          path: '/auto-login',
          builder: (context, state) => FutureBuilder(
            future: authManager.tryAutoLogin(),
            builder: (context, _) => const SafeArea(child: SplashScreen()),
          ),
        ),
        GoRoute(
          path: '/logout',
          builder: (context, state) => FutureBuilder(
            future: authManager.logout(),
            builder: (context, _) => const SafeArea(child: SplashScreen()),
          ),
        ),
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) =>
              HomePageScreen(navigationShell: navigationShell),
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/home/feed',
                  builder: (context, state) => FeedScreen(),
                  routes: [
                    GoRoute(
                      name: 'detail',
                      path: 'posts/:id',
                      builder: (context, state) {
                        final id = state.pathParameters['id']!;
                        final focus =
                            (state.extra is Map &&
                            (state.extra as Map)['focusComment'] == true);
                        return DetailPostScreen(id: id, focusComment: focus);
                      },
                    ),
                  ],
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/home/search',
                  builder: (context, state) {
                    final keyword = state.uri.queryParameters['q'];
                    return SearchScreen(keyword: keyword);
                  },
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/home/post',
                  builder: (context, state) {
                    final post = state.extra as Post?;
                    return PostScreen(existingPost: post);
                  },
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/home/notification',
                  builder: (context, state) => const NotificationScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/home/profile',
                  builder: (context, state) => const ProfileScreen(),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
