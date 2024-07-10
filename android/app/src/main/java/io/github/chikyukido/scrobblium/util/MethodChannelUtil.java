package io.github.chikyukido.scrobblium.util;

import android.content.ActivityNotFoundException;
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

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Set;

public class MethodChannelUtil {

    private static final HashMap<String, MethodInterface> methods = new HashMap<>();
    private static final HashMap<String, MethodInterfac> methods2 = new HashMap<>();
    private static final String TAG = "MethodChannelUtil";

    private static MethodChannel methodChannel;

    public static void configureMethodChannel(MethodChannel mc, Context context) {
        methodChannel = mc;
        methods.put("list", getSongList());
        methods.put("currentSong", getCurrentSong());
        methods.put("setMusicPackage", setPackage());
        methods.put("makeWALCheckpoint", makeWALCheckpoint());
        methods.put("launchNotificationAccess", launchNotificationAccess(context));
        methods.put("isNotificationGranted", hasNotificationPermission(context));
        methods.put("getMusicListenerServiceStatus", getMusicListenerServiceStatus());
        methods.put("startForegroundProcess", startForegroundProcess());
        methods.put("exportDatabase", exportDatabase(context));
        methods.put("importDatabase", importDatabase(context));
        methods.put("deleteEntry",deleteEntry());
        methods.put("backupDatabasePicker",backupDatabasePicker(context));
        methods.put("getBackupDatabasePath",getBackupDatabasePath(context));
        methods.put("backupDatabaseNow",backupDatabaseNow(context));
        methods.put("restartMusicListener",restartMusicListener());
        methods.put("exportMaloja",exportMaloja(context));
        IntegrationHandler.getInstance().addIntegrationsToMethodChannel(methods,methods2);

        methodChannel.setMethodCallHandler((call, result) -> {
            if (methods2.containsKey(call.method)) {
                Log.i("MethodChannelUtil", "Execute following command: " + call.method);
                MethodChannelData methodChannelData = new MethodChannelData(methodChannel);
                methodChannelData.setCallbackId(call.argument("callbackId"));
                new Thread(() -> methods2.get(call.method).run(methodChannelData)).start();
                result.success("");
            } else
            if (methods.containsKey(call.method)) {
                Log.i("MethodChannelUtil", "Execute following command: " + call.method);
                methods.get(call.method).run(call, result);
            } else {
                result.notImplemented();
            }
        });
    }

    private static MethodInterface exportMaloja(Context context) {
        return (call, result) -> {
            MethodChannelData methodChannelData = new MethodChannelData();
            ExportUtil.launchFileChooserForExportMaloja(context);
            result.success(methodChannelData.toMap());
        };
    }

    private static MethodInterface restartMusicListener() {
        return (call, result) -> {
            MethodChannelData methodChannelData = new MethodChannelData();
            if(MusicListenerService.getInstance() == null) {
                methodChannelData.setError("Music listener not initialized");
                result.success(methodChannelData.toMap());
                return;
            }
            MusicListenerService.getInstance().startForegroundService();
            result.success(methodChannelData.toMap());
        };
    }


    private static MethodInterface backupDatabaseNow(Context context) {
        return (call, result) -> {
            result.success(new MethodChannelData(BackupDatabaseUtil.backupDatabase(context),null).toMap());
        };
    }

    private static MethodInterface getBackupDatabasePath(Context context) {
        return (call, result) -> {
            MethodChannelData methodChannelData = new MethodChannelData();
            Uri u = BackupDatabaseUtil.readBackupDatabasePath(context);
            if(u == null) {
                methodChannelData.setError("No backup path set");
            }else {
                methodChannelData.setData(u.getPath().getBytes());
            }
            result.success(methodChannelData.toMap());
        };
    }

    private static MethodInterface backupDatabasePicker(Context context) {
        return (call, result) -> {
            BackupDatabaseUtil.launchFileChooserForBackup(context);
            result.success(new MethodChannelData().toMap());
        };
    }

    private static MethodInterface deleteEntry() {
        return (call, result) -> {
            MethodChannelData methodChannelData = new MethodChannelData();
            //Thread because can't execute a ddl in main thread
            Thread t = new Thread(() -> {
                if (MusicListenerService.getInstance() == null) {
                    methodChannelData.setError("Music listener service not initialized yet");
                    return;
                }
                String argument = call.argument("id");
                if(argument == null) {
                    methodChannelData.setError("No argument provide for delete Entry");
                    return;
                };
                int id = Integer.parseInt(argument);
                MusicListenerService.getInstance().getDatabase().musicTrackDao().deleteTrack(id);
            });
            try {
                t.start();
                t.join();
            } catch (InterruptedException e) {
                methodChannelData.setError("Smth went wrong deleting the entry. Check logs for more infos");
                Log.e(TAG, "deleteEntry: ", e);
            }
            result.success(methodChannelData.toMap());
        };
    }


