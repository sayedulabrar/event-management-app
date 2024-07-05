import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:rive_flutter/app.dart';
import 'package:rive_flutter/firebase_options.dart';
import 'package:rive_flutter/screens/entryPoint/components/menu_state.dart';
import 'package:rive_flutter/service/alert_service.dart';
import 'package:rive_flutter/service/auth_service.dart';
import 'package:rive_flutter/service/local_notification.dart';
import 'package:rive_flutter/service/navigation_service.dart';
import 'package:rive_flutter/service/push_notification.dart';

void main() async {
  await setup();
  runApp(App());
}

Future<void> setup() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await registerServices();
}

Future<void> registerServices() async {
  final getIt = GetIt.instance;
  getIt.registerSingleton<AuthService>(
    AuthService(),
  );
  getIt.registerSingleton<NavigationService>(
    NavigationService(),
  );
  getIt.registerSingleton<AlertService>(
    AlertService(),
  );
  getIt.registerSingleton<MenuState>(
    MenuState(),
  );
  getIt.registerSingleton<PushNotificationService>(
    PushNotificationService(),
  );
  getIt.registerSingleton<NotificationService>(NotificationService());
}
