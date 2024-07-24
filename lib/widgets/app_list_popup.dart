import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:scrobblium/service/method_channel_service.dart';
import 'package:scrobblium/widgets/app_list_widget.dart';

class AppListPopup extends StatefulWidget {
  const AppListPopup({super.key});

  @override
  State<AppListPopup> createState() => _AppListPopupState();
}

class _AppListPopupState extends State<AppListPopup> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: InstalledApps.getInstalledApps(true,true,""),
        builder: (context, snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if(snapshot.data == null) {
            return const Text("Could not find apps");
          }
          return AppListWidget(
              appList: snapshot.data??List.empty(),
              onAppSelected: (p0) {
                Settings.setValue("music-app-package", p0.packageName);
                MethodChannelService.setMusicPackage(p0.packageName);
                Navigator.pop(context);
              },
          );
        },
    );
  }
}
