import 'package:ct312h_project/app/my_app.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load();
  // setupLocator();
  runApp(DevicePreview(enabled: !kReleaseMode, builder: (context) => MyApp()));
}
