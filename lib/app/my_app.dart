import 'package:ct312h_project/models/post.dart';
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
import 'package:ct312h_project/viewmodels/notification_manager.dart';
import 'package:ct312h_project/viewmodels/pofile_manager.dart';
import 'package:ct312h_project/viewmodels/posts_manager.dart';
import 'package:ct312h_project/viewmodels/search_manager.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authManager = AuthManager();

    final router = GoRouter(
      initialLocation: '/auto-login',
      refreshListenable: authManager,
      redirect: (context, state) {
        final authManager = context.read<AuthManager>();
        final isAtAuthScreen = state.fullPath == '/auth';

        if (!authManager.isAuth && !isAtAuthScreen) return '/auth';
        if (authManager.isAuth && isAtAuthScreen) return '/home/feed';
        return null;
      },
      routes: [
        GoRoute(path: '/auth', builder: (context, state) => AuthScreen()),
        GoRoute(
          path: '/auto-login',
          builder: (context, state) => FutureBuilder(
            future: context.read<AuthManager>().tryAutoLogin(),
            builder: (context, _) => const SafeArea(child: SplashScreen()),
          ),
        ),
        GoRoute(
          path: '/logout',
          builder: (context, state) => FutureBuilder(
            future: context.read<AuthManager>().logout(),
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
                  builder: (context, state) => const FavoriteScreen(),
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

    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authManager),
        ChangeNotifierProvider(create: (_) => PostsManager()),
        ChangeNotifierProvider(create: (_) => SearchManager()),
        ChangeNotifierProvider(create: (_) => ProfileManager()),
        ChangeNotifierProvider(create: (_) => NotificationManager()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp.router(
            title: 'Aido',
            locale: DevicePreview.locale(context),
            builder: DevicePreview.appBuilder,
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: const ColorScheme.dark(
                primary: Colors.white,
                onPrimary: Colors.black,
              ),
              useMaterial3: true,
            ),
            routerConfig: router,
          );
        },
      ),
    );
  }
}
