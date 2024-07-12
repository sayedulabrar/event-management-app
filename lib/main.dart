import 'dart:async';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:get_it/get_it.dart';
import 'package:rive_flutter/app.dart';
import 'package:rive_flutter/firebase_options.dart';
import 'package:rive_flutter/screens/entryPoint/components/menu_state.dart';
import 'package:rive_flutter/service/Eventonitor.dart';
import 'package:rive_flutter/service/alert_service.dart';
import 'package:rive_flutter/service/auth_service.dart';
import 'package:rive_flutter/service/local_notification.dart';
import 'package:rive_flutter/service/navigation_service.dart';
import 'package:rive_flutter/service/push_notification.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tzz;
void main() async {
  await setup();
  runApp(App());
}

Future<void> setup() async {
  WidgetsFlutterBinding.ensureInitialized();
  try{
    await Future(() {
      tz.initializeTimeZones();
      tzz.setLocalLocation(tzz.getLocation('Asia/Dhaka'));
    });

  }catch(e)
  {
    print('Error during setup: $e');
  }

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await registerServices();
  await GetIt.I<NotificationService>().init();
  await GetIt.I<PushNotificationService>().initialize();
  await initializeBackgroundService();
}

Future<void> registerServices() async {
  final getIt = GetIt.instance;
  getIt.registerSingleton<AuthService>(AuthService());
  getIt.registerSingleton<NavigationService>(NavigationService());
  getIt.registerSingleton<AlertService>(AlertService());
  getIt.registerSingleton<MenuState>(MenuState());
  getIt.registerSingleton<PushNotificationService>(PushNotificationService());
  getIt.registerSingleton<NotificationService>(NotificationService());
}

Future<void> initializeBackgroundService() async {
  final service = FlutterBackgroundService();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true,
      initialNotificationContent: 'Background Service Running',
      initialNotificationTitle: 'App Name',
    ),
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
  );

  service.startService();
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  print("Background Service: Starting");

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize GetIt
  await registerServices();

  final eventMonitor = EventMonitor();
  eventMonitor.startMonitoring();

  // Periodic check to ensure the service is running
  Timer.periodic(Duration(minutes: 1), (timer) {
    print("Background Service: Still running");
  });
}