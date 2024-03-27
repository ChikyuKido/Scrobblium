import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:scrobblium/service/app_theme_provider.dart';
import 'package:scrobblium/util/settings_helper.dart';

class AppearanceSettingsPage extends StatefulWidget {
  const AppearanceSettingsPage({super.key});

  @override
  State<AppearanceSettingsPage> createState() => _AppearanceSettingsPageState();
}

class _AppearanceSettingsPageState extends State<AppearanceSettingsPage> {
  final List<List<FlexScheme>> colors = [
    [FlexScheme.amber, FlexScheme.wasabi, FlexScheme.deepBlue, FlexScheme.aquaBlue],
    [FlexScheme.damask, FlexScheme.espresso, FlexScheme.gold, FlexScheme.green],
    [FlexScheme.dellGenoa, FlexScheme.jungle, FlexScheme.mango, FlexScheme.red],
    [FlexScheme.flutterDash, FlexScheme.shark, FlexScheme.sakura, FlexScheme.rosewood],
  ];
  FlexScheme? selectedColor;

  @override
  void initState() {
    var color = getValueString("theme-color", "amber");
    selectedColor =
        FlexScheme.values.where((element) => element.name == color).first;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SettingsScreen(
        children: [_buildTrueDarkMode(), _buildMaterialTheme()]);
  }

  Widget _buildTrueDarkMode() {
    return SwitchSettingsTile(
      topPadding: 0.0,
      title: "Use true dark mode",
      settingKey: "true-dark-mode",
      defaultValue: false,
      onChange: (p0) => AppThemeProvider().setTrueDarkMode(p0),
    );
  }

  Widget _buildMaterialTheme() {
    return SwitchSettingsTile(
      topPadding: 0.0,
      title: "Use material theme",
      settingKey: "material-theme",
      defaultValue: false,
      onChange: (p0) => AppThemeProvider().setMaterialTheme(p0),
      reverseChildrenIfEnabled: true,
      childrenPadding: EdgeInsets.zero,
      childrenIfEnabled: [_buildThemeColorPicker()],
    );
  }

  Widget _buildThemeColorPicker() {
    return SimpleSettingsTile(
        title: "Pick color theme",
        onTap: () => showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text('Pick a Color'),
                  content: _buildColorPicker(),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Close'),
                    ),
                  ],
                );
              },
            ));
  }

  void selectColor(FlexScheme color) {
    selectedColor = color;
    Settings.setValue("theme-color", color.name);
    AppThemeProvider().setMaterialColor(color);
  }

  Widget _buildColorPicker() {
    return Container(
      constraints: const BoxConstraints(maxHeight: 200),
      child: ListView.builder(
        itemCount: colors.length,
        itemBuilder: (context, row) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: colors[row].map((color) {
                return GestureDetector(
                  onTap: () {
                    selectColor(color);
                  },
                  child: Container(
                    width: 30 + (selectedColor == color ? 4 : 0),
                    height: 30 + (selectedColor == color ? 4 : 0),
                    decoration: BoxDecoration(
                      color: FlexThemeData.dark(scheme: color).primaryColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: selectedColor == color
                            ? Colors.black
                            : Colors.transparent,
                        width: 4,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}
