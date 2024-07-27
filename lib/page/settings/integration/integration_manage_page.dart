import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:scrobblium/service/method_channel_service.dart';
import 'package:scrobblium/util/widget_util.dart';

class IntegrationManagePage extends StatefulWidget {
  const IntegrationManagePage({super.key});

  @override
  State<IntegrationManagePage> createState() => _IntegrationManagePageState();
}

class _IntegrationManagePageState extends State<IntegrationManagePage> {
  @override
  Widget build(BuildContext context) {
    return SettingsScreen(
        title: "Manage Integrations",
        children: [
          SettingsGroup(
              title: "Settings",
              children: [
                addIntegration(),
              ]
          ),
          FutureBuilder(future: getIntegrations(), builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }
            if (snapshot.hasError || snapshot.data == null) {
              return Center(child: Text("No integrations available", style: Theme
                  .of(context)
                  .textTheme
                  .bodyLarge));
            }
            return SettingsGroup(
                title: "Integrations",
                children: snapshot.data??[]
            );
          })
        ]
    );
  }

  Widget addIntegration() {
    return SimpleSettingsTile(
      title: "Add Integration",
      onTap: () async{
        WidgetUtil.showToast("Not implemented yet. :)");
       // await MethodChannelService.callFunction(ADD_INTEGRATION);
       // setState(() {});
      },
    );
  }
  Future<List<Widget>> getIntegrations() async {
    var data = await MethodChannelService.callFunction(GET_INTEGRATIONS);
    List<String> integrations = data.getDataAsString().split(";");
    List<Widget> integrationWidgets = [];
    for (var value in integrations) {
      integrationWidgets.add(await getIntegration(value));
    }
    return integrationWidgets;
  }
  Future<Widget> getIntegration(String name) async{
    var data = await MethodChannelService.callFunction(GET_INTEGRATION_INFORMATIONS_FOR(name));
    List<String> infos = data.getDataAsString().split(";");
    String author = infos[1];
    String version = infos[2];
    String desc = infos[3];
    return SimpleSettingsTile(
      title: "$name:v$version - $author",
      subtitle: desc,
      onTap: () {
        //TODO: popup to remove the integration
      },
    );
  }
}
