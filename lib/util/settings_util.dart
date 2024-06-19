import 'package:flutter_settings_screens/flutter_settings_screens.dart';

class SettingsUtil {

  static bool getValueBool(String key,bool defaultValue) {
    return Settings.getValue<bool>(key,defaultValue: defaultValue)??defaultValue;
  }
  static String getValueString(String key, String defaultValue) {
    return Settings.getValue<String>(key, defaultValue: defaultValue) ?? defaultValue;
  }
  static int getValueInt(String key,int defaultValue) {
    try {
      return Settings.getValue<int>(key, defaultValue: defaultValue) ?? defaultValue;
    }catch(e) {
      return int.tryParse(Settings.getValue<String>(key,defaultValue: "$defaultValue")??"$defaultValue")??defaultValue;
    }
  }
}
