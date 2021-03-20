import 'package:flutter/material.dart';

class Model with ChangeNotifier {
  int _activeTab = 0;
  int get activeTab => _activeTab;

  void setActiveTab(int v) {
    _activeTab = v;
    notifyListeners();
  }
}
