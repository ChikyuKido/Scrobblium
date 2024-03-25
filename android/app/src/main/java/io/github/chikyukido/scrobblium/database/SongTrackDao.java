package io.github.chikyukido.scrobblium.database;

import androidx.room.Dao;
import androidx.room.Insert;
import androidx.room.Query;

import java.util.List;

@Dao
public interface SongTrackDao {
    @Query("SELECT * FROM played_songs")
    List<SongData> getAllTracks();
    @Insert
    void insertTrack(SongData track);
    @Query("DELETE FROM played_songs WHERE id = :id")
    void deleteTrack(int id);
}