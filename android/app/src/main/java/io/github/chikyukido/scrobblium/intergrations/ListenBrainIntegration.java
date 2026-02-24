package io.github.chikyukido.scrobblium.intergrations;

import android.content.Context;
import android.util.Log;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import com.google.gson.JsonPrimitive;
import io.github.chikyukido.scrobblium.database.SongData;
import okhttp3.MediaType;
import okhttp3.Request;
import okhttp3.RequestBody;
import okhttp3.Response;

import java.time.ZoneId;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.concurrent.atomic.AtomicBoolean;

public class ListenBrainIntegration extends Integration {

    private static final String TAG = "ListenBrainIntegration";

    public ListenBrainIntegration(Context context) {
        super(context);
    }

    @Override
    String getName() {
        return "ListenBrainz";
    }

    @Override
    String getAuthor() {
        return "Chikyu Kido";
    }

    @Override
    String getVersion() {
        return "1.0.0";
    }

    @Override
    String getDescription() {
        return "Integration for ListenBrainz. Needs a base URL (e.g. https://api.listenbrainz.org) and a user token.";
    }

    @Override
    public boolean isLoggedIn() {
        return json.has("token") && json.has("url");
    }

    @Override
    public List<String> requiredFields() {
        return Arrays.asList("url", "token");
    }

    private static String normalizeBaseUrl(String baseURL) {
        if (baseURL == null) return null;

        baseURL = baseURL.trim();
        if (baseURL.isEmpty()) return null;

        if (!baseURL.startsWith("http://") && !baseURL.startsWith("https://")) {
            baseURL = "https://" + baseURL;
        }

        while (baseURL.endsWith("/")) {
            baseURL = baseURL.substring(0, baseURL.length() - 1);
        }
        return baseURL;
    }

    @Override
    public boolean signIn(HashMap<String, String> fields) {
        if (fields.get("url") == null || fields.get("token") == null) return false;

        final String baseURL = normalizeBaseUrl(fields.get("url"));
        final String token = fields.get("token").trim();

        if (baseURL == null || token.isEmpty()) return false;

        final String url = baseURL + "/1/validate-token";

        AtomicBoolean result = new AtomicBoolean(false);

        // TODO: Maybe later don't wait for this thread; callback to flutter frontend
        Thread t = new Thread(() -> {
            Request request = new Request.Builder()
                    .url(url)
                    .get()
                    .addHeader("Authorization", "Token " + token)
                    .build();

            try (Response response = client.newCall(request).execute()) {
                if (response.body() == null) {
                    result.set(false);
                    return;
                }
                if (!response.isSuccessful()) {
                    result.set(false);
                    return;
                }

                // Expected JSON has "valid": true/false
                String body = response.body().string();
                JsonObject resp = gson.fromJson(body, JsonObject.class);
                boolean valid = resp != null && resp.has("valid") && resp.get("valid").getAsBoolean();
                result.set(valid);

            } catch (Exception e) {
                Log.e(TAG, "signIn: Error validating token: " + e.getMessage());
                result.set(false);
            }
        });

        t.start();
        try {
            t.join();
        } catch (InterruptedException e) {
            throw new RuntimeException(e);
        }

        if (result.get()) {
            json.add("url", new JsonPrimitive(baseURL));
            json.add("token", new JsonPrimitive(token));
            saveJson();
        }
        return result.get();
    }

    @Override
    public void signOut() {
        json.remove("url");
        json.remove("token");
        saveJson();
    }

    @Override
    public List<SongData> uploadTracks(List<SongData> songDatas) {
        if (!isLoggedIn()) return songDatas;

        List<SongData> failedSongs = new ArrayList<>();
        boolean failedWithException = false;

        final String baseURL = json.get("url").getAsString();
        final String token = json.get("token").getAsString();

        for (SongData songData : songDatas) {
            if (failedWithException) {
                failedSongs.add(songData);
                continue;
            }

            final String url = baseURL + "/1/submit-listens";

            long endEpoch = songData.getEndTime().atZone(ZoneId.systemDefault()).toEpochSecond();
            long listenedSeconds = songData.getTimeListened();
            long startEpoch = endEpoch - Math.max(0, listenedSeconds);
            if (startEpoch < 0) startEpoch = 0;

            JsonObject additionalInfo = new JsonObject();
            additionalInfo.add("submission_client", new JsonPrimitive("Scrobblium"));
            additionalInfo.add("submission_client_version", new JsonPrimitive(getVersion()));
            long durationMs = Math.max(0, songData.getTimeListened()) * 1000L;
            if (durationMs > 0) additionalInfo.add("duration_ms", new JsonPrimitive(durationMs));

            JsonObject trackMetadata = new JsonObject();
            trackMetadata.add("artist_name", new JsonPrimitive(songData.getArtist()));
            trackMetadata.add("track_name", new JsonPrimitive(songData.getTitle()));
            if (songData.getAlbum() != null && !songData.getAlbum().isEmpty()) {
                trackMetadata.add("release_name", new JsonPrimitive(songData.getAlbum()));
            }
            trackMetadata.add("additional_info", additionalInfo);

            JsonObject listen = new JsonObject();
            listen.add("listened_at", new JsonPrimitive(startEpoch));
            listen.add("track_metadata", trackMetadata);

            JsonArray payload = new JsonArray();
            payload.add(listen);

            JsonObject submit = new JsonObject();
            submit.add("listen_type", new JsonPrimitive("single"));
            submit.add("payload", payload);

            RequestBody body = RequestBody.create(
                    gson.toJson(submit),
                    MediaType.parse("application/json; charset=utf-8")
            );

            Request request = new Request.Builder()
                    .url(url)
                    .post(body)
                    .addHeader("Authorization", "Token " + token)
                    .addHeader("Content-Type", "application/json")
                    .build();

            try (Response response = client.newCall(request).execute()) {
                if (response.body() == null) {
                    failedSongs.add(songData);
                    continue;
                }
                if (!response.isSuccessful()) {
                    failedSongs.add(songData);
                    continue;
                }

                String respBody = response.body().string();
                JsonObject respJson = gson.fromJson(respBody, JsonObject.class);
                boolean ok = respJson != null
                        && respJson.has("status")
                        && "ok".equalsIgnoreCase(respJson.get("status").getAsString());

                if (!ok) failedSongs.add(songData);

            } catch (Exception e) {
                Log.e(TAG, "uploadTracks: Error submitting listen", e);
                failedSongs.add(songData);
                failedWithException = true;
            }
        }

        Log.d(TAG, "uploadTracks: Could not upload " + failedSongs.size() + " songs");
        return failedSongs;
    }
}