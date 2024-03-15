import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:scrobblium/service/song_provider_service.dart';


exportDatabase() async{
  // print(await Permission.accessNotificationPolicy.isGranted);
  // print(await Permission.notification.isGranted);
  // String? baseDir = (await _getDatabaseDirectory())?.path;
  // final file = File("$baseDir/song_database");
  // await SongProviderService.makeWALCheckpoint();
  // final androidInfo = await DeviceInfoPlugin().androidInfo;
  // String? result = await FilePicker.platform.getDirectoryPath();
  // print(await Permission.accessNotificationPolicy.isGranted);
  // print(await Permission.notification.isGranted);
  // bool hasPermission = false;
  // if(androidInfo.version.sdkInt <= 320) {
  //   if(await Permission.storage.isDenied) {
  //     await Permission.storage.request();
  //     hasPermission = await Permission.storage.isGranted;
  //   }
  // }else {
  //   //Permission is granted when picking the folder
  //   hasPermission = true;
  // }
  // print(hasPermission);
  // if (result != null && hasPermission) {
  //   File("$result/song_database").createSync();
  //   File("$result/song_database").writeAsBytesSync(file.readAsBytesSync());
  // }

}


Future<Directory?> _getDatabaseDirectory() async{
  try {
    final Directory baseDir = await getApplicationDocumentsDirectory();
    final String databasePath = baseDir.path.replaceAll('app_flutter', 'databases');
    final Directory databaseDir = Directory(databasePath);
    return databaseDir;
  } catch (e) {
    print("Error: $e");
    return null;
  }
}
