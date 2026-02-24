import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:scrobblium/service/method_channel_service.dart';
import 'package:scrobblium/util/widget_util.dart';

class ExportsettingsPage extends StatelessWidget {
  const ExportsettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsScreen(
      title: "Export Settings",
      children: [
        SettingsGroup(title: "Export", children: [
          malojaExport(),
          listenBrainzExport(),
        ])
      ],
    );
  }
  Widget malojaExport() {
    return SimpleSettingsTile(
    title: "Export Maloja",
    onTap: () {
      MethodChannelService.callFunction(EXPORT_MALOJA).then((value) {
        WidgetUtil.showToast(value.getDataAsString());
      });
    });
  }
  Widget listenBrainzExport() {
    return SimpleSettingsTile(
        title: "Export ListenBrainz",
        onTap: () {
          MethodChannelService.callFunction(EXPORT_LISTEN_BRAINZ).then((value) {
            WidgetUtil.showToast(value.getDataAsString());
          });
        });
  }
}
