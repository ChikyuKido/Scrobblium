package io.github.chikyukido.scrobblium.dao;

import java.util.HashMap;
import java.util.Map;

public class MethodChannelData {
    private String error;
    private byte[] data;

    public MethodChannelData(String error, byte[] data) {
        this.error = error;
        this.data = data;
    }
    public MethodChannelData(String error) {
        this.error = error;
    }
    public MethodChannelData() {}

    public String getError() {
        return error;
    }

    public void setError(String error) {
        this.error = error;
    }

    public byte[] getData() {
        return data;
    }

    public void setData(byte[] data) {
        this.data = data;
    }

    public Map<String, Object> toMap() {
        Map<String, Object> map = new HashMap<>();
        map.put("error", error);
        map.put("data", data);
        return map;
    }

    public static MethodChannelData fromMap(Map<String, Object> map) {
        String error = (String) map.get("error");
        byte[] data = map.get("data") != null ? (byte[]) map.get("data") : null;
        return new MethodChannelData(error, data);
    }
}
