package io.github.chikyukido.scrobblium.intergrations;

import android.content.Context;
import android.util.Log;

import com.google.gson.Gson;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;


import java.nio.ByteBuffer;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.stream.Collectors;
import io.github.chikyukido.scrobblium.database.SongData;
import io.github.chikyukido.scrobblium.util.BatteryUtils;
import io.github.chikyukido.scrobblium.util.ConfigUtil;
import io.github.chikyukido.scrobblium.util.JsonUtil;
import io.github.chikyukido.scrobblium.util.MethodChannelUtil;
import io.github.chikyukido.scrobblium.util.NetworkUtils;

public class IntegrationHandler {
    private static final String TAG = "IntegrationHandler";
    private static IntegrationHandler INSTANCE;
    private final Gson gson = JsonUtil.getGson();
    private final List<Integration> integrations = new ArrayList<>();
    private final ExecutorService executor = Executors.newFixedThreadPool(1);
    private boolean alreadyInitialized = false;
    private HashMap<String, MethodChannelUtil.MethodInterface> methods;

    private IntegrationHandler() {}
    public void init(Context context) {
        if(alreadyInitialized) {
            Log.w(TAG, "init: IntegrationHandler is already initialized");
            return;
        }
        integrations.add(new MalojaIntegration(context));
        alreadyInitialized = true;
    }

    public void addIntegrationsToMethodChannel(HashMap<String, MethodChannelUtil.MethodInterface> methods,Context context) {
        this.methods = methods;
        for (Integration integration : integrations) {
            addIntegrationMethods(integration);
        }
        methods.put("getIntegrations",(data, call) -> {
            data.setData(integrations.stream().map(Integration::getName).collect(Collectors.joining(";")).getBytes());
            data.reply();
        });
        methods.put("checkConditionalUpload",(data, call) -> {
            String failure = checkUploadConditions(context);
            data.setDataAsString(failure == null ? "All conditions are met" : failure);
            data.reply();
        });
    }
    private void addIntegrationMethods(Integration integration) {
        methods.put("loginFor"+integration.getName(),(data, call) -> {
            String jsonContent = call.argument("fields");
            JsonObject json = gson.fromJson(jsonContent,JsonObject.class);
            HashMap<String,String> fields = new HashMap<>();
            for (Map.Entry<String, JsonElement> stringJsonElementEntry : json.entrySet()) {
                fields.put(stringJsonElementEntry.getKey(),stringJsonElementEntry.getValue().getAsString());
            }
            data.setData(new byte[]{(byte)(integration.signIn(fields)?1:0)});
            data.reply();
        });
        methods.put("logoutFor"+integration.getName(),(data, call) -> {
            integration.signOut();
            data.reply();
        });
        methods.put("isLoggedInFor"+integration.getName(),(data, call) -> {
            data.setData(new byte[]{(byte)(integration.isLoggedIn()?1:0)}); //TODO: create a setBool function
            data.reply();
        });
        methods.put("getCachedSongsFor"+integration.getName(),(data, call) -> {
            ByteBuffer byteBuffer = ByteBuffer.allocate(4);
            byteBuffer.putInt(integration.getCachedSongsSize());
            data.setData(byteBuffer.array());
            data.reply();
        });
        methods.put("getRequiredFieldsFor"+integration.getName(),(data, call) -> {
            data.setDataAsString(String.join(";",integration.requiredFields()));
            data.reply();
        });
        methods.put("uploadCachedSongsFor"+integration.getName(),(methodChannelData,call) -> {
            executor.execute(() -> {
                integration.uploadCachedSongs();
                methodChannelData.setData(("Uploaded songs to "+integration.getName()).getBytes());
                methodChannelData.reply();
            });
        });
        methods.put("getIntegrationInfoFor"+integration.getName(),(methodChannelData, call) -> {
            List<String> data = List.of(integration.getName(),integration.getAuthor(),integration.getVersion(),integration.getDescription());
            methodChannelData.setDataAsString(String.join(";",data));
            methodChannelData.reply();
        });
    }
    public void handleUpload(SongData songData,Context context) {
        if((double) songData.getTimeListened() /((double) songData.getMaxProgress() /1000) < 0.5 && songData.getTimeListened() < 240) {
            return;
        }
        executor.execute(() -> {
            for (Integration integration : integrations) {
                if(integration.isActive()) {
                    boolean shouldUpload = !ConfigUtil.getBoolean("flutter.enable-conditional-upload",false)
                                    && NetworkUtils.isConnected(context);
                    integration.uploadTrack(songData,shouldUpload);
                }
            }
        });
    }
    public void handleConditionalUpload(Context context) {
        String failureReason = checkUploadConditions(context);
        if (failureReason != null) {
            Log.i(TAG, "handleConditionalUpload: " + failureReason);
            return;
        }

        Log.i(TAG, "handleConditionalUpload: Conditional upload meets all conditions, start uploading");
        executor.execute(() -> {
            for (Integration integration : integrations) {
                if (integration.isActive()) {
                    integration.uploadCachedSongs();
                }
            }
        });
    }

    private String checkUploadConditions(Context context) {
        if (!NetworkUtils.isConnected(context)) {
            return "Don't attempt to upload cached songs because there is no internet connection";
        }

        String networkMode = ConfigUtil.getString("flutter.condition-network-mode", "both");
        boolean batteryChargingCondition = ConfigUtil.getBoolean("flutter.condition-battery-charging", false);

        if (networkMode.equals("wlan")) {
            if (!NetworkUtils.isUsingWIFI(context)) {
                return "Conditional upload failed to meet network condition. Wifi is not on";
            }
        } else if (networkMode.equals("mobile")) {
            if (!NetworkUtils.isUsingMobile(context)) {
                return "Conditional upload failed to meet network condition. Mobile data is not on";
            }
        }
        if (batteryChargingCondition) {
            if (!BatteryUtils.isBatteryCharging(context)) {
                return "Conditional upload failed to meet battery condition. Battery is not charging";
            }
        }
        return null;
    }

    public static IntegrationHandler getInstance() {
        if(INSTANCE == null) INSTANCE = new IntegrationHandler();
        return INSTANCE;
    }

}
