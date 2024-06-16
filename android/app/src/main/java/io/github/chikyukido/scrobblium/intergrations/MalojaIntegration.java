package io.github.chikyukido.scrobblium.intergrations;

import android.content.Context;
import android.util.Log;

import com.google.gson.JsonObject;
import com.google.gson.JsonPrimitive;

import java.io.IOException;
import java.time.LocalDate;
import java.time.ZoneId;
import java.time.ZoneOffset;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.concurrent.atomic.AtomicBoolean;

import io.github.chikyukido.scrobblium.database.SongData;
import okhttp3.MediaType;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.RequestBody;
import okhttp3.Response;

public class MalojaIntegration extends Integration {

    private static final String TAG = "MalojaIntegration";

    public MalojaIntegration(Context context) {
        super(context);
    }

    @Override
    String getName() {
        return "Maloja";
    }

    @Override
    public boolean isLoggedIn() {
        return json.has("api_key") && json.has("url");
    }

    @Override
    public List<String> requiredFields() {
        return Arrays.asList("url", "api_key");
    }

    @Override
    public boolean signIn(HashMap<String, String> fields) {
        if(fields.get("url") == null || fields.get("api_key") == null) return false;
        String baseURL = fields.get("url");
        if (!baseURL.startsWith("http://") && !baseURL.startsWith("https://")) {
            baseURL = "http://" + baseURL;
        }

        json.add("url", new JsonPrimitive(baseURL));
        json.add("api_key",new JsonPrimitive(fields.get("api_key")));
        JsonObject jsonObject = new JsonObject();
        jsonObject.add("key",new JsonPrimitive(fields.get("api_key")));
        String url = baseURL+"/api/newscrobble";

        AtomicBoolean result = new AtomicBoolean();

        //TODO: Maybe later dont wait for this thread instead send back a callback to the flutter frontend
        Thread t = new Thread(() -> {
        RequestBody body = RequestBody.create(gson.toJson(jsonObject), MediaType.parse("application/json; charset=utf-8"));

        Request request = new Request.Builder()
                .url(url)
                .post(body)
                .build();

        try (Response response = client.newCall(request).execute()) {
            if(response.body() == null) {
                result.set(false);
                return;
            }
            if(response.body().string().contains("missing_scrobble_data")) {
                result.set(true);
            }
        } catch (Exception e) {
            Log.e(TAG, "signIn: Error sending login request", e);
            result.set(false);
        }
    });

        t.start();
        try {
            t.join();
        } catch (InterruptedException e) {
            throw new RuntimeException(e);
        }

        saveJson();
        return result.get();
    }


    @Override
    public void signOut() {
        json.remove("url");
        json.remove("api_key");
        saveJson();
    }

    @Override
    public void nowPlaying(SongData songData) {
        //has no now playing feature
    }

    @Override
    public void uploadTracks(List<SongData> songDatas) {
        if(!isLoggedIn()) return;
        for (SongData songData : songDatas) {
            String url = json.get("url").getAsString()+"/api/newscrobble";
            JsonObject jsonObject = new JsonObject();
            jsonObject.add("key",new JsonPrimitive(json.get("api_key").getAsString()));
            jsonObject.add("artist",new JsonPrimitive(songData.getArtist()));
            jsonObject.add("title",new JsonPrimitive(songData.getTitle()));
            jsonObject.add("album",new JsonPrimitive(songData.getAlbum()));
            jsonObject.add("albumartists",new JsonPrimitive(songData.getAlbumAuthor()));
            jsonObject.add("duration",new JsonPrimitive(songData.getTimeListened()));
            jsonObject.add("length",new JsonPrimitive(songData.getMaxProgress()));
            jsonObject.add("time",new JsonPrimitive(songData.getEndTime().atZone(ZoneId.systemDefault()).toEpochSecond()));
            jsonObject.add("nofix",new JsonPrimitive(true));
            new Thread(() -> {
                RequestBody body = RequestBody.create(gson.toJson(jsonObject), MediaType.parse("application/json; charset=utf-8"));
                Request request = new Request.Builder()
                        .url(url)
                        .post(body)
                        .build();

                try (Response response = client.newCall(request).execute()) {
                    if(response.body() == null) {
                        Log.d(TAG,"uploadTracks: Could not upload track");
                        return;
                    }
                    if(response.body().string().contains("success")) {
                        Log.d(TAG, "uploadTracks: Successfully uploaded track");
                    }else {
                        Log.d(TAG,"uploadTracks: Could not upload track");
                    }
                } catch (Exception e) {
                    Log.e(TAG, "uploadTracks: Error sending login request", e);
                }
            }).start();
        }
    }
}
