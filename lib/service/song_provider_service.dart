import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:scrobblium/song_data.dart';
import 'package:scrobblium/util/util.dart';

class SongProviderService {
  static const platform = MethodChannel('MusicListener');

  static Future<void> makeWALCheckpoint() async {
    await platform.invokeMethod("makeWALCheckpoint");
  }

  static Future<void> setMusicPackage(String package) async {
    await platform.invokeMethod("setMusicPackage", {"package": package});
  }

  static Future<String> getJsonData() async {
    return await platform.invokeMethod('list');
  }

  static Future<List<SongData>> getSongData(
      {withSkipped = true, DateTime? afterDate}) async {
    Stopwatch stopwatch = Stopwatch()..start();
    String jsonData = await platform.invokeMethod('list');
    List<SongData> songs = _parseSongDataList(jsonData);
    if (!withSkipped) {
      int cap = int.tryParse(
              Settings.getValue('skip-cap', defaultValue: '20') ?? "20") ??
          20;
      songs.removeWhere((element) => element.timeListened <= cap);
    }
    if (afterDate != null) {
      songs.removeWhere((element) => element.endTime.isBefore(afterDate));
    }
    stopwatch.stop();
    return songs;
  }

  static List<SongData> removeSkips(List<SongData> songs) {
    List<SongData> newSongs = List.of(songs);
    int cap = int.tryParse(
            Settings.getValue('skip-cap', defaultValue: '20') ?? "20") ??
        20;
    newSongs.removeWhere((element) => element.timeListened <= cap);
    return newSongs;
  }

  static Future<SongData?> getCurrentSong() async {
    String currentSongJson = await platform.invokeMethod('currentSong');
    SongData? songData;
    if (currentSongJson != "[]") {
      songData = SongData.fromJson(
          jsonDecode(currentSongJson).cast<String, dynamic>());
    }
    return songData;
  }

  static List<SongData> _parseSongDataList(String responseBody) {
    final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
    return parsed.map<SongData>((json) => SongData.fromJson(json)).toList();
  }

  static SongStatistic getSongStatistics(List<SongData> songs) {
    int songsListened = 0;
    int songsListenedByProgress = 0;
    int songsListenedByMaxProgress = 0;
    int timeListened = 0;
    int songsSkipped = 0;

    for (var song in songs) {
      int cap = int.tryParse(
              Settings.getValue('skip-cap', defaultValue: '20') ?? "20") ??
          20;
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
