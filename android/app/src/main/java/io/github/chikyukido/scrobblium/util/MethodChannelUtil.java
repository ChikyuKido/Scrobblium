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
import io.github.chikyukido.scrobblium.database.SongData;

import java.time.LocalDateTime;
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
        methodChannel.setMethodCallHandler((call, result) -> {
            if (methods.containsKey(call.method)) {
                Log.i("MethodChannelUtil", "Execute following command: " + call.method);
                methods.get(call.method).run(call, result);
            } else {
                result.notImplemented();
            }
        });
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
            if (MusicListenerService.getInstance() == null || MusicListenerService.getInstance().getDatabase() == null) {
                result.success("[]");
                return;
            }
            List<SongData> tracks = MusicListenerService.getInstance().getDatabase().musicTrackDao().getAllTracks();
            String json = gson.toJson(tracks);
            result.success(json);
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

    private interface MethodInterface {
        void run(MethodCall call, MethodChannel.Result result);
    }
}
