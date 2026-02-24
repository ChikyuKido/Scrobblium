package io.github.chikyukido.scrobblium;

import android.content.Context;
import android.content.Intent;
import android.util.Log;
import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import io.github.chikyukido.scrobblium.dao.MethodChannelData;
import io.github.chikyukido.scrobblium.intergrations.IntegrationHandler;
import io.github.chikyukido.scrobblium.util.MethodChannelUtil;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

public class MainActivity extends FlutterActivity {
    private static final String TAG = "MainActivity";
    private static final String CHANNEL = "MusicListener";
    public static final List<MethodChannelData> resumeCallbacks = new ArrayList<>();
    public static final HashMap<Integer,ActivityResultCallback> activityResultCallbacks = new HashMap<>();


    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        IntegrationHandler.getInstance().init(this);
        MethodChannelUtil.configureMethodChannel(new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL), this);
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        if(activityResultCallbacks.containsKey(requestCode)) {
            activityResultCallbacks.get(requestCode).run(getApplicationContext(),data,resultCode);
            activityResultCallbacks.remove(requestCode);
        }else {
            Log.w(TAG, "onActivityResult: No result callback found for id: "+ requestCode);
        }
    }

    @Override
    protected void onResume() {
        super.onResume();
        resumeCallbacks.forEach(MethodChannelData::reply);
    }

    public interface ActivityResultCallback {
        void run(Context context, Intent intent,int resultCode);
    }
}
