import 'dart:math';

import 'package:flutter/material.dart';
import 'package:scrobblium/page/main_page.dart';
import 'package:scrobblium/service/song_provider_service.dart';
import 'package:scrobblium/widgets/date_option.dart';
import 'package:scrobblium/widgets/latest_song_tile.dart';
import 'package:scrobblium/widgets/music_stats_row.dart';
import 'package:scrobblium/widgets/top_ata.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  int _currentDateSelected = 3;
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      SettingsProvider().updateSelectedPage(getDropdownItems(), handleDropdownClick());
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: MethodChannelService.getSongData(
          afterDate: _currentDateSelected == 0
              ? DateTime.now().subtract(const Duration(days: 7))
              : _currentDateSelected == 1
                  ? DateTime.now().subtract(const Duration(days: 30))
                  : _currentDateSelected == 2
                      ? DateTime.now().subtract(const Duration(days: 365))
                      : null),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        if (snapshot.data == null) {
          return const Text("No data available");
        }
        var songs = snapshot.data ?? [];

        var songsRemovedSkip = MethodChannelService.removeSkips(songs);
        songsRemovedSkip.sort((a, b) => b.endTime.compareTo(a.endTime));
        var allTimeStats = MethodChannelService.getSongStatistics(songs);
        return ListView(
          children: [
            Center(
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(10),bottomRight: Radius.circular(10)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    DateOption(
                        text: 'Last Week',
                        selected: _currentDateSelected == 0,
                        onTap: () => setState(() {
                              _currentDateSelected = 0;
                            })),
                    DateOption(
                        text: 'Last Month',
                        selected: _currentDateSelected == 1,
                        onTap: () => setState(() {
                              _currentDateSelected = 1;
                            })),
                    DateOption(
                        text: 'Last Year',
                        selected: _currentDateSelected == 2,
                        onTap: () => setState(() {
                              _currentDateSelected = 2;
                            })),
                    DateOption(
                        text: 'All Time',
                        selected: _currentDateSelected == 3,
                        onTap: () => setState(() {
                              _currentDateSelected = 3;
                            })),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: Text(
                'Your ${_currentDateSelected == 0 ? "Last Week" : _currentDateSelected == 1 ? "Last Month" : _currentDateSelected == 2 ? "Last Year" : "All Time"} Stats',
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
            songsRemovedSkip.isEmpty
                ? Container()
                : Column(
                    children: songsRemovedSkip
                        .sublist(0, min(7, songsRemovedSkip.length))
                        .map((e) => LatestSongTile(songData: e))
                        .toList(),
                  ),
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
        );
      },
    );
  }

  List<PopupMenuItem<String>> getDropdownItems() {
    return [PopupMenuItem<String>(child: Text("test"),value: "test",)];
  }

  PopupMenuItemSelected<String>? handleDropdownClick() {
    return (value) {
      if(value == "test") {
        print("hello");
      }
    };
  }
}
