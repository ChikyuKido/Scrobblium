import 'package:flutter/material.dart';
import 'package:scrobblium/page/songs/song_tile_info_page.dart';
import 'package:scrobblium/page/songs/songs_filter_page.dart';
import 'package:scrobblium/service/song_data_service.dart';
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
  List<SongListTile> _tiles = [];

  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    if(_tiles.isEmpty) {
      _refresh(withoutFetch: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching ? TextField(
          decoration: InputDecoration(
            hintText: 'Search...',
            hintStyle: Theme.of(context).textTheme.bodyMedium
          ),
          style: Theme.of(context).textTheme.bodyMedium,
        ) : const Text("Songs"),
        centerTitle: true,
        actions: _buildAppBarActions(),
      ),
      body: RefreshIndicator(
        onRefresh: () async => await _refresh(),
        child: _tileSongs.isEmpty ? Container() :
            ListView.builder(
              itemCount: _tileSongs.length + (_isSearching ? 1 : 0),
              itemBuilder: (BuildContext context, int index) {
                if(_isSearching && index == 0) {
                  return _extraSearchOptions();
                }
                return _tiles[index];
              },
            ),
      )
    );
  }


  Widget _extraSearchOptions() {
    return Container();
  }

  List<Widget> _buildAppBarActions() {
    if (_isSearching) {
      return [
        IconButton(onPressed: () {
          setState(() {
            _isSearching = false;
          });
        },
            icon: const Icon(Icons.cancel))
      ];
    } else {
      return [
        IconButton(
          onPressed: () {
            setState(() {
              _isSearching = true;
            });
          },
          icon: const Icon(Icons.search),
        ),
      ];
    }
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
