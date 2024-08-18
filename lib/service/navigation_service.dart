import 'package:flutter/material.dart';
import 'package:rive_flutter/screens/add_user/add_users.dart';
import 'package:rive_flutter/screens/entryPoint/entry_point.dart';
import 'package:rive_flutter/screens/events/events.dart';
import 'package:rive_flutter/screens/notifications/notifications.dart';
import 'package:rive_flutter/screens/onboding/onboding_screen.dart';

class NavigationService {
  late final GlobalKey<NavigatorState> _navigatorKey;

  final Map<String, Widget Function(BuildContext)> _routes = {
    '/home': (context) => EntryPoint(),
    '/login': (context) => OnbodingScreen(),
    '/events': (context) => Events(),
    '/notifications': (context) => Notifications(),
    '/add-users': (context) => AddUsers()
  };

  GlobalKey<NavigatorState>? get navigatorKey => _navigatorKey;

  Map<String, Widget Function(BuildContext)> get routes {
    return _routes;
  }

  NavigationService() {
    _navigatorKey = GlobalKey<NavigatorState>();
  }

  void push(MaterialPageRoute route) {
    _navigatorKey.currentState?.push(route);
  }

  void pushNamed(String routeName) {
    _navigatorKey.currentState?.pushNamed(routeName);
  }

  void pushReplacementNamed(String routeName) {
    _navigatorKey.currentState?.pushReplacementNamed(routeName);
  }

  void goBack() => _navigatorKey.currentState?.pop();
}
