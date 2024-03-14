package io.github.chikyukido.scrobblium;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.graphics.Bitmap;
import android.media.MediaMetadata;
import android.media.session.MediaController;
import android.media.session.MediaSession;
import android.media.session.PlaybackState;
import android.service.notification.NotificationListenerService;
import android.service.notification.StatusBarNotification;
import android.util.Log;

import androidx.core.app.NotificationCompat;
import androidx.room.Room;

import java.nio.file.Files;
import java.nio.file.Paths;
import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.Timer;
import java.util.TimerTask;

import io.github.chikyukido.scrobblium.database.SongData;
import io.github.chikyukido.scrobblium.database.SongDatabase;
import io.github.chikyukido.scrobblium.util.BitmapUtil;
import io.github.chikyukido.scrobblium.util.ConfigUtil;

public class MusicListenerService extends NotificationListenerService {
    private static MusicListenerService INSTANCE = null;

    private final String TAG = "MusicListenerService";
    private final int NOTIFICATION_ID = 1956;
    private final String CHANNEL_ID = "MusicListenerServiceChannel";
    private String musicPackageName = "";

    private SongDatabase database;
    private SongData currentSong = new SongData("", "", "", "", -1L, -1L, LocalDateTime.MIN,
            LocalDateTime.MIN, -1);
    private MediaController currentMediaController;
    private Timer timer;

    @Override
    public void onCreate() {
        super.onCreate();
        INSTANCE = this;
        database = Room.databaseBuilder(
                getApplicationContext(),
                SongDatabase.class,
                "song_database"
        ).build();
        musicPackageName = ConfigUtil.getMusicPackage(getBaseContext());
        if (musicPackageName.isEmpty()) {
            Log.i(TAG, "onCreate: Do not start MusicListener service cause there is no MusicPackage");
        } else {
            startForegroundService();
            startTimer();
        }
    }
    public void setMusicPackage(String musicPackage) {
        musicPackageName = musicPackage;
        INSTANCE.startTimer();
        Log.i(TAG, "setMusicPackage: new package " + INSTANCE);
    }

    private void startForegroundService() {
        NotificationChannel channel = new NotificationChannel(CHANNEL_ID,
                "Music Listener Service",
                NotificationManager.IMPORTANCE_DEFAULT);
        NotificationManager manager = getSystemService(NotificationManager.class);
        manager.createNotificationChannel(channel);
        Notification notification = new NotificationCompat.Builder(this, CHANNEL_ID).build();
        startForeground(NOTIFICATION_ID, notification);
    }

    private void startTimer() {
        if (timer != null) {
            Log.i(TAG, "startTimer: Timer is already active");
            return;
        }
        Log.i(TAG, "startTimer: Timer started");
        timer = new Timer();
        long timerPeriod = 1000;
        timer.scheduleAtFixedRate(new TimerTask() {
            @Override
            public void run() {
                fetchActiveNotifications();
            }
        }, 5000, timerPeriod);

    }

    private void stopTimer() {
        if (timer != null) {
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
            if (currentMediaController.getPlaybackState() != null &&
                    currentMediaController.getPlaybackState().getState() == PlaybackState.STATE_PLAYING) {
                currentSong.incrementTimeListened();
                currentSong.setProgress(currentMediaController.getPlaybackState().getPosition());
            }
        } else {
            currentSong.setEndTime(LocalDateTime.now());
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
        MediaSession.Token mediaSessionToken = (MediaSession.Token) sbn.getNotification().extras.getParcelable("android.mediaSession");
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
    public static MusicListenerService getInstance() {
        return INSTANCE;
    }
}
