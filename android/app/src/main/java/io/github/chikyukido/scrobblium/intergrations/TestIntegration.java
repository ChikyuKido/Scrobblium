package io.github.chikyukido.scrobblium.intergrations;

import android.content.Context;

import java.util.Collections;
import java.util.HashMap;
import java.util.List;

import io.github.chikyukido.scrobblium.database.SongData;

public class TestIntegration extends Integration {
    public TestIntegration(Context context) {
        super(context);
    }

    @Override
    String getName() {
        return "Test";
    }

    @Override
    String getAuthor() {
        return "me";
    }

    @Override
    String getVersion() {
        return "1.0.0";
    }

    @Override
    String getDescription() {
        return "A si mple test";
    }

    @Override
    boolean isLoggedIn() {
        return false;
    }

    @Override
    List<String> requiredFields() {
        return Collections.emptyList();
    }

    @Override
    boolean signIn(HashMap<String, String> fields) {
        return false;
    }

    @Override
    void signOut() {

    }

    @Override
    List<SongData> uploadTracks(List<SongData> songData) {
        return Collections.emptyList();
    }
}
