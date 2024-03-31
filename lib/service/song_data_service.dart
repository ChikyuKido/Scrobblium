import 'package:scrobblium/service/method_channel_service.dart';
import 'package:scrobblium/song_data.dart';
import 'package:scrobblium/util/settings_helper.dart';

/// A singleton class for managing song data.
class SongDataService {
  List<SongData> _songs = [];

  static final SongDataService _instance = SongDataService._internal();

  factory SongDataService() {
    return _instance;
  }

  SongDataService._internal();

  Future<void> fetchData() async {
    _songs = await MethodChannelService.getSongData();
  }
  
  List<SongData> getSongs({withSkipped = true, DateTime? afterDate}) {
    List<SongData> songs = List.of(_songs);
    if (!withSkipped) {
      int cap = getValueInt("skip-cap", 20);
      songs.removeWhere((element) => element.timeListened <= cap);
    }
    if (afterDate != null) {
      songs.removeWhere((element) => element.endTime.isBefore(afterDate));
    }
    return songs;
  }
}