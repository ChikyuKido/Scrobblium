import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:scrobblium/service/song_provider_service.dart';


exportDatabase() async{
  await SongProviderService.exportDatabase();

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
