import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flex_color_scheme/src/flex_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';

class AppThemeProvider extends ChangeNotifier {
  final String key = "theme";
  late bool _trueDarkMode;
  late bool _materialTheme;
  late bool _darkMode;
  late FlexScheme _colorScheme;

  bool get trueDarkMode => _trueDarkMode;

  bool get materialTheme => _materialTheme;

  bool get darkMode => _darkMode;

  FlexScheme get colorScheme => _colorScheme;

  static final AppThemeProvider _instance = AppThemeProvider._internal();

  factory AppThemeProvider() {
    return _instance;
  }

  AppThemeProvider._internal() {
    _loadPrefs();
  }

  setTrueDarkMode(bool darkMode) {
    _trueDarkMode = darkMode;
    notifyListeners();
  }

  setMaterialTheme(bool materialTheme) {
    _materialTheme = materialTheme;
    notifyListeners();
  }

  setDarkMode(bool darkMode) {
    _materialTheme = materialTheme;
    notifyListeners();
  }

  _loadPrefs() {
    _trueDarkMode =
        Settings.getValue<bool>("true-dark-mode", defaultValue: false) ?? false;
    _materialTheme =
        Settings.getValue<bool>("material-theme", defaultValue: false) ?? false;
    _darkMode =
        Settings.getValue<bool>("dark-mode", defaultValue: true) ?? true;
    var c = Settings.getValue<String>("theme-color", defaultValue: "amber") ??
        "amber";
    _colorScheme =
        FlexScheme.values.where((element) => element.name == c).first;
    notifyListeners();
  }

  void setMaterialColor(FlexScheme color) {
    _colorScheme = color;
    notifyListeners();
  }
}
