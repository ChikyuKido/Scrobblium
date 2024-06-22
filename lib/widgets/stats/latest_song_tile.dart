import 'package:flutter/material.dart';
import 'package:scrobblium/dao/song_data.dart';
import 'package:scrobblium/util/image_util.dart';

class LatestSongTile extends StatelessWidget {
  final SongData songData;
  final GestureTapCallback onTap;

  const LatestSongTile({super.key, required this.songData, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<FileImage?>(
      future: ImageUtil.getSongImage(songData),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
            child: GestureDetector(
              onTap: onTap,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundImage: snapshot.data,
                    child: snapshot.data != null ? null : Text(songData.title[0]),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text("${songData.artist} - ${songData.title}",
                        style: Theme.of(context).textTheme.labelMedium),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
