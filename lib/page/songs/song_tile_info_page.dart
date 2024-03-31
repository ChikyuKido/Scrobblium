import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:scrobblium/service/method_channel_service.dart';
import 'package:scrobblium/song_data.dart';
import 'package:scrobblium/util/image_util.dart';
import 'package:scrobblium/util/util.dart';
import 'package:scrobblium/widgets/music_stats_row.dart';


class SongTileInfoPage extends StatefulWidget {
  final List<SongData> songs;
  const SongTileInfoPage({super.key, required this.songs});

  @override
  State<SongTileInfoPage> createState() => _SongTileInfoPageState();

}

class _SongTileInfoPageState extends State<SongTileInfoPage>{
  late final SongData song;

  @override
  void initState() {
    song = widget.songs[0];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SongStatistic stats = MethodChannelService.getSongStatistics(widget.songs);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Song statistic"),
      ),
      body: Column(
        children: [
          getSongInfo(),
          MusicStatsRow(songStatistic: stats),
          Column(
            children: widget.songs.indexed
                .map((e) => getSongTile(e.$2, e.$1 + 1))
                .toList(),
          ),
        ],
      ),
  );
  }

  Widget getSongTile(SongData song, int index) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: null,
        child: Text("$index"),
      ),
      onLongPress: () async {
        MethodChannelService.deleteEntry(song.id);
        widget.songs.removeWhere((element) => element.id == song.id);
        setState(() {});
      },
      title: Text(
        "Time Listened: ${formatDuration(song.timeListened)}",
      ),
      subtitle: Text(
        "Listened on: ${_formatDate(song.endTime)}",
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    // Format the date as per your requirement
    return "${dateTime.day}.${dateTime.month}.${dateTime.year}";
  }

  Widget getSongInfo() {
    return FutureBuilder<FileImage?>(
      future: getSongImage(song),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: snapshot.data,
              child: snapshot.data != null ? null : Text(song.title[0]),
            ),
            title: Text("${song.title} - ${song.artist}", softWrap: false),
            subtitle: Text(song.album, softWrap: false),
          );
        }
      },
    );
  }
}
