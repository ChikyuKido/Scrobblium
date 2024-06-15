import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

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

void showToast(String text) {
  Fluttertoast.showToast(
      msg: "Successfully exported Database",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.grey.shade900,
      textColor: Colors.white,
      fontSize: 16.0
  );
}