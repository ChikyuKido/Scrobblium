import 'package:flutter/material.dart';
import 'package:scrobblium/page/song_tile_info_page.dart';
import 'package:scrobblium/service/song_provider_service.dart';
import 'package:scrobblium/song_data.dart';
import 'package:scrobblium/util/settings_helper.dart';
import 'package:scrobblium/widgets/song_list_tile.dart';

class SongsPage extends StatefulWidget {
  const SongsPage({super.key});

  @override
  State<SongsPage> createState() => _SongsPageState();
}

class _SongsPageState extends State<SongsPage> {
  List<SongTileData> _tileSongs = [];
  List<SongData> _songs = [];

  @override
  void initState() {
    super.initState();
    _refreshSongs();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
        onRefresh: () async => _refreshSongs(),
        child: _tileSongs.isEmpty
            ? Container()
            : ListView.builder(
                itemCount: _tileSongs.length,
                itemBuilder: (BuildContext context, int index) => SongListTile(
                      songData: _tileSongs[index],
                      onTap: () {
                        List<SongData> songs = _songs
                            .where((element) =>
                                _tileSongs[index].getIdentifier() ==
                                element.getIdentifier())
                            .toList();
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    SongTileInfoPage(songs: songs))).then((value) => _refreshSongs());
                      },
                    )));
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
    _songs = await SongProviderService.getSongData(withSkipped: getValueBool("show-skipped-in-songs-page",false));
    _tileSongs = _getSongTileData(_songs);
    setState(() {});
  }


}
