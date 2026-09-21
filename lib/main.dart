import 'package:flutter/material.dart';

import 'app.dart';
import 'config/di/service_locator.dart';

void main() {
  setupServiceLocator();
  runApp(const MyApp());
}

class MyApp extends CinefyApp {
  const MyApp({super.key});
}
