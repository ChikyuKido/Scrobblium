import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:music_tracker/service/song_provider_service.dart';
import 'package:music_tracker/widgets/latest_song_tile.dart';
import 'package:music_tracker/widgets/music_stats_row.dart';
import 'package:music_tracker/widgets/top_ata.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: SongProviderService.getSongData(withSkipped: true),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        if (snapshot.data == null) {
          return const Text("No data available");
        }
        var songs = snapshot.data ?? [];
        songs.sort((a, b) => b.endTime.compareTo(a.endTime));
        var allTimeStats = SongProviderService.getSongStatistics(songs);
        return ListView(
          children: [
            const SizedBox(height: 10),
            Center(
              child: Text(
                'Your All-Time Stats',
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
            Column(
              children: SongProviderService.removeSkips(songs).sublist(0,min(7, songs.length)).map((e) => LatestSongTile(songData: e)).toList(),
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
}
