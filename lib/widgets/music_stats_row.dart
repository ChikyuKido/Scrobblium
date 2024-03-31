import 'package:flutter/material.dart';
import 'package:scrobblium/service/method_channel_service.dart';

class MusicStatsRow extends StatelessWidget {
  final SongStatistic songStatistic;

  const MusicStatsRow({super.key, required this.songStatistic});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [_allTimeStats(context), _allTimeSkippedRatio(context)],
    );
  }

  Row _allTimeStats(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Expanded(
          child: Column(
            children: [
              Icon(
                Icons.headset,
                color: Theme.of(context).iconTheme.color,
                size: 30,
              ),
              const SizedBox(height: 5),
              Text(
                'Songs heard',
                style: Theme.of(context).textTheme.labelMedium,
              ),
              Text(
                '${songStatistic.songsListened}',
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            children: [
              Icon(
                Icons.access_time,
                color: Theme.of(context).iconTheme.color,
                size: 30,
              ),
              const SizedBox(height: 5),
              Text(
                'Time Listened',
                style: Theme.of(context).textTheme.labelMedium,
              ),
              Text(
                songStatistic.timeListened,
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            children: [
              Icon(
                Icons.skip_next,
                color: Theme.of(context).iconTheme.color,
                size: 30,
              ),
              const SizedBox(height: 5),
              Text(
                'Track Skipped',
                style: Theme.of(context).textTheme.labelMedium,
              ),
              Text(
                '${songStatistic.songsSkipped}',
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Row _allTimeSkippedRatio(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Expanded(
          child: Column(
            children: [
              Icon(
                Icons.access_time,
                color: Theme.of(context).iconTheme.color,
                size: 30,
              ),
              const SizedBox(height: 5),
              Text(
                'Time Listened',
                style: Theme.of(context).textTheme.labelMedium,
              ),
              Text(
                'Max. Progress',
                style: Theme.of(context).textTheme.labelMedium,
              ),
              Text(
                songStatistic.timeListenedByMaxProgress,
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            children: [
              Icon(
                Icons.aspect_ratio,
                color: Theme.of(context).iconTheme.color,
                size: 30,
              ),
              const SizedBox(height: 5),
              Text(
                'Ratio',
                style: Theme.of(context).textTheme.labelMedium,
              ),
              Text(
                songStatistic.ratioBetweenTimeListenedAndMaxProgress
                    .toStringAsFixed(2),
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
