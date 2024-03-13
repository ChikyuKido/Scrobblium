package io.github.chikyukido.music_tracker;

import android.os.Environment;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;

import androidx.annotation.NonNull;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.JsonElement;
import com.google.gson.JsonPrimitive;
import com.google.gson.JsonSerializationContext;
import com.google.gson.JsonSerializer;

import org.xmlpull.v1.XmlPullParserException;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.lang.reflect.Type;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import io.github.chikyukido.music_tracker.database.SongData;
import io.github.chikyukido.music_tracker.util.ConfigUtil;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "MusicListener";
    private Gson gson = new Gson();

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        gson = new GsonBuilder().registerTypeAdapter(LocalDateTime.class, (JsonSerializer<LocalDateTime>) (src, typeOfSrc, context) -> new JsonPrimitive(src.toString())).create();
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler(
                        (call, result) -> {
                            if (call.method.equals("list")) {
                                new Thread(() -> {
                                    if(MusicListenerService.getDatabase() == null) {
                                        new Handler(Looper.getMainLooper()).post(() -> result.success("[]"));
                                        return;
                                    }
                                    List<SongData> tracks = MusicListenerService.getDatabase().musicTrackDao().getAllTracks();
                                    String json = gson.toJson(tracks);
                                    new Handler(Looper.getMainLooper()).post(() -> result.success(json));
                                }).start();
                            } else if(call.method.equals("currentSong")){
                                if(MusicListenerService.getCurrentSong().getMaxProgress() == -1) {
                                    result.success("[]");
                                    return;
                                }
                                result.success(gson.toJson(MusicListenerService.getCurrentSong()));
                            } else if(call.method.equals("setMusicPackage")) {
                                String argument = call.argument("package");
                                MusicListenerService.setMusicPackage(argument);
                            }
                            else {
                                result.notImplemented();
                            }
                        }
                );
    }
}
