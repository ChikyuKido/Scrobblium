import 'package:flutter/material.dart';
import 'package:scrobblium/page/songs/song_tile_info_page.dart';
import 'package:scrobblium/service/song_data_service.dart';
import 'package:scrobblium/song_data.dart';
import 'package:scrobblium/util/settings_helper.dart';
import 'package:scrobblium/widgets/debounce_text_field.dart';
import 'package:scrobblium/widgets/song_list_tile.dart';

class SongsPage extends StatefulWidget {
  const SongsPage({super.key});

  @override
  State<SongsPage> createState() => _SongsPageState();
}

class _SongsPageState extends State<SongsPage> {
  List<SongTileData> _tileSongs = [];
  List<SongListTile> _tiles = [];
  List<SongListTile> _filteredTiles = [];

  bool _isSearching = false;
  String _query = "";
  String _selectedSortOption = 'Times Listened';
  bool _isDescending = true;

  @override
  void initState() {
    super.initState();
    if (_tiles.isEmpty) {
      _refresh(withoutFetch: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: _isSearching
              ? DebounceTextField(
                  decoration: InputDecoration(
                      hintText: 'Search...',
                      hintStyle: Theme.of(context).textTheme.bodyMedium),
                  onDebounceChanged: (value) {
                    _query = value;
                    _filterTiles();
                    setState(() {});
                  },
                  bounceDuration: const Duration(milliseconds: 250),
                  style: Theme.of(context).textTheme.bodyMedium,
                )
              : const Text("Songs"),
          centerTitle: true,
          actions: _buildAppBarActions(),
        ),
        body: RefreshIndicator(
          onRefresh: () async => await _refresh(),
          child: _filteredTiles.isEmpty
              ? Container()
              : ListView.builder(
                  itemCount: _filteredTiles.length + (_isSearching ? 1 : 0),
                  itemBuilder: (BuildContext context, int index) {
                    if (_isSearching && index == 0) {
                      return _extraSearchOptions();
                    }
                    return _filteredTiles[_isSearching ? index - 1 : index];
                  },
                ),
        ));
  }

  Widget _extraSearchOptions() {
    return Container(
      padding: const EdgeInsets.only(left: 20, right: 5),
      margin: const EdgeInsets.only(top: 5),
      decoration: BoxDecoration(
        color: Theme.of(context).secondaryHeaderColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              'Sort By: ',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Expanded(
            flex: 3,
            child: PopupMenuButton(
              padding: EdgeInsets.zero,
              child: Text(
                _selectedSortOption,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              onSelected: (String value) {
                _selectedSortOption = value;
                _filterTiles();
                setState(() {});
              },
              itemBuilder: (BuildContext context) => const [
                PopupMenuItem(
                  value: 'Times Listened',
                  child: Text('Times Listened'),
                ),
                PopupMenuItem(
                  value: 'Time Listened',
                  child: Text('Time Listened'),
                ),
                PopupMenuItem(
                  value: 'Last Activity',
                  child: Text('Last Activity'),
                ),
                PopupMenuItem(
                  value: 'By Title',
                  child: Text('By Title'),
                ),
                PopupMenuItem(
                  value: 'By Author',
                  child: Text('By Author'),
                ),
                PopupMenuItem(
                  value: 'By Album',
                  child: Text('By Album'),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: IconButton(
                onPressed: () {
                  _isDescending = !_isDescending;
                  _filterTiles();
                  setState(() {});
                },
                icon: Icon(
                  _isDescending ? Icons.arrow_downward : Icons.arrow_upward,
                  size: 24,
                ),
                color: Colors.white),
          )
        ],
      ),
    );
  }

  List<Widget> _buildAppBarActions() {
    if (_isSearching) {
      return [
        IconButton(
            onPressed: () {
              _isSearching = false;
              _query = "";
              _filterTiles();
              setState(() {});
            },
            icon: const Icon(Icons.cancel))
      ];
    } else {
      return [
        IconButton(
          onPressed: () {
            _isSearching = true;
            setState(() {});
          },
          icon: const Icon(Icons.search),
        ),
      ];
    }
  }

  _filterTiles() {
    _filteredTiles = _tiles
        .where((element) =>
            element.songData.title.toLowerCase().contains(_query.toLowerCase()))
        .toList();
    _filteredTiles.sort((a, b) {
      switch (_selectedSortOption) {
        case 'Times Listened':
          return _isDescending
              ? b.songData.listenCount.compareTo(a.songData.listenCount)
              : a.songData.listenCount.compareTo(b.songData.listenCount);
        case 'Time Listened':
          return _isDescending
              ? b.songData.allTimeListened.compareTo(a.songData.allTimeListened)
              : a.songData.allTimeListened
                  .compareTo(b.songData.allTimeListened);
        case 'Last Activity':
          return _isDescending
              ? b.songData.lastActivity.compareTo(a.songData.lastActivity)
              : a.songData.lastActivity.compareTo(b.songData.lastActivity);
        case 'By Title':
          return _isDescending
              ? b.songData.title.compareTo(a.songData.title)
              : a.songData.title.compareTo(b.songData.title);
        case 'By Author':
          return _isDescending
              ? b.songData.artist.compareTo(a.songData.artist)
              : a.songData.artist.compareTo(b.songData.artist);
        case 'By Album':
          return _isDescending
              ? b.songData.album.compareTo(a.songData.album)
              : a.songData.album.compareTo(b.songData.album);
        default:
          return 0;
      }
    });
  }

  List<SongListTile> _getSongListTiles() {
    List<SongListTile> tiles = [];
    for (var song in _tileSongs) {
      tiles.add(SongListTile(
        songData: song,
        onTap: () {
          List<SongData> songs = SongDataService()
              .getSongs()
              .where(
                  (element) => song.getIdentifier() == element.getIdentifier())
              .toList();
          Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SongTileInfoPage(songs: songs)))
              .then((value) => _refresh());
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
        if (item.endTime.isAfter(songs[index].lastActivity)) {
          songs[index].lastActivity = item.endTime;
        }
      } else {
        songs.add(songTileData);
      }
    }
    songs.sort((a, b) => b.listenCount.compareTo(a.listenCount));
    return songs;
  }

  _refresh({withoutFetch = false}) async {
    if (!withoutFetch) {
      SongDataService().fetchData();
    }
    _tileSongs = _getSongTileData(SongDataService().getSongs(
        withSkipped: getValueBool("show-skipped-in-songs-page", false)));
    _tiles = _getSongListTiles();
    _filterTiles();
    setState(() {});
  }
}
