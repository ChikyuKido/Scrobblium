import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:scrobblium/service/method_channel_service.dart';
import 'package:scrobblium/widgets/login_popup.dart';

class IntegrationSettingsPage extends StatelessWidget {
  const IntegrationSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsScreen(children: [
      _buildLastFMIntegrationActive(),
      _buildLastFMLoginButton(context),
    ]);
  }

  Widget _buildLastFMIntegrationActive() {
    return SwitchSettingsTile(
      topPadding: 0.0,
      title: 'Use LastFM integration',
      settingKey: 'last-fm-active',
      defaultValue: false,
    );
  }

  Widget _buildLastFMLoginButton(BuildContext context) {
    return SimpleSettingsTile(
        title: "Login LastFM",
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return LoginPopup();
          },
        ).then((value) async {
          if (value != null) {
            String username = value['username'];
            String password = value['password'];
            var ret = await MethodChannelService.signInLastFMUser(username, password);
            print("RESULT:${ret}");
          }
        });
      },
    );
  }
}
