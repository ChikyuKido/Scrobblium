import 'dart:io';

import 'package:flutter/material.dart';
import 'package:music_tracker/song_data.dart';
import 'package:path_provider/path_provider.dart';

class SongListTile extends StatelessWidget {
  final SongTileData songData;

  const SongListTile({super.key, required this.songData});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _getAppFilesPath(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          final appFilesPath = snapshot.data ?? '';
          String imagePath =
              '$appFilesPath/arts/${songData.getIdentifier()}.png';
          bool imageExists = File(imagePath).existsSync();

          return ListTile(
            leading: CircleAvatar(
              backgroundImage: imageExists ? FileImage(File(imagePath)) : null,
              child: imageExists ? null : Text(songData.title[0]),
            ),
            title: Text(songData.title),
            subtitle: Text("${songData.artist} - ${songData.album}"),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text("Listens: ${songData.listenCount}"),
                Text("Time: ${_formatDuration(songData.allTimeListened)}"),
              ],
            ),
          );
        }
      },
    );
  }

  Future<String> _getAppFilesPath() async {
    try {
      Directory appDocDir = await getApplicationCacheDirectory();
      String appFilesPath = appDocDir.path;
      return appFilesPath;
    } catch (e) {
      print("Error getting app files directory: $e");
      return '';
    }
  }

  String _formatDuration(int durationInSeconds) {
    Duration duration = Duration(seconds: durationInSeconds);
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${duration.inHours}:$twoDigitMinutes:$twoDigitSeconds";
  }
}
