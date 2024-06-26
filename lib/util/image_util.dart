import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import 'package:scrobblium/dao/song_data.dart';

class ImageUtil {

  static String? _appFilesPath;

  static Future<FileImage?> getSongImage(SongData songData) async {
    _appFilesPath ??= await _getAppFilesPath();
    String imagePath = '$_appFilesPath/arts/${songData.getIdentifier()}.png';
    File f = File(imagePath);
    if (!f.existsSync()) {
      return null;
    }
    return FileImage(f);
  }

  static Future<FileImage?> getSongImageFromTile(SongTileData songData) async {
    _appFilesPath ??= await _getAppFilesPath();
    String imagePath = '$_appFilesPath/arts/${songData.getIdentifier()}.png';
    File f = File(imagePath);
    if (!f.existsSync()) {
      return null;
    }
    return FileImage(f);
  }

  static Future<String> _getAppFilesPath() async {
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
