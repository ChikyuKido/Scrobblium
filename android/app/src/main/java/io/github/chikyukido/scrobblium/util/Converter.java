package io.github.chikyukido.scrobblium.util;

import java.time.Instant;
import java.time.ZoneOffset;

import io.github.chikyukido.scrobblium.database.SongData;
import io.github.chikyukido.scrobblium.messages.SongDataM;

public class Converter {

    static SongDataM.Builder songDataBuilder = SongDataM.newBuilder();
    static SongDataM songDataToMessage(SongData song) {
        songDataBuilder
                .setId(song.getId())
                .setArtist(song.getArtist())
                .setTitle(song.getTitle())
                .setAlbum(song.getAlbum())
                .setAlbumAuthor(song.getAlbumAuthor() != null ? song.getAlbumAuthor() : "")
                .setMaxProgress(song.getMaxProgress())
                .setStartTime(song.getStartTime() != null ? song.getStartTime().atZone(ZoneOffset.UTC).toInstant().toEpochMilli() :0 )
                .setProgress(song.getProgress())
                .setEndTime(song.getEndTime() != null ? song.getEndTime().atZone(ZoneOffset.UTC).toInstant().toEpochMilli() : 0)
                .setTimeListened(song.getTimeListened());
        return songDataBuilder.build();
    }
    static SongData messageToSongData(SongDataM song) {
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

}

