class SongData {
  final int id;
  final String artist;
  final String title;
  final String album;
  final String albumAuthor;
  final int progress;
  final int maxProgress;
  final DateTime startTime;
  final DateTime endTime;
  final int timeListened;

  SongData({
    required this.id,
    required this.artist,
    required this.title,
    required this.album,
    required this.albumAuthor,
    required this.progress,
    required this.maxProgress,
    required this.startTime,
    required this.endTime,
    required this.timeListened,
  });

  factory SongData.fromJson(Map<String, dynamic> json) {
    return SongData(
      id: json['id'] ?? 0,
      artist: json['artist'] ?? '',
      title: json['title'] ?? '',
      album: json['album'] ?? '',
      albumAuthor: json['albumAuthor'] ?? '',
      progress: json['progress'] ?? 0,
      maxProgress: json['maxProgress'] ?? 0,
      startTime: DateTime.parse(json['startTime'] ?? '1970-01-01T00:00:00Z'),
      endTime: DateTime.parse(json['endTime'] ?? '1970-01-01T00:00:00Z'),
      timeListened: json['timeListened'] ?? 0,
    );
  }

  String getIdentifier() {
    return "$artist,$title,$album";
  }

  SongTileData toSongTileData() {
    return SongTileData(artist, title, album, albumAuthor, timeListened, 1);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SongData &&
          runtimeType == other.runtimeType &&
          artist == other.artist &&
          title == other.title &&
          album == other.album &&
          albumAuthor == other.albumAuthor;

  @override
  int get hashCode =>
      artist.hashCode ^ title.hashCode ^ album.hashCode ^ albumAuthor.hashCode;
}

class SongTileData {
  final String artist;
  final String title;
  final String album;
  final String albumAuthor;
  int allTimeListened;
  int listenCount;

  SongTileData(this.artist, this.title, this.album, this.albumAuthor,
      this.allTimeListened, this.listenCount);

  String getIdentifier() {
    return "$artist,$title,$album";
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SongTileData &&
          runtimeType == other.runtimeType &&
          artist == other.artist &&
          album == other.album &&
          albumAuthor == other.albumAuthor &&
          listenCount == other.listenCount;

  @override
  int get hashCode =>
      artist.hashCode ^
      album.hashCode ^
      albumAuthor.hashCode ^
      listenCount.hashCode;
}
