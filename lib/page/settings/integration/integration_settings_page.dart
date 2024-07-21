import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:scrobblium/page/settings/integration/integration_conditional_upload_page.dart';
import 'package:scrobblium/page/settings/integration/integration_manage_page.dart';
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
    return FutureBuilder(future: MethodChannelService.callFunction(GET_INTEGRATIONS),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }
          if (snapshot.hasError || snapshot.data == null) {
            return Center(child: Text("No integrations available", style: Theme
                .of(context)
                .textTheme
                .bodyLarge));
          }

          List<Widget> widgets = snapshot.data!.getDataAsString().split(";")
              .map((e) => _wrapFuture(_addIntegration(e, context))).toList();
          widgets.insert(0,
              const SettingsGroup(
                  title: "Settings",
                  children: [
                    SimpleSettingsTile(
                        title: "Conditional upload",
                        child: IntegrationConditionalUploadPage()
                    ),
                    SimpleSettingsTile(
                      title: "Manage Integrations",
                      child: IntegrationManagePage(),
                    )
                  ],
              )
          );
          return SettingsScreen(
            title: "Integration",
            children: widgets,
          );
        });
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
    var fieldData = (await MethodChannelService.callFunction(GET_REQUIRED_FIELDS_FOR(s)));
    var isLoggedIn = (await MethodChannelService.callFunction(IS_LOGGED_IN_FOR(s))).getDataAsBool();
    var cachedSongs = (await MethodChannelService.callFunction(GET_CACHED_SONGS_FOR(s))).getDataAsInt();
    if(fieldData.hasError()) {
      return SimpleTextSettingsTile(title: "Could not create $s",subtitle: fieldData.error);
    }
    var fields = String.fromCharCodes(fieldData.data??List.empty()).split(";");
    return SettingsGroup(
        title: s,
        children: [
          SwitchSettingsTile(
            title: 'Activate $s',
            settingKey: 'activate-$s',
            defaultValue: false,
            childrenPadding: EdgeInsets.zero,
            childrenIfEnabled: [
              SimpleTrailingSettingsTile(
                title: isLoggedIn ? "Logout from $s" : "Login to $s",
                subtitle: isLoggedIn ? "Cached Songs: $cachedSongs" : "",
                trailing: IconButton(icon: const Icon(Icons.upload),onPressed: () async {
                  var data = await MethodChannelService.callFunction(UPLOAD_CACHED_SONGS_FOR(s));
                  WidgetUtil.showToast(data.getDataAsString());
                  setState(() {});
                }),
                onTap: () async {
                  if(!isLoggedIn) {
                    showDialog(
                        context: context,
                        builder: (context) =>
                            LoginWidget(fields, s, onLogin: (p0) async {
                              var result = await MethodChannelService.loginFor(s,
                                  p0);
                              if (result.getDataAsBool()) {
                                WidgetUtil.showToast("Successfully logged in to $s");
                              } else {
                                WidgetUtil.showToast("Could not login to $s");
                              }
                              setState(() {});
                            }));
                  }else {
                    await MethodChannelService.callFunction(LOGOUT_FOR(s));
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
