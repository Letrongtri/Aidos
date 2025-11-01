import 'package:ct312h_project/services/nofication_service.dart';
import 'package:ct312h_project/ui/activity/favorite_screen.dart';
import 'package:ct312h_project/ui/auth/auth_screen.dart';
import 'package:ct312h_project/ui/home/home_page_screen.dart';
import 'package:ct312h_project/ui/posts/detail_post_screen.dart';
import 'package:ct312h_project/ui/posts/feed_screen.dart';
import 'package:ct312h_project/ui/posts/post_screen.dart';
import 'package:ct312h_project/ui/search/search_screen.dart';
import 'package:ct312h_project/ui/splash_screen.dart';
import 'package:ct312h_project/ui/user/profile_screen.dart';
import 'package:ct312h_project/viewmodels/auth_manager.dart';
import 'package:ct312h_project/viewmodels/pofile_manager.dart';
import 'package:ct312h_project/viewmodels/posts_manager.dart';
import 'package:ct312h_project/viewmodels/search_manager.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class MyApp extends StatelessWidget {
  final authManager = AuthManager();
  MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      initialLocation: '/auto-login',
      refreshListenable: authManager, // listen to auth state changes
      redirect: (context, state) {
        final authManager = context.read<AuthManager>();
        final isAtAuthScreen = state.fullPath == '/auth';

        if (!authManager.isAuth && !isAtAuthScreen) {
          return '/auth';
        }

        if (authManager.isAuth && isAtAuthScreen) {
          return '/home/feed';
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/auth',
          name: 'auth',
          builder: (context, state) => AuthScreen(),
        ),

        GoRoute(
          path: '/auto-login',
          builder: (context, state) {
            return FutureBuilder(
              future: context.read<AuthManager>().tryAutoLogin(),
              builder: (context, authSnapshot) =>
                  SafeArea(child: SplashScreen()),
            );
          },
        ),
        GoRoute(
          path: '/logout',
          builder: (context, state) {
            return FutureBuilder(
              future: context.read<AuthManager>().logout(),
              builder: (context, authSnapshot) =>
                  SafeArea(child: SplashScreen()),
            );
          },
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

    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authManager),
        ChangeNotifierProvider(create: (_) => PostsManager()),
        ChangeNotifierProvider(create: (_) => SearchManager()),
        ChangeNotifierProvider(create: (_) => ProfileManager()),
        ChangeNotifierProvider(create: (_) => NotificationManager()),
      ],
      child: MaterialApp.router(
        title: 'Aido',
        locale: DevicePreview.locale(context),
        builder: DevicePreview.appBuilder,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.dark(
            primary: Colors.white,
            onPrimary: Colors.black,
          ),
          useMaterial3: true,
        ),
        routerConfig: router,
      ),
    );
  }
}
