package io.github.chikyukido.scrobblium.util;

import android.content.ActivityNotFoundException;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.util.Log;
import androidx.core.app.NotificationManagerCompat;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.github.chikyukido.scrobblium.MainActivity;
import io.github.chikyukido.scrobblium.MusicListenerService;
import io.github.chikyukido.scrobblium.dao.MethodChannelData;
import io.github.chikyukido.scrobblium.database.SongData;
import io.github.chikyukido.scrobblium.intergrations.IntegrationHandler;
import io.github.chikyukido.scrobblium.messages.SongDataListM;
import io.github.chikyukido.scrobblium.messages.SongDataM;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Set;

public class MethodChannelUtil {

    private static final HashMap<String, MethodInterface> methods = new HashMap<>();
    private static final String TAG = "MethodChannelUtil";

    private static MethodChannel methodChannel;

    public static void configureMethodChannel(MethodChannel mc, Context context) {
        methodChannel = mc;
        methods.put("getSongList", getSongList());
        methods.put("getCurrentSong", getCurrentSong());
        methods.put("setMusicPackage", setPackage());
        methods.put("makeWALCheckpoint", makeWALCheckpoint());
        methods.put("launchNotificationAccess", launchNotificationAccess(context));
        methods.put("isNotificationPermissionGranted", hasNotificationPermission(context));
        methods.put("getMusicListenerServiceStatus", getMusicListenerServiceStatus());
        methods.put("startForegroundProcess", startForegroundProcess());
        methods.put("exportDatabase", exportDatabase(context));
        methods.put("importDatabase", importDatabase(context));
        methods.put("deleteEntry",deleteEntry());
        methods.put("backupDatabasePicker",backupDatabasePicker(context));
        methods.put("getBackupDatabasePath",getBackupDatabasePath(context));
        methods.put("backupDatabaseNow",backupDatabaseNow(context));
        methods.put("restartMusicListenerService",restartMusicListener());
        methods.put("exportMaloja",exportMaloja(context));
        methods.put("exportListenBrainz",exportListenBrainz(context));
        IntegrationHandler.getInstance().addIntegrationsToMethodChannel(methods,context);

        methodChannel.setMethodCallHandler((call, result) -> {
            if (methods.containsKey(call.method)) {
                if(!call.hasArgument("callbackId")) {
                    result.notImplemented();
                    return;
                }
                int callbackId = call.argument("callbackId");
                Log.i(TAG, "Execute following command: " + call.method +" with the callback id: " + callbackId);
                MethodChannelData methodChannelData = new MethodChannelData(methodChannel);
                methodChannelData.setCallbackId(callbackId);
                new Thread(() -> methods.get(call.method).run(methodChannelData,call)).start();
                result.success("");
            } else {
                result.notImplemented();
            }
        });
    }

    private static MethodInterface exportMaloja(Context context) {
        return (data, call) -> ExportUtil.launchFileChooserForExportMaloja(context,data);
    }
    private static MethodInterface exportListenBrainz(Context context) {
        return (data, call) -> ExportUtil.launchFileChooserForExportListenBrainz(context,data);
    }

    private static MethodInterface restartMusicListener() {
        return (data, call) -> {
            if(MusicListenerService.getInstance() == null) {
                data.setError("Music listener not initialized");
                data.reply();
                return;
            }
            MusicListenerService.getInstance().startForegroundService();
            data.reply();
        };
    }


    private static MethodInterface backupDatabaseNow(Context context) {
        return (data, call) -> {
            data.setError(BackupDatabaseUtil.backupDatabase(context));
            data.reply();
        };
    }

    private static MethodInterface getBackupDatabasePath(Context context) {
        return (data, call) -> {
            Uri u = BackupDatabaseUtil.readBackupDatabasePath(context);
            if(u == null) {
                data.setError("No backup path set");
            }else {
                data.setData(u.getPath().getBytes());
            }
            data.reply();
        };
    }

    private static MethodInterface backupDatabasePicker(Context context) {
        return (data, call) -> BackupDatabaseUtil.launchFileChooserForBackup(context,data);
    }

    private static MethodInterface deleteEntry() {
        return (data, call) -> new Thread(() -> {
            if (MusicListenerService.getInstance() == null) {
                data.setError("Music listener service not initialized yet");
                return;
            }
            String argument = call.argument("id");
            if(argument == null) {
                data.setError("No argument provide for delete Entry");
                return;
            }
            int id = Integer.parseInt(argument);
            MusicListenerService.getInstance().getDatabase().musicTrackDao().deleteTrack(id);

            data.reply();
        }).start();
    }


