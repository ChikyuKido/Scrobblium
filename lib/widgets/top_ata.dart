import 'dart:math';

import 'package:flutter/material.dart';
import 'package:scrobblium/song_data.dart';
import 'package:syncfusion_flutter_charts/charts.dart';


enum ATA { artist, album, track }

class TopATA extends StatelessWidget {
  final List<SongData> songs;
  final ATA ata;

  const TopATA({super.key, required this.songs, required this.ata});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          getTextFromAta(),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        SfCartesianChart(
            primaryXAxis: const CategoryAxis(
              isVisible: false,
            ),
            tooltipBehavior: TooltipBehavior(
                color: Theme.of(context).cardColor,
                borderColor: Theme.of(context).canvasColor,
                elevation: 24,
                textStyle: Theme.of(context).textTheme.bodyMedium,
                enable: true),
            series: <CartesianSeries<_ChartData, String>>[
              BarSeries<_ChartData, String>(
                  dataLabelMapper: (datum, index) {
                    return "${datum.x} (${datum.y})";
                  },
                  dataLabelSettings: DataLabelSettings(
                      isVisible: true,
                      labelAlignment: ChartDataLabelAlignment.bottom,
                      textStyle: Theme.of(context).textTheme.bodySmall),
                  dataSource: getData(),
                  xValueMapper: (_ChartData data, _) => data.x,
                  yValueMapper: (_ChartData data, _) => data.y,
                  name: getTextFromAta(),
                  color: Theme.of(context).highlightColor)
            ])
      ],
    );
  }

  String getTextFromAta() {
    return ata == ATA.artist
        ? "Artist"
        : ata == ATA.track
            ? "Track"
            : ata == ATA.album
                ? "Album"
                : "";
  }

  List<_ChartData> getData() {
    List<_ChartData> chartData = [];
    for (var song in songs) {
      if (song.timeListened < 20) continue;
      var index = -1;
      switch (ata) {
        case ATA.artist:
          index = chartData.indexWhere((element) => element.id == song.artist);
          break;
        case ATA.track:
          index = chartData
              .indexWhere((element) => element.id == song.getIdentifier());
          break;
        case ATA.album:
          index = chartData
              .indexWhere((element) => element.id == song.album + song.artist);
          break;
      }

      if (index != -1) {
        chartData[index].y++;
      } else {
        String title = "";
        String id = "";
        if (ata == ATA.artist) {
          title = song.artist;
          id = song.artist;
        } else if (ata == ATA.track) {
          title = song.title;
          id = song.getIdentifier();
        } else if (ata == ATA.album) {
          title = song.album;
          id = song.album + song.artist;
        }
        chartData.add(_ChartData(title, id, 1));
      }
    }
    chartData.sort((a, b) => b.y - a.y);
    return chartData.sublist(0, min(7, chartData.length)).reversed.toList();
  }
}

class _ChartData {
  _ChartData(this.x, this.id, this.y);

  String x;
  final String id;
  int y;
}
