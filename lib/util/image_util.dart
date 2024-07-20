import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:scrobblium/dao/song_data.dart';

class ImageUtil {
  static Logger log = Logger("ImageUtil");
  static String? _appFilesPath;

  static Future<FileImage?> getSongImage(SongData songData) async {
    _appFilesPath ??= await _getAppFilesPath();
    String imagePath = '$_appFilesPath/arts/${songData.getIdentifier()}.jpeg';
    File f = File(imagePath);
    if (!f.existsSync()) {
      return null;
    }
    return FileImage(f);
  }

  static Future<FileImage?> getSongImageFromTile(SongTileData songData) async {
    _appFilesPath ??= await _getAppFilesPath();
    String imagePath = '$_appFilesPath/arts/${songData.getIdentifier()}.jpeg';
    File f = File(imagePath);
    if (!f.existsSync()) {
      FileImage? img = getFallbackImage(songData.artist);
      if(img != null) return img;
      img = getFallbackImage(songData.album);
      if(img != null) return img;
      return null;
    }
    return FileImage(f);
  }

  /// This method searches for an image with a specific identifier in the artists directory.
  /// If it finds one, it returns the image and caches it with the identifier name for future use.
  static FileImage? getFallbackImage(String identifier)  {
    Directory artsDirectory = Directory('$_appFilesPath/arts');
    if(!artsDirectory.existsSync()) return null;
    File identifierFile = File("${artsDirectory.path}/$identifier.jpeg");
    if(identifierFile.existsSync()) {
      return FileImage(identifierFile);
    }
    List<FileSystemEntity> files = artsDirectory.listSync();
    for (var file in files) {
      String fileName = path.basename(file.path);
      if(fileName.contains(identifier)) {
        File artistFile = File(file.path);
        artistFile.copySync("${artsDirectory.path}/$identifier.jpeg");
        return FileImage(artistFile);
      }
    }
    return null;
  }

  static Future<String> _getAppFilesPath() async {
    try {
      Directory appDocDir = await getApplicationCacheDirectory();
      String appFilesPath = appDocDir.path;
      return appFilesPath;
    } catch (e) {
      log.shout("Error getting app files directory: $e");
      return '';
    }
  }
}
