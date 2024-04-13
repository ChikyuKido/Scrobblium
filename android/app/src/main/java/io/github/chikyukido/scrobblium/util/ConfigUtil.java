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
    private static final String SHARED_PREFS_PATH = "shared_prefs/FlutterSharedPreferences.xml";

    @NonNull
    public static String getString(Context context, String key,String defaultValue) {
        return getValue(context,key).orElse(defaultValue);
    }

    public static boolean getBoolean(Context context, String key,boolean defaultValue) {
        return Boolean.parseBoolean(getValue(context, key).orElse(String.valueOf(defaultValue)));

    }

    public static int getInt(Context context, String key,int defaultValue) {
        try {
            return Integer.parseInt(getValue(context, key).orElse(String.valueOf(defaultValue)));
        }catch (NumberFormatException e) {
            Log.e(TAG, "getInt: could not convert key to a integer. Return default value", e);
            return defaultValue;
        }
    }

    private static Optional<String> getValue(Context context, String key) {
        try {
            XmlPullParserFactory xmlFactoryObject = XmlPullParserFactory.newInstance();
            XmlPullParser xmlPullParser = xmlFactoryObject.newPullParser();
            Path file = context.getDataDir().toPath().resolve(SHARED_PREFS_PATH);
            xmlPullParser.setInput(new FileInputStream(file.toFile()), null);
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
