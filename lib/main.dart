import 'package:ct312h_project/app/locator.dart';
import 'package:ct312h_project/app/my_app.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() {
  setupLocator();
  runApp(DevicePreview(enabled: !kReleaseMode, builder: (context) => MyApp()));
}
