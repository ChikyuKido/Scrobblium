import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:scrobblium/service/app_theme_provider.dart';
import 'package:scrobblium/service/song_provider_service.dart';
import 'package:scrobblium/widgets/simple_text_settings_tile.dart';

import '../song_data.dart';


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
          FutureBuilder(future: _buildValidationInfo(), builder: (context, snapshot) {
            if(snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }
            return snapshot.data??Container();
          }),
        ]),
        buildSkipCap(),
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

  Future<Widget> _buildValidationInfo() async{
    SongData? s = await SongProviderService.getCurrentSong();
    return SimpleSettingsTile(
      title: s == null ? "Could not find currentSong" : "Found music App",
      subtitle: s != null ? s.getIdentifier() : "Maybe start the music or the package is wrong",
      onTap: () => setState(() {})
    );
  }

  Widget buildExportDB() {
    return SimpleSettingsTile(title: "Export Database", onTap: () {});
  }

  Widget buildImportDB() {
    return SimpleSettingsTile(title: "Import Database", onTap: () {});
  }
}
