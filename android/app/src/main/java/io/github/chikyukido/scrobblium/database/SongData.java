package io.github.chikyukido.scrobblium.database;


import android.media.MediaMetadata;
import android.media.session.MediaController;
import androidx.room.Entity;
import androidx.room.PrimaryKey;

import java.time.LocalDateTime;
import java.util.Objects;

@Entity(tableName = "played_songs")
public class SongData {
    private final String artist;
    private final String title;
    private final String album;
    private final String albumAuthor;
    private final long maxProgress;
    private final LocalDateTime startTime;
    @PrimaryKey(autoGenerate = true)
    private long id;
    private long progress;
    private LocalDateTime endTime;
    private int timeListened;

    public SongData(String artist, String title, String album, String albumAuthor, long progress, long maxProgress, LocalDateTime startTime, LocalDateTime endTime, int timeListened) {
        this.artist = artist != null ? artist : "Unknown Artist";
        this.title = title != null ? title : "Unknown Title";
        this.album = album != null ? album : "Unknown Album";
        this.albumAuthor = albumAuthor != null ? albumAuthor : "Unknown Album Author";
        this.progress = progress;
        this.maxProgress = maxProgress;
        this.startTime = startTime != null ? startTime : LocalDateTime.now();
        this.endTime = endTime != null ? endTime : LocalDateTime.now();
        this.timeListened = timeListened;
    }

    public static SongData of(MediaController mediaController) {
        MediaMetadata metadata = mediaController.getMetadata();
        String artist = metadata != null ? metadata.getString(MediaMetadata.METADATA_KEY_ARTIST) : "Unknown Artist";
        String title = metadata != null ? metadata.getString(MediaMetadata.METADATA_KEY_TITLE) : "Unknown Title";
        String album = metadata != null ? metadata.getString(MediaMetadata.METADATA_KEY_ALBUM) : "Unknown Album";
        String albumAuthor = metadata != null ? metadata.getString(MediaMetadata.METADATA_KEY_ALBUM_ARTIST) : "Unknown Album Author";
        long progress = mediaController.getPlaybackState().getPosition();
        long maxProgress = metadata != null ? metadata.getLong(MediaMetadata.METADATA_KEY_DURATION) : 0;
        return new SongData(artist, title, album, albumAuthor, progress, maxProgress, LocalDateTime.now(), null, 0);
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

    public void setProgress(long progress) {
        this.progress = progress;
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

    public void setEndTime(LocalDateTime endTime) {
        this.endTime = endTime;
    }

    public int getTimeListened() {
        return timeListened;
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

    @Override
    public String toString() {
        return "SongData{" +
                "artist='" + artist + '\'' +
                ", title='" + title + '\'' +
                ", album='" + album + '\'' +
                ", albumAuthor='" + albumAuthor + '\'' +
                ", maxProgress=" + maxProgress +
                ", startTime=" + startTime +
                ", progress=" + progress +
                ", endTime=" + endTime +
                ", timeListened=" + timeListened +
                '}';
    }

}
