import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import 'package:scrobblium/dao/method_channel_data.dart';
import 'package:scrobblium/dao/song_data.dart';
import 'package:scrobblium/messages/proto/song_datam.pb.dart';
import 'package:scrobblium/util/widget_util.dart';

// method_channel_methods.dart
const MAKE_WAL_CHECKPOINT = "makeWALCheckpoint";
const SET_MUSIC_PACKAGE = "setMusicPackage";
const GET_SONG_LIST = "getSongList";
const GET_CURRENT_SONG = "getCurrentSong";
const LAUNCH_NOTIFICATION_ACCESS = "launchNotificationAccess";
const IS_NOTIFICATION_PERMISSION_GRANTED = "isNotificationPermissionGranted";
const GET_MUSIC_LISTENER_SERVICE_STATUS = "getMusicListenerServiceStatus";
const RESTART_MUSIC_LISTENER_SERVICE = "restartMusicListenerService";
const EXPORT_DATABASE = "exportDatabase";
const IMPORT_DATABASE = "importDatabase";
const DELETE_ENTRY = "deleteEntry";
const BACKUP_DATABASE_PICKER = "backupDatabasePicker";
const GET_BACKUP_DATABASE_PATH = "getBackupDatabasePath";
const BACKUP_DATABASE_NOW = "backupDatabaseNow";
const GET_INTEGRATIONS = "getIntegrations";
const ADD_INTEGRATION = "addIntegration";
const EXPORT_MALOJA = "exportMaloja";
const EXPORT_LISTEN_BRAINZ = "exportListenBrainz";
const CHECK_CONDITIONAL_UPLOAD = "checkConditionalUpload";

String GET_REQUIRED_FIELDS_FOR(String integration) => "getRequiredFieldsFor$integration";
String LOGIN_FOR(String integration) => "loginFor$integration";
String IS_LOGGED_IN_FOR(String integration) => "isLoggedInFor$integration";
String GET_CACHED_SONGS_FOR(String integration) => "getCachedSongsFor$integration";
String LOGOUT_FOR(String integration) => "logoutFor$integration";
String UPLOAD_CACHED_SONGS_FOR(String integration) => "uploadCachedSongsFor$integration";
String GET_INTEGRATION_INFORMATIONS_FOR(String integration) => "getIntegrationInfoFor$integration";


class MethodChannelService {

  static final log = Logger("MethodChannelService");
  static const platform = MethodChannel('MusicListener');
  static Map<int,Completer> futures = {};
  static Map<int, DateTime> startTimes = {};
  static int futureId = 0;
  
  static init() {
    platform.setMethodCallHandler((call) async{
      if(call.method == "showToast") {
        await _showToast(call.arguments);
      }else if(call.method == "reply") {
        final Map<String, dynamic> resultMap = Map<String, dynamic>.from(call.arguments);
        final int id = resultMap["callbackId"];
        final start = startTimes[id];
        if (start != null) {
          final duration = DateTime.now().difference(start).inMilliseconds;
          log.info("Reply from callback $id took $duration ms");
          startTimes.remove(id);
        } else {
          log.info("Reply from callback $id");
        }
        if(futures[id] == null) {
          return;
        }
        futures[id]?.complete(MethodChannelData.fromMap(resultMap));
        futures.remove(id);
      }
    });
  }

  static Future<void> _showToast(String text) async {
    WidgetUtil.showToast(text);
  }

  static Future<MethodChannelData> callFunction(String function,[Map<String,dynamic>? arguments]) async {
    Completer<MethodChannelData> completer = Completer<MethodChannelData>();
    if (arguments == null) {
      arguments = {"callbackId" : futureId};
    }else {
      arguments["callbackId"] = futureId;
    }
    platform.invokeMethod(function,arguments);
    final currentId = futureId;
    futures[currentId] = completer;
    startTimes[currentId] = DateTime.now();
    futureId++;
    return completer.future;
  }

  static Future<MethodChannelData> setMusicPackage(String package) async {
    return callFunction(SET_MUSIC_PACKAGE,{"package":package});
  }

  static Future<List<SongData>> getSongData() async {
    var data = await callFunction(GET_SONG_LIST);
    if(data.hasError()) return List.empty();
    SongDataListM songDataListM = SongDataListM.fromBuffer(data.data??List.empty());
    final songs = List<SongData>.generate(songDataListM.songs.length, (i) {
      final v = songDataListM.songs[i];
      return SongData(
        id: v.id,
        artist: v.artist,
        title: v.title,
        album: v.album,
        albumAuthor: v.albumAuthor,
        progress: v.progress,
        maxProgress: v.maxProgress,
        startTime: DateTime.fromMillisecondsSinceEpoch(v.startTime.toInt()),
        endTime: DateTime.fromMillisecondsSinceEpoch(v.endTime.toInt()),
        timeListened: v.timeListened,
      );
    }, growable: false);
    return songs;
  }

  static Future<SongData?> getCurrentSong() async {
    var data = await callFunction(GET_CURRENT_SONG);
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

  static Future<MethodChannelData> deleteEntry(int id) {
    return callFunction(DELETE_ENTRY,{"id":"$id"});
  }

  static Future<String> getBackupDatabasePath() async {
    var data = await callFunction(GET_BACKUP_DATABASE_PATH);
    if(data.hasError()) return data.error??"";
    return String.fromCharCodes(data.data??List.empty());
  }

  static Future<MethodChannelData> loginFor(String s, Map<String, String> p0) {
    return callFunction(LOGIN_FOR(s),{"fields":jsonEncode(p0)});
  }
}
