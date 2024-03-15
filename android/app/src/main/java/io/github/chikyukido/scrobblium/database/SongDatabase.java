package io.github.chikyukido.scrobblium.database;

import androidx.room.Database;
import androidx.room.RoomDatabase;
import androidx.room.TypeConverters;

@Database(entities = {SongData.class}, version = 1, exportSchema = false)
@TypeConverters({LocalDateTimeConverter.class})
public abstract class SongDatabase extends RoomDatabase {
    public abstract SongTrackDao musicTrackDao();
}