import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:scrobblium/dao/song_data.dart';
import 'package:scrobblium/service/method_channel_service.dart';
import 'package:scrobblium/util/settings_helper.dart';
import 'package:scrobblium/widgets/app_list_popup.dart';

class TrackingSettingsPage extends StatefulWidget {
  const TrackingSettingsPage({super.key});

  @override
  State<TrackingSettingsPage> createState() => _TrackingSettingsPageState();
}

class _TrackingSettingsPageState extends State<TrackingSettingsPage> {
  late bool notificationPermissionGranted;
  late String status;
  late SongData? currentSong;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: initVariables(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        return SettingsScreen(title: "Tracking",children: [
          _buildNotificationAccess(),
          _buildMusicPackage(context),
          _buildForegroundProcess(),
          _buildValidationInfo()
        ]);
      },
    );
  }

  _buildMusicPackage(BuildContext context) {
    return Visibility(
      visible: notificationPermissionGranted,
      child: SimpleSettingsTile(
        title: "Music app package",
        subtitle: getValueString("music-app-package", "No package selected"),
        onTap: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return const AlertDialog(
                title: Text('Select an App'),
                content: AppListPopup(),
              );
            },
          ).then((value) {
            setState(() {});
          });
        },
      ),
    );
  }

  _buildNotificationAccess() {
    return SimpleSettingsTile(
      padding: const EdgeInsets.only(top: 16.0),
      title:
      "Notification access is ${notificationPermissionGranted ? "granted" : "denied"}",
      subtitle: "Tap to open Notification settings",
      onTap: () {
        MethodChannelService.launchNotificationAccess();
        setState(() {});
      },
    );
  }

  _buildForegroundProcess() {
    return Visibility(
        visible: notificationPermissionGranted,
        child: SimpleSettingsTile(
          title: "Tracker status: $status",
          subtitle: "Tap to start the background process",
          onTap: () async {
            await MethodChannelService.startForegroundProcess();
            setState(() {});
          },
        ));
  }

  _buildValidationInfo() {
    return Visibility(
        visible: status == "TRACKING",
        child: SimpleSettingsTile(
          title: currentSong == null
              ? "Could not find currentSong"
              : "Found music App",
          subtitle: currentSong != null
              ? currentSong?.getIdentifier()
              : "Maybe start the music or the package is wrong",
          onTap: () => setState(() {}),
        ));
  }

  Future<void> initVariables() async {
    notificationPermissionGranted = await MethodChannelService.isNotificationPermissionGranted();
    status = await MethodChannelService.getMusicListenerServiceStatus();
    currentSong = await MethodChannelService.getCurrentSong();
  }
}
