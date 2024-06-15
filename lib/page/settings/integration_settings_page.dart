import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:scrobblium/service/method_channel_service.dart';
import 'package:scrobblium/widgets/login_widget.dart';

class IntegrationSettingsPage extends StatelessWidget {
  const IntegrationSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsScreen(
        title: "Integration",
        children: [
      _wrapFuture(_addIntegration("Maloja",context)),
    ]);
  }

  Widget _wrapFuture(Future<Widget> future) {
    return FutureBuilder(future: future, builder: (context, snapshot) {
      if(snapshot.connectionState == ConnectionState.waiting) {
        return const CircularProgressIndicator();
      }
      return snapshot.data??const Text("Could not load Widget");
    });
  }

  Future<Widget> _addIntegration(String s,BuildContext context) async{
    var fields = await MethodChannelService.getRequiredFieldsFor(s);
    return SettingsGroup(
        title: s,
        children: [
          SwitchSettingsTile(
            topPadding: 0.0,
            title: 'Activate $s',
            settingKey: 'activate-$s',
            defaultValue: false,
            childrenPadding: EdgeInsets.zero,
            childrenIfEnabled: [
              SimpleSettingsTile(
                title: "Login to $s",
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (context) => LoginWidget(fields, s, onLogin: (p0) {
                        MethodChannelService.loginFor(s,p0);
                      }));
                },
              )
            ],
          )
        ]
    );
  }
}
