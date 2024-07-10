package io.github.chikyukido.scrobblium.dao;

import android.os.HandlerThread;
import android.os.Looper;
import android.util.Log;

import java.util.HashMap;
import java.util.Map;
import java.util.logging.Handler;

import io.flutter.plugin.common.MethodChannel;
import io.flutter.util.HandlerCompat;

public class MethodChannelData {
    private final MethodChannel methodChannel;
    private String error;
    private byte[] data;
    private int callbackId;

    public MethodChannelData(String error,byte[] data) {
        this.error = error;
        this.data = data;
        methodChannel = null;
    }
    public MethodChannelData() {
        methodChannel = null;
    }
    public MethodChannelData(MethodChannel methodChannel) {
        this.methodChannel = methodChannel;
    }

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

    public int getCallbackId() {
        return callbackId;
    }

    public void setCallbackId(int callbackId) {
        this.callbackId = callbackId;
    }

    public void reply() {
        new android.os.Handler(Looper.getMainLooper()).post(() -> methodChannel.invokeMethod("reply",toMap()));
    }

    public Map<String, Object> toMap() {
        Map<String, Object> map = new HashMap<>();
        map.put("error", error);
        map.put("data", data);
        map.put("callbackId", callbackId);
        return map;
    }

    public static MethodChannelData fromMap(Map<String, Object> map,MethodChannel methodChannel) {
        String error = (String) map.get("error");
        byte[] data = map.get("data") != null ? (byte[]) map.get("data") : null;
        MethodChannelData channelData =  new MethodChannelData(methodChannel);
        channelData.setError(error);
        channelData.setData(data);
        return channelData;
    }
}
