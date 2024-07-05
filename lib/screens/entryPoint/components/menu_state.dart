import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class MenuState extends ChangeNotifier {
  late SMIBool isMenuOpenInput;
  bool _isMenuOpen = false;

  bool get isMenuOpen => _isMenuOpen;

  void toggleMenu() {
    _isMenuOpen = !_isMenuOpen;
    isMenuOpenInput.value = _isMenuOpen;
    notifyListeners();
  }

  void setMenuInput(SMIBool input) {
    isMenuOpenInput = input;
    isMenuOpenInput.value = _isMenuOpen;
  }
}
