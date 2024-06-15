package io.github.chikyukido.scrobblium.util;

import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.util.Log;
import androidx.core.app.NotificationManagerCompat;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.JsonPrimitive;
import com.google.gson.JsonSerializer;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.github.chikyukido.scrobblium.MusicListenerService;
import io.github.chikyukido.scrobblium.dao.MethodChannelData;
import io.github.chikyukido.scrobblium.database.SongData;
import io.github.chikyukido.scrobblium.intergrations.IntegrationHandler;
import io.github.chikyukido.scrobblium.messages.SongDataListM;
import io.github.chikyukido.scrobblium.messages.SongDataM;

import java.time.LocalDateTime;
import java.time.ZoneOffset;
import java.util.HashMap;
import java.util.List;
import java.util.Set;

public class MethodChannelUtil {

    private static final HashMap<String, MethodInterface> methods = new HashMap<>();
    private static Gson gson = new Gson();

    public static void configureMethodChannel(MethodChannel methodChannel, Context context) {
        gson = new GsonBuilder().registerTypeAdapter(LocalDateTime.class,
                (JsonSerializer<LocalDateTime>) (src, typeOfSrc, context1) -> new JsonPrimitive(src.toString())).create();
        methods.put("list", getSongList());
        methods.put("currentSong", getCurrentSong());
        methods.put("setMusicPackage", setPackage());
        methods.put("makeWALCheckpoint", makeWALCheckpoint());
        methods.put("launchNotificationAccess", launchNotificationAccess(context));
        methods.put("isNotificationGranted", isNotificationPermission(context));
        methods.put("getMusicListenerServiceStatus", getMusicListenerServiceStatus());
        methods.put("startForegroundProcess", startForegroundProcess());
        methods.put("exportDatabase", exportDatabase(context));
        methods.put("importDatabase", importDatabase(context));
        methods.put("deleteEntry",deleteEntry());
        methods.put("backupDatabasePicker",backupDatabasePicker(context));
        methods.put("getBackupDatabasePath",getBackupDatabasePath(context));
        methods.put("backupDatabaseNow",backupDatabaseNow(context));
        IntegrationHandler.getInstance().addIntegrationsToMethodChannel(methods);

        methodChannel.setMethodCallHandler((call, result) -> {
            if (methods.containsKey(call.method)) {
                Log.i("MethodChannelUtil", "Execute following command: " + call.method);
                methods.get(call.method).run(call, result);
            } else {
                result.notImplemented();
            }
        });
    }


    private static MethodInterface backupDatabaseNow(Context context) {
        return (call, result) -> {
            result.success(new MethodChannelData(BackupDatabaseUtil.backupDatabase(context),null).toMap());
        };
    }



    private static MethodInterface getBackupDatabasePath(Context context) {
        return (call, result) -> {
            Uri u = BackupDatabaseUtil.readBackupDatabasePath(context);
            result.success(u == null ? "" : u.getPath());
        };
    }

    private static MethodInterface backupDatabasePicker(Context context) {
        return (call, result) -> {
            BackupDatabaseUtil.launchFileChooserForBackup(context);
            result.success(null);
        };
    }

    private static MethodInterface deleteEntry() {
        return (call, result) -> new Thread(() -> {
            if (MusicListenerService.getInstance() == null) return;
            String argument = call.argument("id");
            if(argument == null) return;
            int id = Integer.parseInt(argument);
            MusicListenerService.getInstance().getDatabase().musicTrackDao().deleteTrack(id);
        }).start();
    }


