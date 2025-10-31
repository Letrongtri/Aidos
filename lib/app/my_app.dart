import 'package:ct312h_project/ui/activity/favorite_screen.dart';
import 'package:ct312h_project/ui/auth/auth_screen.dart';
import 'package:ct312h_project/ui/home/home_page_screen.dart';
import 'package:ct312h_project/ui/posts/feed_screen.dart';
import 'package:ct312h_project/ui/posts/post_screen.dart';
import 'package:ct312h_project/ui/splash_screen.dart';
import 'package:ct312h_project/ui/user/profile_screen.dart';
import 'package:ct312h_project/viewmodels/auth_manager.dart';
import 'package:ct312h_project/viewmodels/posts_manager.dart';
import 'package:ct312h_project/viewmodels/profile_viewmodel.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

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
              builder: (context, _) => const SplashScreen(),
            );
          },
        ),

        GoRoute(
          path: '/logout',
          builder: (context, state) {
            return FutureBuilder(
              future: context.read<AuthManager>().logout(),
              builder: (context, _) => const SplashScreen(),
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
                  builder: (context, state) => const FeedScreen(),
                ),
              ],
            ),

            // Branch 1: Post
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/home/post',
                  name: 'post',
                  builder: (context, state) => const PostScreen(),
                ),
              ],
            ),

            // Branch 2: Notification
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/home/notification',
                  name: 'notification',
                  builder: (context, state) => const FavoriteScreen(),
                ),
              ],
            ),

            // Branch 3: Profile
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/home/profile',
                  name: 'profile',
                  builder: (context, state) {
                    return ChangeNotifierProvider(
                      create: (_) => ProfileViewModel()..loadCurrentUser(),
                      child: const ProfileScreen(),
                    );
                  },
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
      ],
      child: MaterialApp.router(
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
      ),
    );
  }
}
