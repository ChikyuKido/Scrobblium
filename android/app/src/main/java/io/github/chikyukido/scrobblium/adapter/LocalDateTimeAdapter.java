package io.github.chikyukido.scrobblium.adapter;

import com.google.gson.JsonDeserializer;
import com.google.gson.JsonSerializer;
import com.google.gson.JsonPrimitive;
import com.google.gson.JsonParseException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

public class LocalDateTimeAdapter {

    private static final DateTimeFormatter formatter = DateTimeFormatter.ISO_LOCAL_DATE_TIME;

    public static JsonSerializer<LocalDateTime> getSerializer() {
        return (src, typeOfSrc, context) -> new JsonPrimitive(src.format(formatter));
    }

    public static JsonDeserializer<LocalDateTime> getDeserializer() {
        return (json, typeOfT, context) -> {
            try {
                return LocalDateTime.parse(json.getAsString(), formatter);
            } catch (Exception e) {
                throw new JsonParseException(e);
            }
        };
    }
}
