import 'rive_model.dart';

class Menu {
  final String title;
  final RiveModel rive;

  Menu({
    required this.title,
    required this.rive,
  });
}

List<Menu> sidebarMenus = [
  Menu(
    title: "Home",
    rive: RiveModel(
      src: "assets/RiveAssets/icons.riv",
      artboard: "HOME",
      stateMachineName: "HOME_interactivity",
    ),
  ),
  Menu(
    title: "Events",
    rive: RiveModel(
      src: "assets/RiveAssets/icons.riv",
      artboard: "LIKE/STAR",
      stateMachineName: "STAR_Interactivity",
    ),
  ),

  Menu(
    title: "Reminders",
    rive: RiveModel(
      src: "assets/RiveAssets/icons.riv",
      artboard: "BELL",
      stateMachineName: "BELL_Interactivity",
    ),
  ),
  Menu(
    title: "Add Users",
    rive: RiveModel(
      src: "assets/RiveAssets/icons.riv",
      artboard: "USER",
      stateMachineName: "USER_Interactivity",
    ),
  ),
  Menu(
    title: "Summary",
    rive: RiveModel(
      src: "assets/RiveAssets/icons.riv",
      artboard: "TIMER",
      stateMachineName: "TIMER_Interactivity",
    ),
  ),
];
