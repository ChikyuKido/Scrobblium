import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:scrobblium/dao/method_channel_data.dart';
import 'package:scrobblium/dao/song_data.dart';
import 'package:scrobblium/messages/proto/song_datam.pb.dart';
import 'package:scrobblium/util/settings_helper.dart';
import 'package:scrobblium/util/util.dart';

class MethodChannelService {
  static const platform = MethodChannel('MusicListener');


  static Future<MethodChannelData> _callFunction(String function,[dynamic arguments]) async {
    final Map<String, dynamic> result = Map<String, dynamic>.from(await platform.invokeMethod(function,arguments));
    return MethodChannelData.fromMap(result);
  }

  static Future<void> makeWALCheckpoint() async {
    await platform.invokeMethod("makeWALCheckpoint");
  }
  static Future<void> setMusicPackage(String package) async {
    await platform.invokeMethod("setMusicPackage", {"package": package});
  }

  static Future<List<SongData>> getSongData() async {
    var data = await _callFunction("list");
    data.showErrorAsToastIfAvailable();
    if(data.hasError()) return List.empty();
    SongDataListM songDataListM = SongDataListM.fromBuffer(data.data??List.empty());

    List<SongData> songs = [];
    for(var value in songDataListM.songs) {
      songs.add(SongData(id: value.id.toInt(),
          artist: value.artist,
          title: value.title,
          album: value.album,
          albumAuthor: value.albumAuthor,
          progress: value.progress.toInt(),
          maxProgress: value.maxProgress.toInt(),
          startTime: DateTime.fromMillisecondsSinceEpoch(value.startTime.toInt()),
          endTime: DateTime.fromMillisecondsSinceEpoch(value.endTime.toInt()),
          timeListened: value.timeListened));
    }

    return songs;
  }

  static Future<SongData?> getCurrentSong() async {
    String currentSongJson = await platform.invokeMethod('currentSong');
    SongData? songData;
    if (currentSongJson != "[]") {
      songData = SongData.fromJson(jsonDecode(currentSongJson).cast<String, dynamic>());
    }
    return songData;
  }



  static SongStatistic getSongStatistics(List<SongData> songs) {
    int songsListened = 0;
    int songsListenedByProgress = 0;
    int songsListenedByMaxProgress = 0;
    int timeListened = 0;
    int songsSkipped = 0;

    for (var song in songs) {
      int cap = getValueInt("skip-cap", 20);
      if (song.timeListened < cap) {
        songsSkipped++;
      } else {
        songsListened++;
        songsListenedByProgress += song.progress ~/ 1000;
        songsListenedByMaxProgress += song.maxProgress ~/ 1000;
      }
      timeListened += song.timeListened;
    }
    return SongStatistic(
        songsListened,
        formatDuration(timeListened),
        songsSkipped,
        formatDuration(songsListenedByProgress),
        formatDuration(songsListenedByMaxProgress),
        songsListenedByProgress / songsListenedByMaxProgress,
        timeListened / songsListenedByMaxProgress);
  }

  static Future<void> launchNotificationAccess() async {
    await platform.invokeMethod("launchNotificationAccess");
  }

  static Future<bool> isNotificationPermissionGranted() async {
    return (await platform.invokeMethod("isNotificationGranted") == "true");
  }

  static Future<String> getMusicListenerServiceStatus() async {
    return (await platform.invokeMethod("getMusicListenerServiceStatus"));
  }

  static startForegroundProcess() async {
    await platform.invokeMethod("startForegroundProcess");
  }
  static exportDatabase() async {
    await platform.invokeMethod("exportDatabase");
  }

  static importDatabase() async {
    await platform.invokeMethod("importDatabase");
  }
  static deleteEntry(int id) async {
    await platform.invokeMethod("deleteEntry",{"id":"$id"});
  }

  static backupDatabasePathPicker() async {
    await platform.invokeMethod("backupDatabasePicker");
  }
  static Future<String> getBackupDatabasePath() async {
    return await platform.invokeMethod("getBackupDatabasePath");
  }

  static Future<MethodChannelData> backupDatabaseNow() async {
    return _callFunction("backupDatabaseNow");
  }

  static getRequiredFieldsFor(String s) async{

    return (await platform.invokeMethod("getRequiredFieldsFor$s")).split(";");
  }

  static void loginFor(String s, Map<String, String> p0) async{
    await platform.invokeMethod("loginFor$s",{"fields":jsonEncode(p0)});
  }

}

class SongStatistic {
  final int songsListened;
  final String timeListened;
  final int songsSkipped;
  final String timeListenedByProgress;
  final String timeListenedByMaxProgress;
  final double ratioBetweenProgressAndMaxProgress;
  final double ratioBetweenTimeListenedAndMaxProgress;

  SongStatistic(
      this.songsListened,
      this.timeListened,
      this.songsSkipped,
      this.timeListenedByProgress,
      this.timeListenedByMaxProgress,
      this.ratioBetweenProgressAndMaxProgress,
      this.ratioBetweenTimeListenedAndMaxProgress);
}
