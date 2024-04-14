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
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }
          return SettingsScreen(children: [
            _buildExportDB(),
            _buildImportDB(),
            _buildBackupOption()
          ]);
        });
  }

  initVariables() async {
    path = await MethodChannelService.getBackupDatabasePath();
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
      childrenIfEnabled: [_buildMakeBackup(),_buildBackupPicker()],
    );
  }

  _buildBackupPicker() {
    return SimpleSettingsTile(
      title: "Backup path",
      subtitle: "Path: ${path.isEmpty ? "Non" : path}",
      onTap: () => MethodChannelService.backupDatabasePathPicker(),
    );
  }

  _buildMakeBackup() {
    return SimpleSettingsTile(
        title: "Create backup now",
        onTap: () => MethodChannelService.backupDatabaseNow(),
    );
  }
}
