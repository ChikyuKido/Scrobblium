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
import io.github.chikyukido.scrobblium.intergrations.IntegrationHandler;
import io.github.chikyukido.scrobblium.util.BackupDatabaseUtil;
import io.github.chikyukido.scrobblium.util.BitmapUtil;
import io.github.chikyukido.scrobblium.util.ConfigUtil;

import java.nio.file.Files;
import java.nio.file.Paths;
import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.List;
import java.util.Set;
import java.util.Timer;
import java.util.TimerTask;
import java.util.concurrent.Executor;
import java.util.concurrent.Executors;

public class MusicListenerService extends NotificationListenerService {
    public static MusicListenerServiceStatus status = MusicListenerServiceStatus.NOT_INITIALIZED;
    private static MusicListenerService INSTANCE = null;

    private static final String CHANNEL_ID = "MusicListenerServiceChannel";
    private static final int NOTIFICATION_ID = 1956;
    private static final String TAG = "MusicListenerService";

    private final Executor executor = Executors.newSingleThreadExecutor();

    private int lastBackupTime;
    private String musicPackageName = "";

    private boolean showNotificationStatus = false;
    private StatusBarNotification currentNotification;
    private NotificationManager notificationManager;

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
        //set it to zero so every time it starts it also makes a backup
        lastBackupTime = 0;
        connectToDatabase();
        startForegroundService();

    }

    public void connectToDatabase() {
        if(database != null) database.close();
        database = Room.databaseBuilder(
                getApplicationContext(),
                SongDatabase.class,
                "song_database"
        ).build();
    }

    @Override
    public void onNotificationPosted(StatusBarNotification sbn) {
        if(sbn.getPackageName().equals(musicPackageName)) {
            status = MusicListenerServiceStatus.TRACKING;
            checkForUpdates(sbn);
        }
    }

    @Override
    public void onNotificationRemoved(StatusBarNotification sbn) {
        if(sbn.getPackageName().equals(musicPackageName)) {
            setMusicListenerStatus(MusicListenerServiceStatus.NO_NOTIFICATION);
        }
    }


    public void setMusicPackage(String musicPackage) {
        musicPackageName = musicPackage;
        startTimer();
        Log.i(TAG, "setMusicPackage: new package " + INSTANCE);
    }

    public void startForegroundService() {
        Log.i(TAG, "startForegroundService: Start foreground service");
        stopTimer();
        musicPackageName = ConfigUtil.getString(getBaseContext(),"flutter.music-app-package","");
        if (musicPackageName.isEmpty()) {
            Log.i(TAG, "onCreate: Do not start MusicListener service cause there is no MusicPackage");
            setMusicListenerStatus(MusicListenerServiceStatus.NO_PACKAGE);
            return;
        }
        showNotificationStatus = ConfigUtil.getBoolean(getBaseContext(),"flutter.show-status-notification",false);
        if (!isPermissionGranted()) {
            setMusicListenerStatus(MusicListenerServiceStatus.NO_PERMISSION);
            Log.w(TAG, "startForegroundService: Permission not granted. Can't start the service");
            return;
        }
        NotificationChannel channel = new NotificationChannel(CHANNEL_ID,
                "Music Listener Service",
                NotificationManager.IMPORTANCE_NONE);
        channel.setShowBadge(false);

        notificationManager = (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
        notificationManager.createNotificationChannel(channel);

        startForeground(NOTIFICATION_ID, getNotification());
        Log.i(TAG, "startForegroundService: started foreground process");

        if (status != MusicListenerServiceStatus.TRACKING) startTimer();
    }


    private void startTimer() {
        if (timer != null) {
            Log.i(TAG, "startTimer: Timer is already active");
            return;
        }
        Log.i(TAG, "startTimer: Timer started");
        setMusicListenerStatus(MusicListenerServiceStatus.NO_NOTIFICATION);
        //run it once so if the music is already playing it also gets tracked
        fetchActiveNotifications();
        timer = new Timer();
        timer.schedule(new TimerTask() {
            @Override
            public void run() {
                incrementTimeListened();
                if(lastBackupTime <= 0) {
                    if(ConfigUtil.getBoolean(getBaseContext(),"flutter.backup-database",false)) {
                        BackupDatabaseUtil.backupDatabase(getBaseContext());
                    }
                    lastBackupTime = 60*60;
                }
                lastBackupTime--;
            }
        }, 5000, 1000);

    }

    private void stopTimer() {
        if (timer != null) {
            setMusicListenerStatus(MusicListenerServiceStatus.PAUSED);
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
        currentNotification = sbn;
        if (sbn == null) {
            setMusicListenerStatus(MusicListenerServiceStatus.NO_NOTIFICATION);
            return;
        }
        setMusicListenerStatus(MusicListenerServiceStatus.TRACKING);
        checkForUpdates(sbn);
    }

    private void incrementTimeListened() {
        if (isSameSong()) {
            if (currentMediaController.getPlaybackState() != null && currentMediaController.getPlaybackState().getState() == PlaybackState.STATE_PLAYING) {
                currentSong.incrementTimeListened();
                currentSong.setProgress(currentMediaController.getPlaybackState().getPosition());
            }
        }
    }

    private void checkForUpdates(StatusBarNotification sbn) {
        if (currentMediaController == null || currentMediaController.getPlaybackState() == null) {
            Log.i(TAG, "fetchActiveNotifications: Current media controller is null. Retrieving from the notification.");
            currentMediaController = getMediaControllerFromNotification(sbn);
            if (currentMediaController == null) {
                Log.e(TAG, "fetchActiveNotifications: Could not get MediaController from notification: " + sbn.getNotification().toString());
                setMusicListenerStatus(MusicListenerServiceStatus.NO_MEDIA_CONTROLLER);
                return;
            }
        }
        if (currentSong.getTimeListened() == -1) {
            Log.i(TAG, "fetchActiveNotifications: New song detected.");
            currentSong = SongData.of(currentMediaController);
            saveArt();
            if(showNotificationStatus) notificationManager.notify(NOTIFICATION_ID,getNotification());
            return;
        }
        if (!isSameSong()) {
            if (currentMediaController.getPlaybackState() != null) {
                currentSong.setProgress(currentMediaController.getPlaybackState().getPosition());
            }
            currentSong.setEndTime(LocalDateTime.now());
            SongData oldSong = currentSong;
            currentSong = SongData.of(currentMediaController);
            Log.i(TAG, "checkForUpdates: New song detected. Old song was: " + oldSong);
            // extra thread because this can take some time
            executor.execute(() -> {
                if(!database.isOpen()) {
                    connectToDatabase();
                }
                database.musicTrackDao().insertTrack(oldSong);
                IntegrationHandler.getInstance().handleUpload(oldSong);
                saveArt();
                if(showNotificationStatus) notificationManager.notify(NOTIFICATION_ID,getNotification());
            });
        }
    }

    private boolean isSameSong() {
        if(currentMediaController == null) return false;
        MediaMetadata metadata = currentMediaController.getMetadata();
        if (metadata == null) return false;
        String artist = metadata.getString(MediaMetadata.METADATA_KEY_ARTIST);
        String title = metadata.getString(MediaMetadata.METADATA_KEY_TITLE);
        String album = metadata.getString(MediaMetadata.METADATA_KEY_ALBUM);
        return currentSong.getIdentifier().equals(artist + "," + title + "," + album);
    }

    private MediaController getMediaControllerFromNotification(StatusBarNotification sbn) {
        if(sbn.getNotification() == null) return null;
        MediaSession.Token mediaSessionToken = sbn.getNotification().extras.getParcelable("android.mediaSession");
        if (mediaSessionToken == null) return null;
        return new MediaController(getApplicationContext(), mediaSessionToken);
    }

    private void saveArt() {
        String filename = currentSong.getIdentifier() + ".jpeg";
        MediaMetadata metadata = currentMediaController.getMetadata();
        if (metadata == null) return;
        Bitmap bitmap = metadata.getBitmap(MediaMetadata.METADATA_KEY_ART);
        if (bitmap == null) bitmap = metadata.getBitmap(MediaMetadata.METADATA_KEY_ALBUM_ART);
        if(bitmap == null && currentNotification.getNotification().getLargeIcon() != null) {
            bitmap = BitmapUtil.drawableToBitmap(currentNotification.getNotification().getLargeIcon().loadDrawable(getBaseContext()));
        }
        if(bitmap == null && currentNotification.getNotification().getSmallIcon() != null) {
            bitmap = BitmapUtil.drawableToBitmap(currentNotification.getNotification().getSmallIcon().loadDrawable(getBaseContext()));
        }
        if(bitmap == null) return;
        if (!Files.exists(Paths.get(getBaseContext().getFilesDir().toString()).resolve(filename))) {
            BitmapUtil.saveBitmapAsPNG(getBaseContext(), bitmap, filename);
        }
    }

    public void setMusicListenerStatus(MusicListenerServiceStatus newStatus) {
        status = newStatus;
        if(showNotificationStatus) notificationManager.notify(NOTIFICATION_ID,getNotification());
    }

    private Notification getNotification() {
        if(showNotificationStatus) {
            return new NotificationCompat.Builder(this, CHANNEL_ID)
                    .setSmallIcon(R.mipmap.ic_launcher_round)
                    .setContentTitle("Status: " + status)
                    .setContentText("Current song: " + String.format("%s - %s", currentSong.getArtist(), currentSong.getTitle()))
                    .setOngoing(true)
                    .build();
        }else {
            return new NotificationCompat
                    .Builder(this,CHANNEL_ID)
                    .setPriority(NotificationManager.IMPORTANCE_MIN)
                    .build();
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
        NO_NOTIFICATION,
        NO_MEDIA_CONTROLLER,
        TRACKING,
        PAUSED,
    }
}
