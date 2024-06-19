import 'package:flutter/material.dart';
import 'package:scrobblium/dao/song_data.dart';
import 'package:scrobblium/page/songs/song_tile_info_page.dart';
import 'package:scrobblium/util/converter_util.dart';
import 'package:scrobblium/util/image_util.dart';


class SongListTile extends StatelessWidget {
  final SongTileData songData;
  const SongListTile({super.key, required this.songData});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<FileImage?>(
      future: ImageUtil.getSongImageFromTile(songData),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return ListTile(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SongTileInfoPage(songs: songData.songs)));
            },
            leading: CircleAvatar(
              backgroundImage: snapshot.data,
              child: snapshot.data != null ? null : Text(songData.title[0]),
            ),
            title: Text(songData.combineMode == "Track" ?
              songData.title : songData.combineMode == "Artist" ?
              songData.artist : songData.combineMode == "Album" ? songData.album : songData.title, softWrap: false),
            subtitle: songData.combineMode == "Track" || songData.combineMode == "Nothing" ? Text(songData.artist, softWrap: false) : null,
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text("Listens: ${songData.listenCount}"),
                Text("Time: ${ConverterUtil.formatDuration(songData.allTimeListened)}"),
              ],
            ),
          );
        }
      },
    );
  }
}
