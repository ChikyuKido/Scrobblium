import 'package:flutter/material.dart';
import 'package:scrobblium/page/songs/song_tile_info_page.dart';
import 'package:scrobblium/page/songs/songs_filter_page.dart';
import 'package:scrobblium/service/song_data_service.dart';
import 'package:scrobblium/song_data.dart';
import 'package:scrobblium/util/settings_helper.dart';
import 'package:scrobblium/widgets/song_list_tile.dart';

import '../main_page.dart';

class SongsPage extends StatefulWidget {
  const SongsPage({super.key});

  @override
  State<SongsPage> createState() => _SongsPageState();
}

class _SongsPageState extends State<SongsPage> {
  List<SongTileData> _tileSongs = [];
  List<SongListTile> _tiles = [];

  @override
  void initState() {
    super.initState();
    if(_tiles.isEmpty) {
      _refresh(withoutFetch: true);
    }
    Future.delayed(Duration.zero, () {
      SettingsProvider().updateSelectedPage(getDropdownItems(), handleDropdownClick());
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
        onRefresh: () async => await _refresh(),
        child: _tileSongs.isEmpty
            ? Container()
            : ListView.builder(
                itemCount: _tileSongs.length,
                itemBuilder: (BuildContext context, int index) => _tiles[index]));
  }

  List<SongListTile> _getSongListTiles() {
    List<SongListTile> tiles = [];
    for(var song in _tileSongs) {
      tiles.add(SongListTile(
        songData: song,
        onTap: () {
          List<SongData> songs = SongDataService().getSongs()
              .where((element) =>
          song.getIdentifier() ==
              element.getIdentifier())
              .toList();
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      SongTileInfoPage(songs: songs))).then((value) => _refresh());
        },
      ));
    }
    return tiles;
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
  _refresh({withoutFetch = false}) async {
    if(!withoutFetch) {
      SongDataService().fetchData();
    }
    _tileSongs = _getSongTileData(SongDataService().getSongs(withSkipped: getValueBool("show-skipped-in-songs-page", false)));
    _tiles = _getSongListTiles();
    setState(() {});
  }

  List<PopupMenuItem<String>> getDropdownItems() {
    return [
      const PopupMenuItem<String>(
        value: "filter",
        child: Text("Filter")
      ),
    ];
  }

  PopupMenuItemSelected<String>? handleDropdownClick() {
    return (value) {
      if(value == "filter") {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const SongsFilterPage())).then((value) => setState(() {
        }));
      }
    };
  }
}
