
import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';

class AppThemeProvider extends ChangeNotifier {
  final String key = "theme";
  late bool _trueDarkMode;

  bool get trueDarkMode => _trueDarkMode;

  static final AppThemeProvider _instance = AppThemeProvider._internal();

  factory AppThemeProvider() {
    return _instance;
  }

  AppThemeProvider._internal() {
    _trueDarkMode = true;
    _loadprefs();
  }

  switchThemeDark() {
    _trueDarkMode = !_trueDarkMode;
    notifyListeners();
  }

  _loadprefs() async {
    _trueDarkMode = await Settings.getValue("true-dark-mode");
    notifyListeners();
  }
}
