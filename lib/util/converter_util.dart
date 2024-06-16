import 'package:scrobblium/dao/song_data.dart';
import 'package:scrobblium/messages/proto/song_datam.pb.dart';

SongData fromMessageToSongData(SongDataM value) {
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