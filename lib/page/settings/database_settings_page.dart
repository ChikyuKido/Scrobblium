import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:scrobblium/service/method_channel_service.dart';

class DatabaseSettingsPage extends StatelessWidget {
  DatabaseSettingsPage({super.key});

  late String path;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: initVariables(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const CircularProgressIndicator();
          return SettingsScreen(children: [
            _buildExportDB(),
            _buildImportDB(),
            _buildBackupOption()
          ]);
        });
  }

  Widget _buildExportDB() {
    return SimpleSettingsTile(
        title: "Export Database",
        onTap: () async {
          await MethodChannelService.exportDatabase();
        });
  }

  Widget _buildImportDB() {
    return SimpleSettingsTile(
        title: "Import Database",
        onTap: () async {
          MethodChannelService.importDatabase();
        });
  }

  Widget _buildBackupOption() {
    return SwitchSettingsTile(
      topPadding: 0.0,
      title: 'Backup database',
      settingKey: 'backup-database',
      defaultValue: false,
      childrenPadding: EdgeInsets.zero,
      childrenIfEnabled: [_buildBackupPicker()],
    );
  }

  _buildBackupPicker() {
    return SimpleSettingsTile(
      title: "Backup path (Not working yet)",
      subtitle: "Path: ${path.isEmpty ? "Non" : path}",
      onTap: () => MethodChannelService.backupDatabasePathPicker(),
    );
  }

  initVariables() async {
    path = await MethodChannelService.getBackupDatabasePath();
  }
}
