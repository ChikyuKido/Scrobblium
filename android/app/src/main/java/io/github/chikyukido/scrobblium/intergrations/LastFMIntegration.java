package io.github.chikyukido.scrobblium.intergrations;

import android.util.Log;
import io.github.chikyukido.scrobblium.database.SongData;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;

public class LastFMIntegration implements Integration{

    public static final String API_BASE_URL = "https://ws.audioscrobbler.com/2.0";
    public static final String API_AUTH_URL = "https://www.last.fm/api/";

    public static final String SECRET = "";


    @Override
    public boolean isLoggedIn() {
        return false;
    }

    @Override
    public boolean signIn(String username, String password) {
        Log.i("test", "signIn: "+username+"/"+password);

        Map<String, String> params = new TreeMap<>();
        params.put("api_key", "");
        params.put("method", "auth.getMobileSession");
        params.put("password", password);
        params.put("username", username);
        params.put("api_sig",generateSignature(params));


        return true;
    }

    @Override
    public void signOut() {

    }

    @Override
    public void nowPlaying(SongData songData) {

    }

    @Override
    public void uploadTracks(List<SongData> songData) {

    }

    public static String generateSignature(Map<String, String> params) {
        StringBuilder sortedParams = new StringBuilder();

        TreeMap<String, String> sortedMap = new TreeMap<>(params);

        for (Map.Entry<String, String> entry : sortedMap.entrySet()) {
            sortedParams.append(entry.getKey());
            sortedParams.append(entry.getValue());
        }

        sortedParams.append(SECRET);

        String md5Hash = null;
        try {
            MessageDigest md = MessageDigest.getInstance("MD5");
            byte[] hashBytes = md.digest(sortedParams.toString().getBytes(StandardCharsets.UTF_8));
            StringBuilder sb = new StringBuilder();
            for (byte b : hashBytes) {
                sb.append(String.format("%02x", b));
            }
            md5Hash = sb.toString();
        } catch (NoSuchAlgorithmException e) {
            e.printStackTrace();
        }
        return md5Hash;
    }
}
