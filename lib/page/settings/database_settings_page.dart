import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:scrobblium/service/method_channel_service.dart';
import 'package:scrobblium/util/widget_util.dart';

class DatabaseSettingsPage extends StatefulWidget {
  const DatabaseSettingsPage({super.key});

  @override
  State<DatabaseSettingsPage> createState() => _DatabaseSettingsPageState();
}

class _DatabaseSettingsPageState extends State<DatabaseSettingsPage> {
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
            SettingsGroup(title: "Import/Export", children: [
              _buildExportDB(context),
              _buildImportDB(),
            ]),
            SettingsGroup(title: "Backup", children: [
              _buildBackupOption(),
            ])
          ]);
        });
  }

  initVariables() async {
    path = await MethodChannelService.getBackupDatabasePath();
  }

  Widget _buildExportDB(BuildContext context) {
    return SimpleSettingsTile(
        title: "Export Database",
        onTap: ()  {
          MethodChannelService.callFunction(EXPORT_DATABASE).then((value) {
            WidgetUtil.showToast(value.getDataAsString());
          });
        });
  }

  Widget _buildImportDB() {
    return SimpleSettingsTile(
        title: "Import Database",
        onTap: () {
          MethodChannelService.callFunction(IMPORT_DATABASE).then((value) {
            WidgetUtil.showToast(value.getDataAsString());
          });
        });
  }

  Widget _buildBackupOption() {
    return SwitchSettingsTile(
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
      onTap: () {
        MethodChannelService.callFunction(BACKUP_DATABASE_PICKER).then((value) {
          WidgetUtil.showToast(value.getDataAsString());
          setState(() {});
        });
      },
    );
  }

  _buildMakeBackup() {
    return SimpleSettingsTile(
        title: "Create backup now",
        onTap: () async {
            var result = await MethodChannelService.callFunction(BACKUP_DATABASE_NOW);
            result.showErrorAsToastIfAvailable();
            if(result.hasNotError()) {
              WidgetUtil.showToast("Successfully created backup now");
            }
        },
    );
  }
}
