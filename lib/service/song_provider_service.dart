import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:logger/logger.dart';
import 'package:scrobblium/song_data.dart';

class SongProviderService {
  static final logger = Logger();
  static const platform = MethodChannel('MusicListener');

  static Future<void> setMusicPackage(String package) async {
    await platform.invokeMethod("setMusicPackage", {"package":package});
  }

  static Future<List<SongData>> getSongData({withSkipped = false}) async {
    Stopwatch stopwatch = Stopwatch()..start();
    String jsonData = await platform.invokeMethod('list');
    List<SongData> songs = _parseSongDataList(jsonData);
    if(!withSkipped) {
        int cap = int.tryParse(Settings.getValue('skip-cap', defaultValue: '20') ?? "20") ?? 20;
        songs.removeWhere((element) => element.timeListened <= cap);
    }
    stopwatch.stop();
    logger.i(
        'Elapsed time: ${stopwatch.elapsedMilliseconds} milliseconds. Size of the json: ${jsonData.length / 1024}kb');
    return songs;
  }
  static List<SongData> removeSkips(List<SongData> songs) {
    List<SongData> newSongs = List.of(songs);
    int cap = int.tryParse(Settings.getValue('skip-cap', defaultValue: '20') ?? "20") ?? 20;
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

    for(var song in songs) {
      int cap = int.tryParse(Settings.getValue('skip-cap',defaultValue: '20')??"20")??20;
      if(song.timeListened < cap) {
        songsSkipped++;
      }else {
        songsListened++;
        songsListenedByProgress += song.progress~/1000;
        songsListenedByMaxProgress += song.maxProgress~/1000;
      }
      timeListened += song.timeListened;

    }
    return SongStatistic(songsListened,
        _formatDuration(timeListened),
        songsSkipped,
        _formatDuration(songsListenedByProgress),
        _formatDuration(songsListenedByMaxProgress),
        songsListenedByProgress/songsListenedByMaxProgress,
        timeListened/songsListenedByMaxProgress);
  }
  static String _formatDuration(int durationInSeconds) {
    Duration duration = Duration(seconds: durationInSeconds);
    int days = duration.inDays;
    int hours = duration.inHours.remainder(24);
    int minutes = duration.inMinutes.remainder(60);
    int seconds = duration.inSeconds.remainder(60);

    String formattedDuration = '';
    if (days > 0) {
      formattedDuration += '${days}d ';
    }
    if (hours > 0) {
      formattedDuration += '${hours}h ';
    }
    if (minutes > 0) {
      formattedDuration += '${minutes}m ';
    }
    if (seconds > 0 || formattedDuration.isEmpty) {
      formattedDuration += '${seconds}s';
    }
    return formattedDuration.trim();
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

  SongStatistic(this.songsListened, this.timeListened, this.songsSkipped, this.timeListenedByProgress, this.timeListenedByMaxProgress, this.ratioBetweenProgressAndMaxProgress, this.ratioBetweenTimeListenedAndMaxProgress);
}
