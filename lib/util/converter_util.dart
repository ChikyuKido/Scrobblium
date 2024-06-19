import 'package:scrobblium/dao/song_data.dart';
import 'package:scrobblium/messages/proto/song_datam.pb.dart';

class ConverterUtil {
  static SongData fromMessageToSongData(SongDataM value) {
    return SongData(id: value.id.toInt(),
        artist: value.artist,
        title: value.title,
        album: value.album,
        albumAuthor: value.albumAuthor,
        progress: value.progress.toInt(),
        maxProgress: value.maxProgress.toInt(),
        startTime: DateTime.fromMillisecondsSinceEpoch(value.startTime.toInt()),
        endTime: DateTime.fromMillisecondsSinceEpoch(value.endTime.toInt()),
        timeListened: value.timeListened);
  }
  static String formatDuration(int durationInSeconds) {
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
