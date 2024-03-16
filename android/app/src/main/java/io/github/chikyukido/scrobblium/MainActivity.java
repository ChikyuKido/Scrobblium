package io.github.chikyukido.scrobblium;

import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import io.github.chikyukido.scrobblium.util.MethodChannelUtil;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "MusicListener";

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        MethodChannelUtil.configureMethodChannel(new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL),this);
    }
}
