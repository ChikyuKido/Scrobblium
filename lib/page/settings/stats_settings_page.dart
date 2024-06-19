import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';

class StatsSettingsPage extends StatelessWidget {
  const StatsSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsScreen(title: "Stats",children: [
      _buildSkipCap(),
      _buildAnywayCap(),
      _buildShowSkippedInSongs(),
      _buildSearchSaveOptions(),
    ]);
  }

  Widget _buildSkipCap() {
    return TextInputSettingsTile(
      title: 'Skip cap',
      unit: '%',
      settingKey: 'skip-cap',
      helperText: 'The percentage when a track is counted as skip.',
      initialValue: '50',
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
  Widget _buildAnywayCap() {
    return TextInputSettingsTile(
      title: 'Anyway cap',
      unit: 's',
      settingKey: 'anyway-cap',
      helperText: 'The time when a track is not counted as a skip even if the skip cap is reached.',
      initialValue: '240',
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

  _buildSearchSaveOptions() {
    return SwitchSettingsTile(
      topPadding: 0.0,
        title: "Save search options in songs page",
        subtitle: "Whether the entered search options should be saved",
        settingKey: "search-save-options",
        defaultValue: true
    );
  }
}
