import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:scrobblium/service/song_provider_service.dart';
import 'package:scrobblium/widgets/song_list_tile.dart';

import '../song_data.dart';

class SongsPage extends StatefulWidget {
  const SongsPage({super.key});

  @override
  State<SongsPage> createState() => _SongsPageState();
}

class _SongsPageState extends State<SongsPage> {
  List<SongTileData> _songs = [];

  @override
  void initState() {
    super.initState();
    _refreshSongs();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
        onRefresh: () async => _refreshSongs(),
        child: _songs.isEmpty
            ? Container()
            : ListView.builder(
              itemCount: _songs.length,
                itemBuilder: (BuildContext context, int index) =>
                    SongListTile(songData: _songs[index])));
  }

  List<SongTileData> _getSongTileData(List<SongData> songDatas) {
    List<SongTileData> songs = [];
    for (var item in songDatas) {
      var songTileData = item.toSongTileData();
      var index = songs.indexWhere((element) =>
          element.title == songTileData.title &&
          element.artist == songTileData.artist &&
          element.album == songTileData.album);

      if (index != -1) {
        songs[index].listenCount++;
        songs[index].allTimeListened += item.timeListened;
      } else {
        songs.add(songTileData);
      }
    }
    songs.sort((a, b) => b.listenCount.compareTo(a.listenCount));
    return songs;
  }

  _refreshSongs() async {
    _songs = _getSongTileData(await SongProviderService.getSongData(withSkipped: false));
    setState(() {});
  }
}
