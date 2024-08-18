import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:rive/rive.dart';
import 'package:rive_flutter/screens/add_user/add_users.dart';
import 'package:rive_flutter/screens/events/events.dart';
import 'package:rive_flutter/screens/events/summary.dart';
import 'package:rive_flutter/screens/notifications/notifications.dart';
import 'package:rive_flutter/service/auth_service.dart';
import 'package:rive_flutter/service/local_notification.dart';
import 'package:rive_flutter/service/push_notification.dart';
import '../../constants.dart';
import '../home/home_screen.dart';
import '../../model/menu.dart';
import 'components/menu_btn.dart';
import 'components/side_bar.dart';
import 'package:timezone/data/latest.dart' as tz;

Set<String> notifiedEvents = Set<String>();

class EntryPoint extends StatefulWidget {
  const EntryPoint({super.key});

  @override
  State<EntryPoint> createState() => _EntryPointState();
}

class _EntryPointState extends State<EntryPoint>
    with SingleTickerProviderStateMixin {
  bool isSideBarOpen = false;
  Menu selectedSideMenu = sidebarMenus.first;
  final GetIt _getIt = GetIt.instance;
  late PushNotificationService _pushNotificationService;
  late AuthService _authService;

  late SMIBool isMenuOpenInput;
  late AnimationController _animationController;
  late Animation<double> scalAnimation;
  late Animation<double> animation;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _authService = _getIt.get<AuthService>();
    _pushNotificationService = _getIt.get<PushNotificationService>();
    _authService.fetchUserRole();
    tz.initializeTimeZones();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    )..addListener(() {
        setState(() {});
      });
    scalAnimation = Tween<double>(begin: 1, end: 0.8).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.fastOutSlowIn,
      ),
    );
    animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.fastOutSlowIn,
      ),
    );
    _pageController = PageController();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onMenuSelected(Menu menu) {
    setState(() {
      selectedSideMenu = menu;
      isSideBarOpen = false;
    });
    _pageController.jumpToPage(sidebarMenus.indexOf(menu));
    if (_animationController.value != 0) {
      _animationController.reverse();
      isMenuOpenInput.value = true; // Update the menu button state
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      resizeToAvoidBottomInset: false,
      backgroundColor: backgroundColor2,
      body: Stack(
        children: [
          AnimatedPositioned(
            width: 288,
            height: MediaQuery.of(context).size.height,
            duration: const Duration(milliseconds: 200),
            curve: Curves.fastOutSlowIn,
            left: isSideBarOpen ? 0 : -288,
            top: 0,
            child: SideBar(onMenuSelected: _onMenuSelected),
          ),
          Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(
                  1 * animation.value - 30 * (animation.value) * pi / 180),
            child: Transform.translate(
              offset: Offset(animation.value * 265, 0),
              child: Transform.scale(
                scale: scalAnimation.value,
                child: ClipRRect(
                  borderRadius: BorderRadius.all(
                    Radius.circular(24),
                  ),
                  child: PageView(
                    controller: _pageController,
                    children: [
                      HomePage(
                          pushNotificationService: _pushNotificationService),
                      Events(),
                      Notifications(),
                      _authService.role == "user"
                          ? HomePage(
                              pushNotificationService: _pushNotificationService)
                          : AddUsers(),
                      EventLevelChart()
                    ],
                  ),
                ),
              ),
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 200),
            curve: Curves.fastOutSlowIn,
            left: isSideBarOpen ? 220 : 0,
            top: 6,
            child: MenuBtn(
              press: () {
                isMenuOpenInput.value = !isMenuOpenInput.value;

                if (_animationController.value == 0) {
                  _animationController.forward();
                } else {
                  _animationController.reverse();
                }

                setState(() {
                  isSideBarOpen = !isSideBarOpen;
                });
              },
              riveOnInit: (artboard) {
                final controller = StateMachineController.fromArtboard(
                  artboard,
                  "State Machine",
                );

                artboard.addController(controller!);
                isMenuOpenInput =
                    controller.findInput<bool>("isOpen") as SMIBool;
                isMenuOpenInput.value =
                    true; // Set initial value to closed state
              },
            ),
          ),
        ],
      ),
    );
  }
}
