import 'package:ct312h_project/ui/activity/favorite_screen.dart';
import 'package:ct312h_project/ui/posts/detail_post_screen.dart';
import 'package:ct312h_project/ui/home/home_page_screen.dart';
import 'package:ct312h_project/ui/auth/login_screen.dart';
import 'package:ct312h_project/ui/auth/signup_screen.dart';
import 'package:ct312h_project/ui/posts/feed_screen.dart';
import 'package:ct312h_project/ui/search/search_screen.dart';
import 'package:ct312h_project/ui/user/profile_screen.dart';
import 'package:ct312h_project/ui/posts/post_screen.dart';
import 'package:go_router/go_router.dart';

final GoRouter router = GoRouter(
  initialLocation: '/home/feed',
  routes: [
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => LoginScreen(),
    ),
    GoRoute(
      path: '/signup',
      name: 'signup',
      builder: (context, state) => SignupScreen(),
    ),

    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return HomePageScreen(navigationShell: navigationShell);
      },
      branches: [
        // Branch 0: Feed
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home/feed',
              name: 'feed',
              builder: (context, state) => FeedScreen(),
              routes: [
                GoRoute(
                  path: 'posts/:id',
                  name: 'detail',
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

        // Branch 1: Search
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home/search',
              name: 'search',
              builder: (context, state) {
                final keyword = state.uri.queryParameters['q'];
                return SearchScreen(keyword: keyword);
              },
            ),
          ],
        ),

        // Branch 2: Post
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home/post',
              name: 'post',
              builder: (context, state) => const PostScreen(),
            ),
          ],
        ),

        // Branch 3: Notification
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home/notification',
              name: 'notification',
              builder: (context, state) => const FavoriteScreen(),
            ),
          ],
        ),

        // Branch 4: Profile
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home/profile',
              name: 'profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
