import 'package:ct312h_project/app/app_route.dart';
import 'package:ct312h_project/services/local_notification_service.dart';
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

class MyApp extends StatefulWidget {
  const MyApp({super.key, required this.localNotifService});

  final LocalNotificationService localNotifService;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AuthManager authManager;
  late final GoRouter router;

  @override
  void initState() {
    super.initState();
    authManager = AuthManager();
    router = AppRoute.createRouter(authManager);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authManager),
        ChangeNotifierProvider(create: (_) => PostsManager()),
        ChangeNotifierProvider(create: (_) => SearchManager()),
        ChangeNotifierProvider(create: (_) => ProfileManager()),
        ChangeNotifierProvider(
          create: (_) => NotificationManager(widget.localNotifService)..init(),
        ),
      ],
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) => _buildMaterialApp(context),
      ),
    );
  }

  MaterialApp _buildMaterialApp(BuildContext context) {
    return MaterialApp.router(
      title: 'Aido',
      debugShowMaterialGrid: false,
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
  }
}
