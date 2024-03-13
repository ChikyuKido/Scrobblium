package io.github.chikyukido.music_tracker.database;

import androidx.room.Database;
import androidx.room.RoomDatabase;
import androidx.room.TypeConverters;

@Database(entities = {SongData.class}, version = 1)
@TypeConverters({LocalDateTimeConverter.class})
public abstract class SongDatabase extends RoomDatabase {
    public abstract SongTrackDao musicTrackDao();
}