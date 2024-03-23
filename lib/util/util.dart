String formatDuration(int durationInSeconds) {
  Duration duration = Duration(seconds: durationInSeconds);
  int days = duration.inDays;
  int hours = duration.inHours.remainder(24);
  int minutes = duration.inMinutes.remainder(60);
  int seconds = duration.inSeconds.remainder(60);

  String formattedDuration = '';
  if (days > 0) {
    formattedDuration += '${days}d ';
  }
  if (hours > 0) {
    formattedDuration += '${hours}h ';
  }
  if (minutes > 0) {
    formattedDuration += '${minutes}m ';
  }
  if (seconds > 0 || formattedDuration.isEmpty) {
    formattedDuration += '${seconds}s';
  }
  return formattedDuration.trim();
}
