import 'package:flutter/material.dart';
import 'package:scrobblium/util/image_util.dart';

import '../song_data.dart';

class LatestSongTile extends StatelessWidget {
  final SongData songData;

  const LatestSongTile({super.key, required this.songData});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<FileImage?>(
      future: getSongImage(songData),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 15,
                  backgroundImage: snapshot.data,
                  child: snapshot.data != null ? null : Text(songData.title[0]),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text("${songData.artist} - ${songData.title}",
                      style: Theme.of(context).textTheme.labelSmall),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
