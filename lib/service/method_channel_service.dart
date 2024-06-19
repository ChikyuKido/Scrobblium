import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:scrobblium/dao/method_channel_data.dart';
import 'package:scrobblium/dao/song_data.dart';
import 'package:scrobblium/messages/proto/song_datam.pb.dart';
import 'package:scrobblium/util/settings_helper.dart';
import 'package:scrobblium/util/util.dart';

class MethodChannelService {
  static const platform = MethodChannel('MusicListener');
  
  static init() {
    platform.setMethodCallHandler((call) async{
      if(call.method == "showToast") {
        print("pxlosion");
        await _showToast(call.arguments);
      }
    });
  }

  static Future<void> _showToast(String text) async {
    showToast(text);
  }

  
  static Future<MethodChannelData> _callFunction(String function,[dynamic arguments]) async {
    final Map<String, dynamic> result = Map<String, dynamic>.from(await platform.invokeMethod(function,arguments));
    return MethodChannelData.fromMap(result);
  }


  static Future<MethodChannelData> makeWALCheckpoint() async {
    return await _callFunction("makeWALCheckpoint");
  }
  static Future<MethodChannelData> setMusicPackage(String package) async {
    return await _callFunction("setMusicPackage",{"package":package});
  }

  static Future<List<SongData>> getSongData() async {
    var data = await _callFunction("list");
    data.showErrorAsToastIfAvailable();
    if(data.hasError()) return List.empty();
    SongDataListM songDataListM = SongDataListM.fromBuffer(data.data??List.empty());

    List<SongData> songs = [];
    for(var value in songDataListM.songs) {
      songs.add(SongData(id: value.id.toInt(),
          artist: value.artist,
          title: value.title,
          album: value.album,
          albumAuthor: value.albumAuthor,
          progress: value.progress.toInt(),
          maxProgress: value.maxProgress.toInt(),
          startTime: DateTime.fromMillisecondsSinceEpoch(value.startTime.toInt()),
          endTime: DateTime.fromMillisecondsSinceEpoch(value.endTime.toInt()),
          timeListened: value.timeListened));
    }

    return songs;
  }

  static Future<SongData?> getCurrentSong() async {
    var data = await _callFunction("currentSong");
    if(data.hasError()) return null;

    SongDataM value = SongDataM.fromBuffer(data.data??List.empty());
    return SongData(id: value.id.toInt(),
        artist: value.artist,
        title: value.title,
        album: value.album,
        albumAuthor: value.albumAuthor,
        progress: value.progress.toInt(),
        maxProgress: value.maxProgress.toInt(),
        startTime: DateTime.fromMillisecondsSinceEpoch(value.startTime.toInt()),
        endTime: DateTime.fromMillisecondsSinceEpoch(value.endTime.toInt()),
        timeListened: value.timeListened);
  }

  static Future<MethodChannelData> launchNotificationAccess() async {
    return await _callFunction("launchNotificationAccess");
  }

  static Future<bool> isNotificationPermissionGranted() async {
    var data = await _callFunction("isNotificationGranted");
    data.showErrorAsToastIfAvailable();
    if(data.hasError()) return false;
    return data.data?.first == 1;
  }

  static Future<String> getMusicListenerServiceStatus() async {
    var data = await _callFunction("getMusicListenerServiceStatus");
    if(data.hasError()) return data.error??"";
    return String.fromCharCodes(data.data??List.empty());
  }

  static Future<MethodChannelData> startForegroundProcess() async {
    return await _callFunction("restartMusicListener");
  }
  static exportDatabase() async {
    var data = await _callFunction("exportDatabase");
    data.showErrorAsToastIfAvailable();
  }

  static importDatabase() async {
    var data = await _callFunction("importDatabase");
    data.showErrorAsToastIfAvailable();
  }
  static deleteEntry(int id) async {
    var data = await _callFunction("deleteEntry",{"id":"$id"});
    data.showErrorAsToastIfAvailable();
  }

  static backupDatabasePathPicker() async {
    var data = await _callFunction("backupDatabasePicker");
    data.showErrorAsToastIfAvailable();
  }
  static Future<String> getBackupDatabasePath() async {
    var data = await _callFunction("getBackupDatabasePath");
    if(data.hasError()) return data.error??"";
    return String.fromCharCodes(data.data??List.empty());
  }
  static Future<MethodChannelData> backupDatabaseNow() async {
    return await _callFunction("backupDatabaseNow");
  }

  static Future<MethodChannelData> getRequiredFieldsFor(String s) async{
    return await _callFunction("getRequiredFieldsFor$s");
  }

  static Future<bool> loginFor(String s, Map<String, String> p0) async{
    var data = await _callFunction("loginFor$s",{"fields":jsonEncode(p0)});
    if(data.hasError()) return false;
    return data.data?.first == 1;
  }
  static Future<bool> isLoggedInFor(String s) async{
    var data = await _callFunction("isLoggedInFor$s");
    if(data.hasError()) return false;
    return data.data?.first == 1;
  }
  static Future<int> cachedSongsFor(String s) async{
    var data = await _callFunction("cachedSongsFor$s");
    if(data.hasError()) return 0;
    int result = data.data!.fold(0, (prev, elem) => (prev << 8) | elem);
    return result;
  }
  static Future<void> logoutFor(String s) async{
    await _callFunction("logoutFor$s");
  }

}
