package io.github.chikyukido.scrobblium;

import android.app.ActivityManager;
import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.content.Context;
import android.graphics.Bitmap;
import android.media.MediaMetadata;
import android.media.session.MediaController;
import android.media.session.MediaSession;
import android.media.session.PlaybackState;
import android.service.notification.NotificationListenerService;
import android.service.notification.StatusBarNotification;
import android.util.Log;
import androidx.core.app.NotificationCompat;
import androidx.core.app.NotificationManagerCompat;
import androidx.room.Room;
import io.github.chikyukido.scrobblium.database.SongData;
import io.github.chikyukido.scrobblium.database.SongDatabase;
import io.github.chikyukido.scrobblium.util.BitmapUtil;
import io.github.chikyukido.scrobblium.util.ConfigUtil;

import java.nio.file.Files;
import java.nio.file.Paths;
import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.Set;
import java.util.Timer;
import java.util.TimerTask;

public class MusicListenerService extends NotificationListenerService {
    public static MusicListenerServiceStatus status = MusicListenerServiceStatus.NOT_INITIALIZED;
    private static MusicListenerService INSTANCE = null;

    private final String TAG = "MusicListenerService";
    private String musicPackageName = "";

    private SongDatabase database;
    private SongData currentSong = new SongData("", "", "", "", -1L, -1L, LocalDateTime.MIN,
            LocalDateTime.MIN, -1);
    private MediaController currentMediaController;
    private Timer timer;

    public static MusicListenerService getInstance() {
        return INSTANCE;
    }

    @Override
    public void onCreate() {
        super.onCreate();
        INSTANCE = this;
        connectToDatabase();
        startForegroundService();

    }

    public void connectToDatabase() {
        database = Room.databaseBuilder(
                getApplicationContext(),
                SongDatabase.class,
                "song_database"
        ).build();
    }

    public void setMusicPackage(String musicPackage) {
        musicPackageName = musicPackage;
        INSTANCE.startTimer();
        Log.i(TAG, "setMusicPackage: new package " + INSTANCE);
    }

    public void startForegroundService() {
        musicPackageName = ConfigUtil.getMusicPackage(getBaseContext());
        if (musicPackageName == null || musicPackageName.isEmpty()) {
            Log.i(TAG, "onCreate: Do not start MusicListener service cause there is no MusicPackage");
            status = MusicListenerServiceStatus.NO_PACKAGE;
            return;
        }
        if (!isPermissionGranted()) {
            status = MusicListenerServiceStatus.NO_PERMISSION;
            return;
        }
        if (!isServiceRunning(this.getClass())) {
            String channelID = "MusicListenerServiceChannel";
            NotificationChannel channel = new NotificationChannel(channelID,
                    "Music Listener Service",
                    NotificationManager.IMPORTANCE_DEFAULT);
            NotificationManager manager = getSystemService(NotificationManager.class);
            manager.createNotificationChannel(channel);
            Notification notification = new NotificationCompat.Builder(this, channelID).build();
            int NOTIFICATION_ID = 1956;
            startForeground(NOTIFICATION_ID, notification);
        }
        if (status != MusicListenerServiceStatus.TRACKING) startTimer();
    }

    private void startTimer() {
        if (timer != null) {
            Log.i(TAG, "startTimer: Timer is already active");
            return;
        }
        Log.i(TAG, "startTimer: Timer started");
        status = MusicListenerServiceStatus.TRACKING;
        timer = new Timer();
        timer.scheduleAtFixedRate(new TimerTask() {
            @Override
            public void run() {
                fetchActiveNotifications();
            }
        }, 5000, 1000);

    }

    private void stopTimer() {
        if (timer != null) {
            status = MusicListenerServiceStatus.PAUSED;
            Log.i(TAG, "stopTimer: Timer stopped");
            timer.cancel();
            timer = null;
        } else {
            Log.i(TAG, "stopTimer: Timer is not active");
        }
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        database.close();
        stopTimer();
    }

