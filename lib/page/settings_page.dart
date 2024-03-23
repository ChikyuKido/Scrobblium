import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:scrobblium/service/app_theme_provider.dart';
import 'package:scrobblium/service/song_provider_service.dart';
import 'package:scrobblium/song_data.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final List<List<FlexScheme>> colors = [
    [
      FlexScheme.amber,
      FlexScheme.wasabi,
      FlexScheme.deepBlue,
      FlexScheme.aquaBlue
    ],
    [FlexScheme.damask, FlexScheme.espresso, FlexScheme.gold, FlexScheme.green],
    [FlexScheme.dellGenoa, FlexScheme.jungle, FlexScheme.mango, FlexScheme.red],
    [
      FlexScheme.yellowM3,
      FlexScheme.shark,
      FlexScheme.sakura,
      FlexScheme.rosewood
    ],
  ];
  FlexScheme? selectedColor;

  @override
  void initState() {
    super.initState();
    var color =
        Settings.getValue("theme-color", defaultValue: "amber") ?? "amber";
    selectedColor =
        FlexScheme.values.where((element) => element.name == color).first;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: ListView(
      padding: const EdgeInsets.all(8.0),
      children: [
        SettingsGroup(title: "Tracking", children: <Widget>[
          _futureWidget(_buildNotificationAccess()),
          _futureWidget(buildMusicPackage()),
          _futureWidget(_buildForegroundProcess()),
          _futureWidget(_buildValidationInfo())
        ]),
        SettingsGroup(title: "Stats", children: [
          buildSkipCap(),
        ]),
        SettingsGroup(title: "Appearance", children: <Widget>[
          buildTrueDarkMode(),
          buildMaterialTheme(),
          buildThemeColorPicker()
        ]),
        SettingsGroup(
            title: "Save/Load",
            children: <Widget>[buildExportDB(), buildImportDB()]),
      ],
    ));
  }

  Widget buildTrueDarkMode() {
    return SwitchSettingsTile(
      topPadding: 0.0,
      title: "Use true dark mode",
      settingKey: "true-dark-mode",
      defaultValue: false,
      onChange: (p0) => AppThemeProvider().setTrueDarkMode(p0),
    );
  }

  Widget buildMaterialTheme() {
    return SwitchSettingsTile(
      topPadding: 0.0,
      title: "Use material theme",
      settingKey: "material-theme",
      defaultValue: false,
      onChange: (p0) {
        AppThemeProvider().setMaterialTheme(p0);
        setState(() {});
      },
    );
  }

  Widget buildThemeColorPicker() {
    bool active =
        Settings.getValue("material-theme", defaultValue: false) ?? false;
    return active
        ? Container()
        : SimpleSettingsTile(
            title: "Pick color theme",
            onTap: () {
              showDialog(
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
              );
            },
          );
  }

  Future<Widget> buildMusicPackage() async {
    bool granted = await SongProviderService.isNotificationPermissionGranted();
    return granted
        ? TextInputSettingsTile(
            topPadding: 0.0,
            title: 'Music app package',
            settingKey: 'music-app-package',
            initialValue: '',
            onChange: (p0) {
              SongProviderService.setMusicPackage(p0);
            },
          )
        : Container();
  }

  Widget buildSkipCap() {
    return TextInputSettingsTile(
      title: 'Skip cap',
      settingKey: 'skip-cap',
      helperText: 'The time when a track is counted as skip',
      initialValue: '20',
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Value can't be null or empty";
        }
        if (int.tryParse(value) == null) {
          return "Value not a number";
        }
        return null;
      },
    );
  }

  Widget _futureWidget(Future<Widget> wid) {
    return FutureBuilder(
        future: wid,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }
          return snapshot.data ?? Container();
        });
  }

  Future<Widget> _buildNotificationAccess() async {
    bool granted = await SongProviderService.isNotificationPermissionGranted();
    return SimpleSettingsTile(
      padding: const EdgeInsets.only(top: 16.0),
      title: "Notification access is ${granted ? "granted" : "denied"}",
      subtitle: "Tap to open Notification settings",
      onTap: () => SongProviderService.launchNotificationAccess(),
    );
  }

  Future<Widget> _buildForegroundProcess() async {
    bool granted = await SongProviderService.isNotificationPermissionGranted();
    String status = await SongProviderService.getMusicListenerServiceStatus();
    return granted
        ? SimpleSettingsTile(
            title: "Tracker status: $status",
            subtitle: "Tap to start the background process",
            onTap: () async {
              await SongProviderService.startForegroundProcess();
              setState(() {});
            },
          )
        : Container();
  }

  Future<Widget> _buildValidationInfo() async {
    SongData? s = await SongProviderService.getCurrentSong();
    String status = await SongProviderService.getMusicListenerServiceStatus();
    return status == "TRACKING"
        ? SimpleSettingsTile(
            title: s == null ? "Could not find currentSong" : "Found music App",
            subtitle: s != null
                ? s.getIdentifier()
                : "Maybe start the music or the package is wrong",
            onTap: () => setState(() {}))
        : Container();
  }

  Widget buildExportDB() {
    return SimpleSettingsTile(
        title: "Export Database",
        onTap: () async {
          await SongProviderService.exportDatabase();
        });
  }

  Widget buildImportDB() {
    return SimpleSettingsTile(
        title: "Import Database",
        onTap: () async {
          SongProviderService.importDatabase();
        });
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
