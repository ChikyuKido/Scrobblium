import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:scrobblium/service/app_theme_provider.dart';
import 'package:scrobblium/service/song_provider_service.dart';
import 'package:scrobblium/song_data.dart';
import 'package:scrobblium/util/database_util.dart';


class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: ListView(
      padding: const EdgeInsets.all(8.0),
      children: [
        SettingsGroup(title: "Tracking", children: <Widget>[
          buildMusicPackage(),
          _futureWidget(_buildNotificationAccess()),
          _futureWidget(_buildForegroundProcess()),
          _futureWidget(_buildValidationInfo())
        ]),
        SettingsGroup(title: "Stats", children: [
          buildSkipCap(),
        ]),
        SettingsGroup(
            title: "Appearance",
            children: <Widget>[buildTrueDarkMode()]),
        SettingsGroup(
            title: "Save/Load",
            children: <Widget>[buildExportDB(), buildImportDB()]),
      ],
    ));
  }

  Widget buildTrueDarkMode() {
    return SwitchSettingsTile(
        title: "Use true dark mode",
        settingKey: "true-dark-mode",
        onChange: (p0) => AppThemeProvider().switchThemeDark(),
    );
  }
  Widget buildMusicPackage() {
    return TextInputSettingsTile(
      title: 'Music app package',
      settingKey: 'music-app-package',
      initialValue: '',
      onChange: (p0) {
        SongProviderService.setMusicPackage(p0);
      },
    );
  }
  Widget buildSkipCap() {
    return TextInputSettingsTile(
      topPadding: 0.0,
      title: 'Skip cap',
      settingKey: 'skip-cap',
      helperText: 'The time when a track is counted as skip',
      initialValue: '20',

      validator: (value) {
        if(value == null || value.isEmpty) {
          return "Value can't be null or empty";
        }
        if(int.tryParse(value) == null) {
          return "Value not a number";
        }
        return null;
      },
    );
  }
  Widget _futureWidget(Future<Widget> wid) {
    return FutureBuilder(future: wid, builder: (context, snapshot) {
      if(snapshot.connectionState == ConnectionState.waiting) {
        return const CircularProgressIndicator();
      }
      return snapshot.data??Container();
    });
  }
  Future<Widget> _buildNotificationAccess() async{
    bool granted = await SongProviderService.isNotificationPermissionGranted();
    return SimpleSettingsTile(
        title: "Notification access is ${granted ? "granted" : "denied"}",
        subtitle: "Tap to open Notification settings",
        onTap: () => SongProviderService.launchNotificationAccess(),
    );
  }
  Future<Widget> _buildForegroundProcess() async {
    bool granted = await SongProviderService.isNotificationPermissionGranted();
    String status = await SongProviderService.getMusicListenerServiceStatus();
    return granted ?
        SimpleSettingsTile(
            title: "Tracker status: $status",
            subtitle: "Tap to start the background process",
            onTap: () async {
              await SongProviderService.startForegroundProcess();
              setState(() {});
            },
        )
        : Container();
  }

  Future<Widget> _buildValidationInfo() async{
    SongData? s = await SongProviderService.getCurrentSong();
    String status = await SongProviderService.getMusicListenerServiceStatus();
    return status == "TRACKING" ? SimpleSettingsTile(
      title: s == null ? "Could not find currentSong" : "Found music App",
      subtitle: s != null ? s.getIdentifier() : "Maybe start the music or the package is wrong",
      onTap: () => setState(() {})
    ) : Container();
  }

  Widget buildExportDB() {
    return SimpleSettingsTile(title: "Export Database", onTap: () async{ await exportDatabase();});
  }

  Widget buildImportDB() {
    return SimpleSettingsTile(title: "Import Database", onTap: () {});
  }
}
