import 'package:ct312h_project/app/app_route.dart';
import 'package:ct312h_project/app/theme.dart';
import 'package:ct312h_project/services/local_notification_service.dart';
import 'package:ct312h_project/viewmodels/viewmodels.dart';
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
    ThemeData mainTheme = buildTheme();

    return MaterialApp.router(
      title: 'Aidos',
      debugShowMaterialGrid: false,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      debugShowCheckedModeBanner: false,
      theme: mainTheme,
      routerConfig: router,
    );
  }
}
