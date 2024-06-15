package io.github.chikyukido.scrobblium.intergrations;

import android.content.Context;

import com.google.gson.Gson;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;

import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.MethodChannel;
import io.github.chikyukido.scrobblium.util.MethodChannelUtil;

public class IntegrationHandler {
    private static IntegrationHandler INSTANCE;
    private final Gson gson = new Gson();
    private final HashMap<Integration,Boolean> integrations = new HashMap<>();

    private IntegrationHandler() {}
    public void init(Context context) {
        integrations.put(new MalojaIntegration(context),true);
    }

    public void addIntegrationsToMethodChannel(HashMap<String, MethodChannelUtil.MethodInterface> methods) {
        for (Integration integration : integrations.keySet()) {
            methods.put("loginFor"+integration.getName(),(call, result) -> {
                String jsonContent = call.argument("fields");
                JsonObject json = gson.fromJson(jsonContent,JsonObject.class);
                HashMap<String,String> fields = new HashMap<>();
                for (Map.Entry<String, JsonElement> stringJsonElementEntry : json.entrySet()) {
                    fields.put(stringJsonElementEntry.getKey(),stringJsonElementEntry.getValue().getAsString());
                }
                integration.signIn(fields);
                result.success(null);
            });
            methods.put("getRequiredFieldsFor"+integration.getName(),(call, result) ->
                    result.success(String.join(";",integration.requiredFields())));
        }
    }

    public static IntegrationHandler getInstance() {
        if(INSTANCE == null) INSTANCE = new IntegrationHandler();
        return INSTANCE;
    }
}
