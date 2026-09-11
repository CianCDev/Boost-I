import 'package:flutter/material.dart';

class PanelProvider extends ChangeNotifier {
  bool _isOpen = false;
  bool get isOpen => _isOpen;

  void openPanel() {
    _isOpen = true;
    notifyListeners();
  }

  void closePanel() {
    _isOpen = false;
    notifyListeners();
  }

  void togglePanel() {
    _isOpen = !_isOpen;
    notifyListeners();
  }
}