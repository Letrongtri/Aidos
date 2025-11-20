import 'package:ct312h_project/app/my_app.dart';
import 'package:ct312h_project/services/local_notification_service.dart';
import 'package:ct312h_project/utils/timezone.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await configureLocalTimeZone();

  final localNotificationService = LocalNotificationService();
  await localNotificationService.init();

  // final NotificationAppLaunchDetails? notificationAppLaunchDetails =
  //     await notificationService.getNotificationAppLaunchDetails();

  await dotenv.load();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) => MyApp(localNotifService: localNotificationService),
    ),
  );
}
