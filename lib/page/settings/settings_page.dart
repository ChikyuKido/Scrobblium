import 'package:flutter/material.dart';
import 'package:scrobblium/page/settings/export_settings_page.dart';
import 'package:scrobblium/page/settings/appearance_settings_page.dart';
import 'package:scrobblium/page/settings/database_settings_page.dart';
import 'package:scrobblium/page/settings/debug_settings_page.dart';
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        centerTitle: true,
      ),
      body:  SafeArea(
          child: ListView(padding: const EdgeInsets.all(8.0), children:
          [
            addSettingsPage("Tracking", Icons.music_note, const TrackingSettingsPage()),
            addSettingsPage("Stats", Icons.insert_chart, const StatsSettingsPage()),
            addSettingsPage("Appearance", Icons.palette, const AppearanceSettingsPage()),
            addSettingsPage("Database", Icons.storage, DatabaseSettingsPage()),
            addSettingsPage("Integrations", Icons.network_check, const IntegrationSettingsPage()),
            addSettingsPage("Exports", Icons.import_export, const ExportsettingsPage()),
            addSettingsPage("Debug", Icons.bug_report, const DebugSettingsPage())
          ])),
    );
  }

  Widget addSettingsPage(String title, IconData icon, Widget page) {
    return ListTile(
      title: Text(title,style: Theme.of(context).textTheme.bodyLarge),
      leading: Icon(icon),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: () => navigate(page),
    );
  }
  void navigate(Widget page) {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 200),
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, animation, __, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          );
        },
      ),
    );
  }
}
