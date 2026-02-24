package io.github.chikyukido.scrobblium.util;

import io.github.chikyukido.scrobblium.database.SongData;
import io.github.chikyukido.scrobblium.messages.SongDataM;

import java.time.Instant;
import java.time.ZoneOffset;

public class Converter {

    private static final SongDataM.Builder songDataBuilder = SongDataM.newBuilder();
    public static SongDataM songDataToMessage(SongData song) {
        SongDataM.Builder b = SongDataM.newBuilder();

        b.setId((int) song.getId());
        b.setArtist(nullToEmpty(song.getArtist()));
        b.setTitle(nullToEmpty(song.getTitle()));
        b.setAlbum(nullToEmpty(song.getAlbum()));
        b.setAlbumAuthor(nullToEmpty(song.getAlbumAuthor()));
        b.setMaxProgress((int) song.getMaxProgress());
        b.setProgress((int) song.getProgress());
        b.setTimeListened(song.getTimeListened());

        b.setStartTime(toEpochMillisUtc(song.getStartTime()));
        b.setEndTime(toEpochMillisUtc(song.getEndTime()));

        return b.build();
    }
    public static SongData messageToSongData(SongDataM song) {
        return new SongData(
                song.getArtist(),
                song.getTitle(),
                song.getAlbum(),
                song.getAlbumAuthor(),
                song.getProgress(),
                song.getMaxProgress(),
                Instant.ofEpochMilli(song.getStartTime()).atZone(ZoneOffset.UTC).toLocalDateTime(),
                Instant.ofEpochMilli(song.getEndTime()).atZone(ZoneOffset.UTC).toLocalDateTime(),
                song.getTimeListened());
    }
    private static String nullToEmpty(String s) {
        return s == null ? "" : s;
    }

    private static long toEpochMillisUtc(java.time.LocalDateTime ldt) {
        if (ldt == null) return 0L;
        return ldt.toInstant(ZoneOffset.UTC).toEpochMilli(); // faster than atZone(...).toInstant()
    }

}

