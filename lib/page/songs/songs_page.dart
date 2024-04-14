import 'package:anim_search_bar/anim_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:scrobblium/dao/song_data.dart';
import 'package:scrobblium/service/song_data_service.dart';
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
  List<SongListTile> _filteredTiles = [];

  TextEditingController _textController = TextEditingController();

  bool _isSearching = false;
  String _query = "";
  String _selectedSortOption = 'Times Listened';
  bool _isDescending = true;
  String _selectedCombineOption = "Track";

  double _searchAnimationHeight = 0;

  @override
  void initState() {
    super.initState();
    if (getValueBool("search-save-options", true)) {
      _isDescending = getValueBool("search-order-option", true);
      _selectedSortOption =
          getValueString("search-sort-option", "Times Listened");
      _selectedCombineOption = getValueString("search-combine-option", "Track");
    }
    if (_tiles.isEmpty) {
      _refresh(withoutFetch: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Visibility(
              visible: !_isSearching,
              child: const Text("Songs")
          ),
          centerTitle: true,
          actions: _buildAppBarActions(),
        ),
        body: RefreshIndicator(
          onRefresh: () async => await _refresh(),
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                height: _searchAnimationHeight,
                child: SingleChildScrollView(
                  child: _extraSearchOptions(),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _filteredTiles.length,
                  itemBuilder: (BuildContext context, int index) {
                    return _filteredTiles[index];
                  },
                ),
              ),
            ],
          ),
        ));
  }

  Widget _extraSearchOptions() {
    return Container(
        padding: const EdgeInsets.only(left: 20, right: 5, bottom: 10),
        margin: const EdgeInsets.only(top: 5),
        decoration: BoxDecoration(
          color: Theme.of(context).secondaryHeaderColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Row(
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
                      Settings.setValue("search-sort-option", value);
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
                        Settings.setValue("search-order-option", _isDescending);
                        _filterTiles();
                        setState(() {});
                      },
                      icon: Icon(
                        _isDescending
                            ? Icons.arrow_downward
                            : Icons.arrow_upward,
                        size: 24,
                      ),
                      color: Colors.white),
                )
              ],
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'Combine By: ',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: PopupMenuButton(
                    padding: EdgeInsets.zero,
                    child: Text(
                      _selectedCombineOption,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    onSelected: (String value) {
                      _selectedCombineOption = value;
                      _refresh(withoutFetch: true);
                      Settings.setValue("search-combine-option", value);
                    },
                    itemBuilder: (BuildContext context) => const [
                      PopupMenuItem(
                        value: 'Track',
                        child: Text('Track'),
                      ),
                      PopupMenuItem(
                        value: 'Artist',
                        child: Text('Artist'),
                      ),
                      PopupMenuItem(
                        value: 'Album',
                        child: Text('Album'),
                      ),
                      PopupMenuItem(
                        value: 'Nothing',
                        child: Text('Nothing'),
                      ),
                    ],
                  ),
                ),
                const Expanded(
                  flex: 1,
                  child:
                      SizedBox(), // Placeholder for the IconButton to maintain layout consistency
                )
              ],
            ),
          ],
        ));
  }

  List<Widget> _buildAppBarActions() {
    return [
      Padding(
          padding: const EdgeInsets.only(right: 20),
          child: AnimSearchBar(
              width: MediaQuery.of(context).size.width/9*8,
              color: Theme.of(context).primaryColor,
              autoFocus: true,
              closeOnSubmit: false,
              animationDurationInMilli: 150,
              textController: _textController,
              debounceDuration: const Duration(milliseconds: 250),
              onSearchOpen: () => setState(() {
                _isSearching = true;
                _searchAnimationHeight = 100;
              }),
              onSearchClose: () => setState(() {
                _isSearching = false;
                _query = "";
                _searchAnimationHeight = 0;
                _filterTiles();
                setState(() {});
              }),
              onDebounceChanged: (value) {
                _query = value;
                _filterTiles();
                setState(() {});
              },
          )
      )
    ];
  }

  _filterTiles() {
    switch (_selectedCombineOption) {
      case "Artist":
        {
          _filteredTiles = _tiles
              .where((element) => element.songData.artist
                  .toLowerCase()
                  .contains(_query.toLowerCase()))
              .toList();
          break;
        }
      case "Album":
        {
          _filteredTiles = _tiles
              .where((element) => element.songData.album
                  .toLowerCase()
                  .contains(_query.toLowerCase()))
              .toList();
        }
      case "Track":
      default:
        {
          _filteredTiles = _tiles
              .where((element) => element.songData.title
                  .toLowerCase()
                  .contains(_query.toLowerCase()))
              .toList();
          break;
        }
    }

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
      tiles.add(SongListTile(songData: song));
    }
    return tiles;
  }

  List<SongTileData> _getSongTileData(List<SongData> songDatas) {
    List<SongTileData> songs = [];
    for (var item in songDatas) {
      var songTileData = item.toSongTileData();
      var index = -1;
      switch (_selectedCombineOption) {
        case "Track":
          {
            index = songs.indexWhere((element) =>
                element.title == songTileData.title &&
                element.artist == songTileData.artist &&
                element.album == songTileData.album);
            break;
          }
        case "Artist":
          {
            index = songs
                .indexWhere((element) => element.artist == songTileData.artist);
            break;
          }
        case "Album":
          {
            index = songs
                .indexWhere((element) => element.album == songTileData.album);
            break;
          }
      }

      if (index != -1) {
        songs[index].listenCount++;
        songs[index].allTimeListened += item.timeListened;
        if (item.endTime.isAfter(songs[index].lastActivity)) {
          songs[index].lastActivity = item.endTime;
        }
        songs[index].songs.add(item);
      } else {
        songs.add(songTileData);
        songTileData.songs.add(item);
        songTileData.combineMode = _selectedCombineOption;
      }
    }
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
