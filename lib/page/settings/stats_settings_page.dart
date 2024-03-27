import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';

class StatsSettingsPage extends StatelessWidget {
  const StatsSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsScreen(children: [
      _buildSkipCap(),
      _buildShowSkippedInSongs(),
    ]);
  }

  Widget _buildSkipCap() {
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

  Widget _buildShowSkippedInSongs() {
    return SwitchSettingsTile(
      topPadding: 0.0,
      title: 'Show skipped in songs page',
      subtitle: 'Whether skipped songs should be shown in the songs page',
      settingKey: 'show-skipped-in-songs-page',
      defaultValue: false,
    );
  }
}
