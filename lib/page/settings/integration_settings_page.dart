import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:scrobblium/service/method_channel_service.dart';
import 'package:scrobblium/util/widget_util.dart';
import 'package:scrobblium/widgets/login_widget.dart';


class IntegrationSettingsPage extends StatefulWidget {
  const IntegrationSettingsPage({super.key});

  @override
  State<IntegrationSettingsPage> createState() => _IntegrationSettingsPageState();
}

class _IntegrationSettingsPageState extends State<IntegrationSettingsPage> {

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
    var fieldData = await MethodChannelService.getRequiredFieldsFor(s);
    var isLoggedIn = await MethodChannelService.isLoggedInFor(s);
    var cachedSongs = await MethodChannelService.cachedSongsFor(s);
    if(fieldData.hasError()) {
      return SimpleTextSettingsTile(title: "Could not create $s",subtitle: fieldData.error);
    }
    var fields = String.fromCharCodes(fieldData.data??List.empty()).split(";");
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
                title: isLoggedIn ? "Logout from $s" : "Login to $s",
                subtitle: isLoggedIn ? "Cached Songs: $cachedSongs" : "",
                onTap: () async {
                  if(!isLoggedIn) {
                    showDialog(
                        context: context,
                        builder: (context) =>
                            LoginWidget(fields, s, onLogin: (p0) async {
                              var result = await MethodChannelService.loginFor(s,
                                  p0);
                              if (result) {
                                WidgetUtil.showToast("Successfully logged in to $s");
                              } else {
                                WidgetUtil.showToast("Could not login to $s");
                              }
                              setState(() {});
                            }));
                  }else {
                    await MethodChannelService.logoutFor(s);
                    WidgetUtil.showToast("Successfully logged out from $s");
                    setState(() {});
                  }
                },
              ),
            ],
          )
        ]
    );
  }
}
