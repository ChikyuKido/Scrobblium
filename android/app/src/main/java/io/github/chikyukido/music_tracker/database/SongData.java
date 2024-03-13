package io.github.chikyukido.music_tracker.database;


import java.time.LocalDateTime;
import java.util.Objects;

import android.graphics.Bitmap;
import android.media.MediaMetadata;
import android.media.session.MediaController;

import androidx.room.Entity;
import androidx.room.PrimaryKey;

import io.github.chikyukido.music_tracker.util.BitmapUtil;

@Entity(tableName = "played_songs")
public class SongData {
    @PrimaryKey(autoGenerate = true)
    private long id;

    private final String artist;
    private final String title;
    private final String album;
    private final String albumAuthor;
    private long progress;
    private final long maxProgress;
    private final LocalDateTime startTime;
    private LocalDateTime endTime;
    private int timeListened;

    public SongData(String artist, String title, String album, String albumAuthor, long progress, long maxProgress, LocalDateTime startTime, LocalDateTime endTime, int timeListened) {
        this.artist = artist;
        this.title = title;
        this.album = album;
        this.albumAuthor = albumAuthor;
        this.progress = progress;
        this.maxProgress = maxProgress;
        this.startTime = startTime;
        this.endTime = endTime;
        this.timeListened = timeListened;
    }

    public static SongData of(MediaController mediaController) {
        MediaMetadata metadata = mediaController.getMetadata();
        String artist = metadata.getString(MediaMetadata.METADATA_KEY_ARTIST);
        String title = metadata.getString(MediaMetadata.METADATA_KEY_TITLE);
        String album = metadata.getString(MediaMetadata.METADATA_KEY_ALBUM);
        String albumAuthor = metadata.getString(MediaMetadata.METADATA_KEY_ALBUM_ARTIST);
        long progress = mediaController.getPlaybackState().getPosition();
        long maxProgress = metadata.getLong(MediaMetadata.METADATA_KEY_DURATION);
        return new SongData(artist,title,album,albumAuthor,progress,maxProgress,LocalDateTime.now(),null,0);
    }

    public String getIdentifier() {
        return artist + "," + title + "," + album;
    }
    public void incrementTimeListened() {
        this.timeListened++;
    }
    public long getId() {
        return id;
    }

    public void setId(long id) {
        this.id = id;
    }
    public String getArtist() {
        return artist;
    }

    public String getTitle() {
        return title;
    }

    public String getAlbum() {
        return album;
    }

    public String getAlbumAuthor() {
        return albumAuthor;
    }

    public long getProgress() {
        return progress;
    }

    public long getMaxProgress() {
        return maxProgress;
    }

    public LocalDateTime getStartTime() {
        return startTime;
    }

    public LocalDateTime getEndTime() {
        return endTime;
    }

    public int getTimeListened() {
        return timeListened;
    }

    public void setProgress(long progress) {
        this.progress = progress;
    }

    public void setEndTime(LocalDateTime endTime) {
        this.endTime = endTime;
    }

    public void setTimeListened(int timeListened) {
        this.timeListened = timeListened;
    }



    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        SongData songData = (SongData) o;
        return Objects.equals(artist, songData.artist) && Objects.equals(title, songData.title) && Objects.equals(album, songData.album) && Objects.equals(albumAuthor, songData.albumAuthor);
    }

    @Override
    public int hashCode() {
        return Objects.hash(artist, title, album, albumAuthor);
    }
}