    private StatusBarNotification getMusicNotification() {
        try {
            return Arrays.stream(getActiveNotifications())
                    .filter(sbn -> sbn.getPackageName().equals(musicPackageName))
                    .findFirst().orElse(null);
        } catch (SecurityException e) {
            Log.w(TAG, "getMusicNotification: Could not get Music-notification because a security issue." +
                    " This shouldn't be a issue this occurs on the app startup");
            return null;
        }
    }

    private void fetchActiveNotifications() {
        StatusBarNotification sbn = getMusicNotification();
        if (sbn == null) {
            return;
        }
        if (currentMediaController == null || currentMediaController.getPlaybackState() == null) {
            Log.i(TAG, "fetchActiveNotifications: Current media controller is null. Retrieving from the notification.");
            currentMediaController = getMediaControllerFromNotification(sbn);
            if (currentMediaController == null) {
                Log.e(TAG, "fetchActiveNotifications: Could not get MediaController from notification: " + sbn.getNotification().toString());
                return;
            }
        }
        if (currentSong.getTimeListened() == -1) {
            currentSong = SongData.of(currentMediaController);
            saveArt();
        }
        if (isSameSong()) {
            if (currentMediaController.getPlaybackState() != null && currentMediaController.getPlaybackState().getState() == PlaybackState.STATE_PLAYING) {
                currentSong.incrementTimeListened();
                currentSong.setProgress(currentMediaController.getPlaybackState().getPosition());
            }
        } else {
            currentSong.setEndTime(LocalDateTime.now());
            if (database.isOpen())
                database.musicTrackDao().insertTrack(currentSong);
            currentSong = SongData.of(currentMediaController);
            saveArt();
            Log.i(TAG, "fetchActiveNotifications: New song detected.");
        }
    }

    private boolean isSameSong() {
        MediaMetadata metadata = currentMediaController.getMetadata();
        if (metadata == null) return false;
        String artist = metadata.getString(MediaMetadata.METADATA_KEY_ARTIST);
        String title = metadata.getString(MediaMetadata.METADATA_KEY_TITLE);
        String album = metadata.getString(MediaMetadata.METADATA_KEY_ALBUM);
        return currentSong.getIdentifier().equals(artist + "," + title + "," + album);
    }

    private MediaController getMediaControllerFromNotification(StatusBarNotification sbn) {
        MediaSession.Token mediaSessionToken = sbn.getNotification().extras.getParcelable("android.mediaSession");
        if (mediaSessionToken == null) return null;
        return new MediaController(getApplicationContext(), mediaSessionToken);
    }

    private void saveArt() {
        String filename = currentSong.getIdentifier() + ".png";
        MediaMetadata metadata = currentMediaController.getMetadata();
        if (metadata == null) return;
        Bitmap bitmap = metadata.getBitmap(MediaMetadata.METADATA_KEY_ART);
        if (bitmap == null) bitmap = metadata.getBitmap(MediaMetadata.METADATA_KEY_ALBUM_ART);
        if (!Files.exists(Paths.get(getBaseContext().getFilesDir().toString()).resolve(filename))) {
            BitmapUtil.saveBitmapAsPNG(getBaseContext(), bitmap, filename);
        }
    }


    public SongDatabase getDatabase() {
        return database;
    }

    public SongData getCurrentSong() {
        return currentSong;
    }

    private boolean isPermissionGranted() {
        Set<String> enabledListenerPackages = NotificationManagerCompat.getEnabledListenerPackages(getBaseContext());
        return enabledListenerPackages.contains(getBaseContext().getPackageName());
    }

    private boolean isServiceRunning(Class<?> serviceClass) {
        ActivityManager manager = (ActivityManager) getSystemService(Context.ACTIVITY_SERVICE);
        for (ActivityManager.RunningServiceInfo service : manager.getRunningServices(Integer.MAX_VALUE)) {
            if (serviceClass.getName().equals(service.service.getClassName())) {
                return true;
            }
        }
        return false;
    }

    public enum MusicListenerServiceStatus {
        NOT_INITIALIZED,
        NO_PACKAGE,
        NO_PERMISSION,
        TRACKING,
        PAUSED,
    }
}
