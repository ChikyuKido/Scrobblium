import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:scrobblium/service/method_channel_service.dart';

class ExportsettingsPage extends StatelessWidget {
  const ExportsettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsScreen(
      title: "Export Settings",
      children: [
        SettingsGroup(title: "Export", children: [
          malojaExport(),
        ])
      ],
    );
  }
  Widget malojaExport() {
    return SimpleSettingsTile(
    title: "Export Maloja",
    onTap: () {
      MethodChannelService.callFunction(EXPORT_MALOJA);
    });
  }
}
