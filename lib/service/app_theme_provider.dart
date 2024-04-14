import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:scrobblium/util/settings_helper.dart';

class AppThemeProvider extends ChangeNotifier {
  late bool _trueDarkMode;
  late bool _materialTheme;
  late FlexScheme _colorScheme;

  bool get trueDarkMode => _trueDarkMode;
  bool get materialTheme => _materialTheme;
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


  _loadPrefs() {
    _trueDarkMode = getValueBool("true-dark-mode", false);
    _materialTheme = getValueBool("material-theme", false);
    var c = getValueString("theme-color", "amber");
    _colorScheme = FlexScheme.values.where((element) => element.name == c).first;
    notifyListeners();
  }

  void setMaterialColor(FlexScheme color) {
    _colorScheme = color;
    notifyListeners();
  }
}
