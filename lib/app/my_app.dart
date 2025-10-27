import 'package:ct312h_project/app/router.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// import 'package:ct312h_project/app/locator.dart';
// import 'package:ct312h_project/viewmodels/posts_manager.dart';
// import 'package:ct312h_project/viewmodels/user_cache_manager.dart';
// import 'package:ct312h_project/viewmodels/search_manager.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Provider(create: (_) => getIt<UserCacheManager>()),
        // ChangeNotifierProvider(create: (_) => getIt<PostsManager>()),
        // ChangeNotifierProvider(create: (_) => getIt<SearchManager>()),
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
