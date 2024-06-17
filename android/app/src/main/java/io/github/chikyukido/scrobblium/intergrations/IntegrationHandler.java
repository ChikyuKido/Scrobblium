package io.github.chikyukido.scrobblium.intergrations;

import android.content.Context;

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

import io.flutter.plugin.common.MethodChannel;
import io.github.chikyukido.scrobblium.dao.MethodChannelData;
import io.github.chikyukido.scrobblium.database.SongData;
import io.github.chikyukido.scrobblium.util.MethodChannelUtil;

public class IntegrationHandler {
    private static IntegrationHandler INSTANCE;
    private final Gson gson = new Gson();
    private final List<Integration> integrations = new ArrayList<>();
    ExecutorService executor = Executors.newFixedThreadPool(1);


    private IntegrationHandler() {}
    public void init(Context context) {
        integrations.add(new MalojaIntegration(context));
    }

    public void addIntegrationsToMethodChannel(HashMap<String, MethodChannelUtil.MethodInterface> methods) {
        for (Integration integration : integrations) {
            methods.put("loginFor"+integration.getName(),(call, result) -> {
                MethodChannelData methodChannelData = new MethodChannelData();
                String jsonContent = call.argument("fields");
                JsonObject json = gson.fromJson(jsonContent,JsonObject.class);
                HashMap<String,String> fields = new HashMap<>();
                for (Map.Entry<String, JsonElement> stringJsonElementEntry : json.entrySet()) {
                    fields.put(stringJsonElementEntry.getKey(),stringJsonElementEntry.getValue().getAsString());
                }
                methodChannelData.setData(new byte[]{(byte)(integration.signIn(fields)?1:0)});
                result.success(methodChannelData.toMap());
            });
            methods.put("isLoggedInFor"+integration.getName(),(call, result) -> {
                MethodChannelData methodChannelData = new MethodChannelData();
                methodChannelData.setData(new byte[]{(byte)(integration.isLoggedIn()?1:0)});
                result.success(methodChannelData.toMap());
            });
            methods.put("cachedSongsFor"+integration.getName(),(call, result) -> {
                MethodChannelData methodChannelData = new MethodChannelData();
                ByteBuffer byteBuffer = ByteBuffer.allocate(4);
                byteBuffer.putInt(integration.getCachedSongsSize());
                methodChannelData.setData(byteBuffer.array());
                result.success(methodChannelData.toMap());
            });
            methods.put("getRequiredFieldsFor"+integration.getName(),(call, result) -> {
                MethodChannelData methodChannelData = new MethodChannelData();
                methodChannelData.setData(String.join(";",integration.requiredFields()).getBytes());
                result.success(methodChannelData.toMap());
            });
        }
    }
    public void handleUpload(SongData songData) {
        if(songData.getTimeListened()/songData.getMaxProgress() < 50 && songData.getTimeListened() < 240) {
            return;
        }
        executor.execute(() -> {
            for (Integration integration : integrations) {
                if(integration.isActive()) {
                    integration.uploadTrack(songData);
                }
            }
        });
    }

    public static IntegrationHandler getInstance() {
        if(INSTANCE == null) INSTANCE = new IntegrationHandler();
        return INSTANCE;
    }
}