    private static MethodInterface getSongList() {
        return (data, call) -> new Thread(() -> {
            if (MusicListenerService.getInstance() == null || MusicListenerService.getInstance().getDatabase() == null) {
                data.setError("Could not get Songs because the service is not running");
                data.reply();
                return;
            }

            List<SongData> tracks = MusicListenerService.getInstance().getDatabase().musicTrackDao().getAllTracks();

            List<SongDataM> out = new ArrayList<>(tracks.size());
            for (SongData song : tracks) {
                out.add(Converter.songDataToMessage(song));
            }
            SongDataListM msg = SongDataListM.newBuilder()
                    .addAllSongs(out)
                    .build();
            data.setData(msg.toByteArray());
            data.reply();
        }).start();
    }

    private static MethodInterface getCurrentSong() {
        return (data, result) -> {
            if (MusicListenerService.getInstance() == null || MusicListenerService.getInstance().getDatabase() == null) {
                data.setError("Could not get current song because the service is not running");
                data.reply();
                return;
            }
            if(MusicListenerService.getInstance().getCurrentSong().getMaxProgress() == -1) {
                data.setError("Could not get current Song because no song was started");
                data.reply();
                return;
            }
            data.setData(Converter.songDataToMessage(MusicListenerService.getInstance().getCurrentSong()).toByteArray());
            data.reply();
        };
    }

    private static MethodInterface setPackage() {
        return (data,call) -> {
            if (MusicListenerService.getInstance() == null) {
                data.setError("Music listener service not initialized yet");
                data.reply();
                return;
            }
            String argument = call.argument("package");
            MusicListenerService.getInstance().setMusicPackage(argument);
            data.setDataAsString("Successfully set music package to "+argument);
            data.reply();
        };
    }

    private static MethodInterface makeWALCheckpoint() {
        return (data,call) -> {
            if (MusicListenerService.getInstance() == null) {
                data.setError("Music listener service not initialized yet");
                data.reply();
                return;
            }
            if (MusicListenerService.getInstance().getDatabase() != null) {
                MusicListenerService.getInstance().getDatabase().close();
            }
            MusicListenerService.getInstance().connectToDatabase();
            Log.i("MethodChannelUtil", "makeWALCheckpoint: checkpoint for database");
            data.setDataAsString("Successfully created a wal checkpoint");
            data.reply();
        };
    }

    private static MethodInterface launchNotificationAccess(Context context) {
        return (data, call) -> {
            try {
                MainActivity.resumeCallbacks.add(data);
                Intent intent = new Intent();
                intent.setAction("android.settings.ACTION_NOTIFICATION_LISTENER_SETTINGS");
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                context.startActivity(intent);
            }catch (ActivityNotFoundException e) {
                data.setError(e.getMessage());
                data.reply();
            }
        };
    }

    private static MethodInterface hasNotificationPermission(Context context) {
        return (data, call) -> {
            Set<String> enabledListenerPackages = NotificationManagerCompat.getEnabledListenerPackages(context);
            data.setData(new byte[]{(byte) (enabledListenerPackages.contains(context.getPackageName()) ? 1: 0)});
            data.reply();
        };
    }

    private static MethodInterface getMusicListenerServiceStatus() {
        return (data, call) -> {
            data.setData(MusicListenerService.status.toString().getBytes());
            data.reply();
        };
    }

    private static MethodInterface startForegroundProcess() {
        return (data, call) -> {
            if (MusicListenerService.getInstance() == null) {
                data.setError("Music listener service not initialized yet");
                data.reply();
                return;
            }
            MusicListenerService.getInstance().startForegroundService();
            data.reply();
        };
    }

    private static MethodInterface exportDatabase(Context context) {
        return (data, call) -> {
            BackupDatabaseUtil.launchDirectoryChooserForExport(context,data);
        };
    }

    private static MethodInterface importDatabase(Context context) {
        return (data, call) -> {
            BackupDatabaseUtil.launchFileChooserForImport(context,data);
        };
    }

    public static void showToast(String text) {
        if(methodChannel != null) {
            methodChannel.invokeMethod("showToast",text);
        }
    }

    public interface MethodInterface {
        void run(MethodChannelData data,MethodCall call);
    }
}
