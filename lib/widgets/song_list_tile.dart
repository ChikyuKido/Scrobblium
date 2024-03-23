import 'package:flutter/material.dart';
import 'package:scrobblium/song_data.dart';
import 'package:scrobblium/util/image_util.dart';
import 'package:scrobblium/util/util.dart';

class SongListTile extends StatelessWidget {
  final SongTileData songData;
  final GestureTapCallback onTap;

  const SongListTile({super.key, required this.songData, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<FileImage?>(
      future: getSongImageFromTile(songData),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return ListTile(
            onTap: onTap,
            leading: CircleAvatar(
              backgroundImage: snapshot.data,
              child: snapshot.data != null ? null : Text(songData.title[0]),
            ),
            title: Text(songData.title, softWrap: false),
            subtitle: Text(songData.artist, softWrap: false),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text("Listens: ${songData.listenCount}"),
                Text("Time: ${formatDuration(songData.allTimeListened)}"),
              ],
            ),
          );
        }
      },
    );
  }
}
