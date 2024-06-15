import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:scrobblium/service/method_channel_service.dart';
import 'package:scrobblium/util/util.dart';

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
          return SettingsScreen(title: "Database",children: [
            _buildExportDB(context),
            _buildImportDB(),
            _buildBackupOption()
          ]);
        });
  }

  initVariables() async {
    path = await MethodChannelService.getBackupDatabasePath();
  }

  Widget _buildExportDB(BuildContext context) {
    return SimpleSettingsTile(
        title: "Export Database",
        onTap: () async {
          await MethodChannelService.exportDatabase();
          showToast("Successfully exported Database");
        });
  }

  Widget _buildImportDB() {
    return SimpleSettingsTile(
        title: "Import Database",
        onTap: () async {
          await MethodChannelService.importDatabase();
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
        onTap: () async{
            var result = await MethodChannelService.backupDatabaseNow();
            result.showErrorAsToastIfAvailable();
            if(result.hasNotError()) {
              showToast("Successfully created backup now");
            }
        },
    );
  }
}
