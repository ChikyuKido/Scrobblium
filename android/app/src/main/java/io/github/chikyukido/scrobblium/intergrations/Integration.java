package io.github.chikyukido.scrobblium.intergrations;

import android.content.Context;
import android.util.Log;
import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import io.github.chikyukido.scrobblium.database.SongData;
import io.github.chikyukido.scrobblium.util.ConfigUtil;
import io.github.chikyukido.scrobblium.util.JsonUtil;
import okhttp3.OkHttpClient;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardOpenOption;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

/**
 * The integration for a other scrobble service like last.fm
 */
public abstract class Integration {
    private static final String TAG = "Integration";
    protected final JsonObject json;
    protected final Gson gson = JsonUtil.getGson();
    protected final OkHttpClient client = new OkHttpClient();
    private List<SongData> cachedSongs = new ArrayList<>();
    private Context context;

    public Integration(Context context) {
        this.context = context;
        this.json = loadJson();
        if(json.has("cached_songs")) {
            for(JsonElement song : json.getAsJsonArray("cached_songs")) {
                cachedSongs.add(gson.fromJson(song, SongData.class));
            }
        }
    }

    /**
     * @return the name of the integration
     */
    abstract String getName();

    /**
     * @return The author of this integration
     */
    abstract String getAuthor();

    /**
     * @return The version of the integration
     */
    abstract String getVersion();

    /**
     * @return A small description for the integration
     */
    abstract String getDescription();
    /**
     * Checks if the user is still logged in with a valid session.
     * @return if the user is logged in
     */
    abstract boolean isLoggedIn();

    /**
     * These function should return the required fields for the login to the service. Also like password and username. Or a url and a token.
     * @return A list of fields
     */
    abstract List<String> requiredFields();

    /**
     * Sign in the user in the specific integration
     * @param fields the fields that are required for the login
     * @return if the login was successful
     */
    abstract boolean signIn(HashMap<String,String> fields);

    /**
     * Signs out the user. Delete all the stored session data etc.
     */
    abstract void signOut();


    /**
     * Upload a finished track to the server. If there was no internet connection it can happen that multiple tracks are cached
     * up so you need to upload multiple tracks
     * @param songData the song data to upload
     * @return songs that could not be uploaded to due errors. These songs will be tried next time
     */
    abstract List<SongData> uploadTracks(List<SongData> songData);


    /**
     * Tries to upload all cached songs.
     */
    public void uploadCachedSongs() {
        cachedSongs = uploadTracks(cachedSongs);
        json.add("cached_songs", new JsonArray());
        JsonArray arr = json.get("cached_songs").getAsJsonArray();
        for (SongData cachedSong : cachedSongs) {
            arr.add(gson.toJsonTree(cachedSong));
        }
        saveJson();
    }

    public void uploadTrack(SongData songData,boolean shouldUpload) {
        cachedSongs.add(songData);
        //if no network there is no reason to attempt a upload
        if(shouldUpload) {
            cachedSongs = uploadTracks(cachedSongs);
        }
        json.add("cached_songs", new JsonArray());
        JsonArray arr = json.get("cached_songs").getAsJsonArray();
        for (SongData cachedSong : cachedSongs) {
            arr.add(gson.toJsonTree(cachedSong));
        }
        saveJson();
    }
    public boolean isActive() {
        if(!isLoggedIn()) return false;
        return ConfigUtil.getBoolean("flutter.activate-"+getName(),false);
    }

    public int getCachedSongsSize() {
        return cachedSongs.size();
    }
    protected JsonObject loadJson() {
        Path path = context.getFilesDir().toPath().resolve(getName()+".json");
        if(Files.exists(path)) {
            try {
                return gson.fromJson(Files.newBufferedReader(path),JsonObject.class);
            } catch (Exception e) {
                Log.e(TAG, "loadJson: Could not load json for "+getName()+" return a empty json", e);
                return new JsonObject();
            }
        }
        return new JsonObject();
    }
    protected void saveJson() {
        Path path = context.getFilesDir().toPath().resolve(getName()+".json");
        try {
            Files.write(path,gson.toJson(json).getBytes(StandardCharsets.UTF_8), StandardOpenOption.CREATE,StandardOpenOption.TRUNCATE_EXISTING);
        } catch (IOException e) {
            Log.e(TAG, "saveJson: Could not save json for "+getName(), e);
        }
    }
    public void setContext(Context context) {
        this.context = context;
    }
}
