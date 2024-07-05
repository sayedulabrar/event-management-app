import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:rive_flutter/service/auth_service.dart';
import 'package:rive_flutter/service/navigation_service.dart';

import '../../../model/menu.dart';
import '../../../utils/rive_utils.dart';
import 'info_card.dart';
import 'side_menu.dart';

class SideBar extends StatefulWidget {
  final Function(Menu) onMenuSelected;

  const SideBar({super.key, required this.onMenuSelected});

  @override
  State<SideBar> createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  late AuthService _authService;
  late NavigationService _navigationService;
  final GetIt _getIt = GetIt.instance;
  Menu selectedSideMenu = sidebarMenus.first;

  @override
  void initState() {
    super.initState();
    _authService = _getIt.get<AuthService>();
    _navigationService = _getIt.get<NavigationService>();
    _authService.fetchUserRole();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 288,
      height: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF324681),
        borderRadius: BorderRadius.all(
          Radius.circular(30),
        ),
      ),
      child: DefaultTextStyle(
        style: const TextStyle(color: Colors.white),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InfoCard(
              name: _authService.user!.email ?? "User",
              bio: _authService.role ?? "Admin",
            ),
            Padding(
              padding: const EdgeInsets.only(left: 24, top: 32, bottom: 16),
              child: Text(
                "Browse".toUpperCase(),
                style: Theme.of(context)
                    .textTheme
                    .titleMedium!
                    .copyWith(color: Colors.white70),
              ),
            ),
            ...sidebarMenus
                .map((menu) => SideMenu(
                      menu: menu,
                      selectedMenu: selectedSideMenu,
                      press: () {
                        RiveUtils.chnageSMIBoolState(menu.rive.status!);
                        setState(() {
                          selectedSideMenu = menu;
                        });
                        widget.onMenuSelected(menu);
                      },
                      riveOnInit: (artboard) {
                        menu.rive.status = RiveUtils.getRiveInput(
                          artboard,
                          stateMachineName: menu.rive.stateMachineName,
                        );
                      },
                    ))
                .toList(),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: MyLogoutButton(
                onTap: () {
                  _authService.logout();
                  _navigationService.pushReplacementNamed("/login");
                },
                initialColor: Colors.transparent,
                onPressedColor: Colors.redAccent,
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class MyLogoutButton extends StatefulWidget {
  final Function onTap;
  final Color initialColor;
  final Color onPressedColor;

  const MyLogoutButton({
    Key? key,
    required this.onTap,
    required this.initialColor,
    required this.onPressedColor,
  }) : super(key: key);

  @override
  _MyLogoutButtonState createState() => _MyLogoutButtonState();
}

class _MyLogoutButtonState extends State<MyLogoutButton> {
  bool _isTapped = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isTapped = true;
        });
        widget.onTap();
      },
      child: Container(
        decoration: BoxDecoration(
          color: _isTapped ? widget.onPressedColor : widget.initialColor,
          boxShadow: _isTapped
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: Offset(0, 3), // changes position of shadow
                  ),
                ]
              : [],
        ),
        child: ListTile(
          leading: const Icon(Icons.logout, color: Colors.white),
          title: const Text("Logout", style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}