    private static MethodInterface getSongList() {
        return (call, result) -> new Thread(() -> {
            MethodChannelData methodChannelData = new MethodChannelData();
            if (MusicListenerService.getInstance() == null || MusicListenerService.getInstance().getDatabase() == null) {
                methodChannelData.setError("Could not get Songs because the service is not running");
            }

            long start = System.currentTimeMillis();
            List<SongData> tracks = MusicListenerService.getInstance().getDatabase().musicTrackDao().getAllTracks();

            Log.i("test", "getSongList: database"+(System.currentTimeMillis() - start));
            start = System.currentTimeMillis();
            SongDataListM.Builder songDataListBuilder = SongDataListM.newBuilder();

            for (SongData song : tracks) {
                SongDataM.Builder songBuilder = SongDataM.newBuilder()
                        .setId(song.getId())
                        .setArtist(song.getArtist())
                        .setTitle(song.getTitle())
                        .setAlbum(song.getAlbum())
                        .setAlbumAuthor(song.getAlbumAuthor() != null ? song.getAlbumAuthor() : "")
                        .setMaxProgress(song.getMaxProgress())
                        .setStartTime(song.getStartTime().atZone(ZoneOffset.UTC).toInstant().toEpochMilli())
                        .setProgress(song.getProgress())
                        .setEndTime(song.getEndTime().atZone(ZoneOffset.UTC).toInstant().toEpochMilli())
                        .setTimeListened(song.getTimeListened());

                songDataListBuilder.addSongs(songBuilder.build());
            }
            Log.i("test", "getSongList: created data"+(System.currentTimeMillis() - start));
            start = System.currentTimeMillis();
            methodChannelData.setData(songDataListBuilder.build().toByteArray());
            Log.i("test", "getSongList: converted data"+(System.currentTimeMillis() - start));
            result.success(methodChannelData.toMap());
        }).start();
    }

    private static MethodInterface getCurrentSong() {
        return (call, result) -> {
            if (MusicListenerService.getInstance() == null || MusicListenerService.getInstance().getDatabase() == null
                    || MusicListenerService.getInstance().getCurrentSong().getMaxProgress() == -1) {
                result.success("[]");
                return;
            }
            result.success(gson.toJson(MusicListenerService.getInstance().getCurrentSong()));
        };
    }

    private static MethodInterface setPackage() {
        return (call, result) -> {
            if (MusicListenerService.getInstance() == null) return;
            String argument = call.argument("package");
            MusicListenerService.getInstance().setMusicPackage(argument);
            result.success(null);
        };
    }

    private static MethodInterface makeWALCheckpoint() {
        return (call, result) -> {
            if (MusicListenerService.getInstance() == null) return;
            if (MusicListenerService.getInstance().getDatabase() != null) {
                MusicListenerService.getInstance().getDatabase().close();
            }
            MusicListenerService.getInstance().connectToDatabase();
            Log.i("MainActivity", "configureFlutterEngine: checkpoint for database");
            result.success(null);
        };
    }

    private static MethodInterface launchNotificationAccess(Context context) {
        return (call, result) -> {
            Intent intent = new Intent();
            intent.setAction("android.settings.ACTION_NOTIFICATION_LISTENER_SETTINGS");
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            context.startActivity(intent);
            result.success(null);
        };
    }

    private static MethodInterface isNotificationPermission(Context context) {
        return (call, result) -> {
            Set<String> enabledListenerPackages = NotificationManagerCompat.getEnabledListenerPackages(context);
            result.success(String.valueOf(enabledListenerPackages.contains(context.getPackageName())));
        };
    }

    private static MethodInterface getMusicListenerServiceStatus() {
        return (call, result) -> result.success(MusicListenerService.status.toString());
    }

    private static MethodInterface startForegroundProcess() {
        return (call, result) -> {
            if (MusicListenerService.getInstance() == null) return;
            MusicListenerService.getInstance().startForegroundService();
            result.success(null);
        };
    }

    private static MethodInterface exportDatabase(Context context) {
        return (call, result) -> {
            BackupDatabaseUtil.launchDirectoryChooserForExport(context);
            result.success(null);
        };
    }

    private static MethodInterface importDatabase(Context context) {
        return (call, result) -> {
            BackupDatabaseUtil.launchFileChooserForImport(context);
            result.success(null);
        };
    }

    public interface MethodInterface {
        void run(MethodCall call, MethodChannel.Result result);
    }
}
