
import 'package:scrobblium/dao/song_data.dart';
import 'package:scrobblium/util/settings_helper.dart';
import 'package:scrobblium/util/util.dart';

class StatsUtil {
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
