import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:scrobblium/page/main_page.dart';
import 'package:scrobblium/page/settings/appearance_settings_page.dart';
import 'package:scrobblium/page/settings/database_settings_page.dart';
import 'package:scrobblium/page/settings/integration_settings_page.dart';
import 'package:scrobblium/page/settings/stats_settings_page.dart';
import 'package:scrobblium/page/settings/tracking_settings_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      SettingsProvider().updateSelectedPage([], null);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: ListView(padding: const EdgeInsets.all(8.0), children:
        [
        SimpleSettingsTile(title: "Tracking", child: TrackingSettingsPage()),
        SimpleSettingsTile(title: "Stats", child: const StatsSettingsPage()),
        SimpleSettingsTile(
            title: "Appearance", child: const AppearanceSettingsPage()),
        SimpleSettingsTile(title: "Database", child: DatabaseSettingsPage()),
        SimpleSettingsTile(title: "Integrations", child: const IntegrationSettingsPage()),
    ]));
  }
}
