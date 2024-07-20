package io.github.chikyukido.scrobblium.util;

import android.content.Context;
import android.util.Log;

import androidx.annotation.NonNull;

import org.xmlpull.v1.XmlPullParser;
import org.xmlpull.v1.XmlPullParserException;
import org.xmlpull.v1.XmlPullParserFactory;

import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.nio.file.Path;
import java.util.Optional;

public class ConfigUtil {
    private static final String TAG = "ConfigUtil";
    private static Path SHARED_PREFS_PATH;

    public static void init(Context context) {
        SHARED_PREFS_PATH = context.getDataDir().toPath().resolve("shared_prefs/FlutterSharedPreferences.xml");
        Log.i(TAG, "init: "+SHARED_PREFS_PATH.toString());
    }

    @NonNull
    public static String getString( String key,String defaultValue) {
        return getValue(key).orElse(defaultValue);
    }

    public static boolean getBoolean(String key,boolean defaultValue) {
        return Boolean.parseBoolean(getValue(key).orElse(String.valueOf(defaultValue)));

    }

    public static int getInt(String key,int defaultValue) {
        try {
            return Integer.parseInt(getValue( key).orElse(String.valueOf(defaultValue)));
        }catch (NumberFormatException e) {
            Log.e(TAG, "getInt: could not convert key to a integer. Return default value", e);
            return defaultValue;
        }
    }

    private static Optional<String> getValue(String key) {
        try {
            XmlPullParserFactory xmlFactoryObject = XmlPullParserFactory.newInstance();
            XmlPullParser xmlPullParser = xmlFactoryObject.newPullParser();
            xmlPullParser.setInput(new FileInputStream(SHARED_PREFS_PATH.toFile()), null);
            int eventType = xmlPullParser.getEventType();
            while (eventType != XmlPullParser.END_DOCUMENT) {
                if (eventType == XmlPullParser.START_TAG && xmlPullParser.getName() != null
                        && (xmlPullParser.getName().equals("string") || xmlPullParser.getName().equals("boolean"))) {
                    String name = xmlPullParser.getAttributeValue(null, "name");
                    if (key.equals(name)) {
                        xmlPullParser.next();
                        if(xmlPullParser.getText() != null)
                            return Optional.of(xmlPullParser.getText());
                        return Optional.of(xmlPullParser.getAttributeValue(null, "value"));
                    }
                }
                eventType = xmlPullParser.next();
            }
        } catch (FileNotFoundException e) {
            Log.w("ConfigUtil", "Could not read preferences file: " + SHARED_PREFS_PATH);
        } catch (IOException | XmlPullParserException e) {
            Log.w("ConfigUtil", "Error reading preferences: " + e.getMessage());
        }
        return Optional.empty();
    }
}
