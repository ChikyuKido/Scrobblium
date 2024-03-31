import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:scrobblium/service/method_channel_service.dart';
import 'package:scrobblium/song_data.dart';
import 'package:scrobblium/util/widget_util.dart';

class TrackingSettingsPage extends StatelessWidget {
  TrackingSettingsPage({super.key});

  late bool notificationPermissionGranted;
  late String status;
  late SongData? currentSong;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: initVariables(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return const CircularProgressIndicator();
        return SettingsScreen(children: [
          _buildNotificationAccess(),
          _buildMusicPackage(),
          _buildForegroundProcess(),
          _buildValidationInfo()
        ]);
      },
    );
  }

  _buildMusicPackage() {
    return showOnlyWhen(
        notificationPermissionGranted,
        TextInputSettingsTile(
          topPadding: 0.0,
          title: 'Music app package',
          settingKey: 'music-app-package',
          initialValue: '',
          onChange: (p0) {
            MethodChannelService.setMusicPackage(p0);
          },
        ));
  }

  _buildNotificationAccess() {
    return SimpleSettingsTile(
      padding: const EdgeInsets.only(top: 16.0),
      title:
          "Notification access is ${notificationPermissionGranted ? "granted" : "denied"}",
      subtitle: "Tap to open Notification settings",
      onTap: () => MethodChannelService.launchNotificationAccess(),
    );
  }

  _buildForegroundProcess() {
    return showOnlyWhen(
        notificationPermissionGranted,
        SimpleSettingsTile(
          title: "Tracker status: $status",
          subtitle: "Tap to start the background process",
          onTap: () async {
            await MethodChannelService.startForegroundProcess();
          },
        ));
  }

  _buildValidationInfo() {
    return showOnlyWhen(
        status == "TRACKING",
        SimpleSettingsTile(
          title: currentSong == null
              ? "Could not find currentSong"
              : "Found music App",
          subtitle: currentSong != null
              ? currentSong?.getIdentifier()
              : "Maybe start the music or the package is wrong",
        ));
  }

  initVariables() async {
    notificationPermissionGranted =
        await MethodChannelService.isNotificationPermissionGranted();
    status = await MethodChannelService.getMusicListenerServiceStatus();
    currentSong = await MethodChannelService.getCurrentSong();
  }
}
