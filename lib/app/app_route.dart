import 'package:ct312h_project/models/post.dart';
import 'package:ct312h_project/ui/screens.dart';
import 'package:ct312h_project/viewmodels/auth_manager.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

enum AppRouteName {
  auth,
  autoLogin,
  feed,
  search,
  profile,
  post,
  notification,
  detailPost,
  logout,
}

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
        GoRoute(
          path: '/auth',
          name: AppRouteName.auth.name,
          builder: (context, state) => AuthScreen(),
        ),
        GoRoute(
          path: '/auto-login',
          name: AppRouteName.autoLogin.name,
          builder: (context, state) => FutureBuilder(
            future: authManager.tryAutoLogin(),
            builder: (context, _) => const SafeArea(child: SplashScreen()),
          ),
        ),
        GoRoute(
          path: '/logout',
          name: AppRouteName.logout.name,
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
                  name: AppRouteName.feed.name,
                  builder: (context, state) => FeedScreen(),
                  routes: [
                    GoRoute(
                      name: AppRouteName.detailPost.name,
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
                  name: AppRouteName.search.name,
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
                  name: AppRouteName.post.name,
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
                  name: AppRouteName.notification.name,
                  builder: (context, state) => const NotificationScreen(),
                ),
              ],
            ),

            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/home/profile',
                  name: AppRouteName.profile.name,
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
