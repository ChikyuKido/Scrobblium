import 'dart:math';

import 'package:flutter/material.dart';
import 'package:scrobblium/dao/song_data.dart';
import 'package:scrobblium/service/method_channel_service.dart';
import 'package:scrobblium/service/song_data_service.dart';
import 'package:scrobblium/util/stats_util.dart';
import 'package:scrobblium/widgets/date_option.dart';
import 'package:scrobblium/widgets/latest_song_tile.dart';
import 'package:scrobblium/widgets/music_stats_row.dart';
import 'package:scrobblium/widgets/top_ata.dart';

import 'songs/song_tile_info_page.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  int _currentDateSelected = 3;
  final List<String> dates = ["Last Week","Last Month","Last Year","All Time"];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    DateTime? selectedDate = _currentDateSelected == 0
        ? DateTime.now().subtract(const Duration(days: 7))
        : _currentDateSelected == 1
        ? DateTime.now().subtract(const Duration(days: 30))
        : _currentDateSelected == 2
        ? DateTime.now().subtract(const Duration(days: 365))
        : null;
    var songs = SongDataService().getSongs(
        afterDate: selectedDate, withSkipped: false);
    songs.sort((a, b) => b.endTime.compareTo(a.endTime));
    var allTimeStats = StatsUtil.getSongStatistics(SongDataService().getSongs(afterDate: selectedDate));

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Stats"),
      ),
      body: RefreshIndicator(
          child: ListView(
            children: [
              dateChooser(context),
              const SizedBox(height: 10),
              Center(
                child: Text(
                  'Your ${dates[_currentDateSelected]} Stats',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              const SizedBox(height: 10),
              MusicStatsRow(songStatistic: allTimeStats),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  'Last 7 Songs',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              _latestSongs(songs, context),
              const SizedBox(height: 10),
              Center(
                child: Text(
                  'Detailed Statistics',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              const SizedBox(height: 10),
              TopATA(ata: ATA.artist, songs: songs),
              TopATA(ata: ATA.track, songs: songs),
              TopATA(ata: ATA.album, songs: songs),
            ],
          ),
          onRefresh: () => _refresh()),
    );
  }

  Center dateChooser(BuildContext context) {
    return Center(
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Theme.of(context).canvasColor,
                borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: dates.indexed.map((e) => DateOption(
                    text: e.$2,
                    selected: e.$1 == _currentDateSelected,
                    onTap: () => setState(() => _currentDateSelected = e.$1 )))
                    .toList(),
              ),
            ),
          );
  }

  Widget _latestSongs(List<SongData> songs, BuildContext context) {
    return songs.isEmpty
              ? Container()
              : Column(
                  children: songs
                      .sublist(0, min(7, songs.length))
                      .map((e) => LatestSongTile(
                      songData: e,
                      onTap: () {
                        List<SongData> songs = SongDataService().getSongs()
                            .where((element) =>
                            e.getIdentifier() ==
                            element.getIdentifier())
                            .toList();
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    SongTileInfoPage(songs: songs))).then((value) => _refresh());
                      },
                      ))
                      .toList(),
                );
  }

  _refresh() async {
    await SongDataService().fetchData();
    setState(() {});
  }
  List<PopupMenuItem<String>> getDropdownItems() {
    return [];
  }

  PopupMenuItemSelected<String>? handleDropdownClick() {
    return (value) {

    };
  }
}
