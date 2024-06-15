package io.github.chikyukido.scrobblium.intergrations;

import android.content.Context;
import com.google.gson.JsonPrimitive;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import io.github.chikyukido.scrobblium.database.SongData;

public class MalojaIntegration extends Integration {

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
        json.add("url", new JsonPrimitive(fields.get("url")));
        json.add("api_key",new JsonPrimitive(fields.get("api_key")));


        saveJson();
        return true;
    }


    @Override
    public void signOut() {
        json.remove("url");
        json.remove("api_key");
        saveJson();
    }

    @Override
    public void nowPlaying(SongData songData) {

    }

    @Override
    public void uploadTracks(List<SongData> songData) {

    }
}