    private static MethodInterface getSongList() {
        return (call, result) -> new Thread(() -> {
            MethodChannelData methodChannelData = new MethodChannelData();
            if (MusicListenerService.getInstance() == null || MusicListenerService.getInstance().getDatabase() == null) {
                methodChannelData.setError("Could not get Songs because the service is not running");
                result.success(methodChannelData.toMap());
                return;
            }

            List<SongData> tracks = MusicListenerService.getInstance().getDatabase().musicTrackDao().getAllTracks();
            SongDataListM.Builder songDataListBuilder = SongDataListM.newBuilder();

            for (SongData song : tracks) {
                songDataListBuilder.addSongs(Converter.songDataToMessage(song));
            }
            methodChannelData.setData(songDataListBuilder.build().toByteArray());
            result.success(methodChannelData.toMap());
        }).start();
    }

    private static MethodInterface getCurrentSong() {
        return (call, result) -> {
            MethodChannelData methodChannelData = new MethodChannelData();
            if (MusicListenerService.getInstance() == null || MusicListenerService.getInstance().getDatabase() == null) {
                methodChannelData.setError("Could not get current song because the service is not running");
                result.success(methodChannelData.toMap());
                return;
            }
            if(MusicListenerService.getInstance().getCurrentSong().getMaxProgress() == -1) {
                methodChannelData.setError("Could not get current Song because no song was started");
                result.success(methodChannelData.toMap());
                return;
            }
            methodChannelData.setData(Converter.songDataToMessage(MusicListenerService.getInstance().getCurrentSong()).toByteArray());
            result.success(methodChannelData.toMap());
        };
    }

    private static MethodInterface setPackage() {
        return (call, result) -> {
            MethodChannelData methodChannelData = new MethodChannelData();
            if (MusicListenerService.getInstance() == null) {
                methodChannelData.setError("Music listener service not initialized yet");
                result.success(methodChannelData.toMap());
                return;
            }
            String argument = call.argument("package");
            MusicListenerService.getInstance().setMusicPackage(argument);
            result.success(methodChannelData.toMap());
        };
    }

    private static MethodInterface makeWALCheckpoint() {
        return (call, result) -> {
            MethodChannelData methodChannelData = new MethodChannelData();
            if (MusicListenerService.getInstance() == null) {
                methodChannelData.setError("Music listener service not initialized yet");
                result.success(methodChannelData.toMap());
                return;
            };
            if (MusicListenerService.getInstance().getDatabase() != null) {
                MusicListenerService.getInstance().getDatabase().close();
            }
            MusicListenerService.getInstance().connectToDatabase();
            Log.i("MethodChannelUtil", "makeWALCheckpoint: checkpoint for database");
            result.success(methodChannelData.toMap());
        };
    }

    private static MethodInterface launchNotificationAccess(Context context) {
        return (call, result) -> {
            MethodChannelData methodChannelData = new MethodChannelData();
            try {
                Intent intent = new Intent();
                intent.setAction("android.settings.ACTION_NOTIFICATION_LISTENER_SETTINGS");
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                context.startActivity(intent);
            }catch (ActivityNotFoundException e) {
                methodChannelData.setError(e.getMessage());
            }
            result.success(methodChannelData.toMap());
        };
    }

    private static MethodInterface hasNotificationPermission(Context context) {
        return (call, result) -> {
            MethodChannelData methodChannelData = new MethodChannelData();
            Set<String> enabledListenerPackages = NotificationManagerCompat.getEnabledListenerPackages(context);
            methodChannelData.setData(new byte[]{(byte) (enabledListenerPackages.contains(context.getPackageName()) ? 1: 0)});
            result.success(methodChannelData.toMap());
        };
    }

    private static MethodInterface getMusicListenerServiceStatus() {
        return (call, result) -> {
            result.success( new MethodChannelData(null,MusicListenerService.status.toString().getBytes()).toMap());
        };
    }

    private static MethodInterface startForegroundProcess() {
        return (call, result) -> {
            MethodChannelData methodChannelData = new MethodChannelData();
            if (MusicListenerService.getInstance() == null) {
                methodChannelData.setError("Music listener service not initialized yet");
                result.success(methodChannelData.toMap());
                return;
            };
            MusicListenerService.getInstance().startForegroundService();
            result.success(methodChannelData.toMap());
        };
    }

    private static MethodInterface exportDatabase(Context context) {
        return (call, result) -> {
            BackupDatabaseUtil.launchDirectoryChooserForExport(context);
            result.success(new MethodChannelData().toMap());
        };
    }

    private static MethodInterface importDatabase(Context context) {
        return (call, result) -> {
            BackupDatabaseUtil.launchFileChooserForImport(context);
            result.success(new MethodChannelData().toMap());
        };
    }

    public static void showToast(String text) {
        if(methodChannel != null) {
            methodChannel.invokeMethod("showToast",text);
        }
    }

    public interface MethodInterface {
        void run(MethodCall call, MethodChannel.Result result);
    }
    public interface MethodInterfac {
        void run(MethodChannelData data);
    }
}
