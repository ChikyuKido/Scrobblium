package io.github.chikyukido.scrobblium.util;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;

import java.time.LocalDateTime;

import io.github.chikyukido.scrobblium.adapter.LocalDateTimeAdapter;

public class JsonUtil {
    private static final Gson gson = new GsonBuilder()
            .registerTypeAdapter(LocalDateTime.class, LocalDateTimeAdapter.getSerializer())
            .registerTypeAdapter(LocalDateTime.class, LocalDateTimeAdapter.getDeserializer())
            .create();

    public static Gson getGson() {
        return gson;
    }


}
