import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:scrobblium/service/method_channel_service.dart';

class DebugSettingsPage extends StatelessWidget {
  const DebugSettingsPage({super.key});


  @override
  Widget build(BuildContext context) {
    return SettingsScreen(children: [
      _buildShowStatusNotification(),
    ]);
  }

  Widget _buildShowStatusNotification() {
    return SwitchSettingsTile(
      topPadding: 0.0,
      title: 'Show status notification',
      settingKey: 'show-status-notification',
      defaultValue: false,
      onChange: (p0) {
        Future.delayed(const Duration(seconds: 1)).then((value) => MethodChannelService.startForegroundProcess());
      },
    );
  }

}
