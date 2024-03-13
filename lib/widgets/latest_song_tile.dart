import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../song_data.dart';

class LatestSongTile extends StatelessWidget {
  final SongData songData;
  const LatestSongTile({super.key, required this.songData});

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

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0,horizontal: 16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 15,
                  backgroundImage: imageExists ? FileImage(File(imagePath)) : null,
                  child: imageExists ? null : Text(songData.title[0]),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text("${songData.artist} - ${songData.title}", style: Theme.of(context).textTheme.labelSmall),
                ),
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
}
