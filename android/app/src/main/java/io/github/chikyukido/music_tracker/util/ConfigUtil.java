package io.github.chikyukido.music_tracker.util;

import android.content.Context;
import android.util.Log;

import org.xmlpull.v1.XmlPullParser;
import org.xmlpull.v1.XmlPullParserException;
import org.xmlpull.v1.XmlPullParserFactory;

import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

public class ConfigUtil {
    public static String getMusicPackage(Context context)  {
        try {
            XmlPullParserFactory xmlFactoryObject = XmlPullParserFactory.newInstance();
            XmlPullParser xmlPullParser = xmlFactoryObject.newPullParser();
            Path file = context.getDataDir().toPath().resolve("shared_prefs/FlutterSharedPreferences.xml");
            xmlPullParser.setInput(new FileInputStream(file.toFile()), null);
            int eventType = xmlPullParser.getEventType();
            while (eventType != XmlPullParser.END_DOCUMENT) {
                if (eventType == XmlPullParser.START_TAG && xmlPullParser.getName().equals("string")) {
                    String name = xmlPullParser.getAttributeValue(null, "name");
                    if ("flutter.music-app-package".equals(name)) {
                        xmlPullParser.next();
                        return xmlPullParser.getText();
                    }
                }
                eventType = xmlPullParser.next();
            }
            return "";
        }catch (FileNotFoundException e) {
            Log.w("ConfigUtil","Could not get the MusicPackage. XML files does not exists");
            return "";
        } catch (IOException | XmlPullParserException e) {
            Log.w("ConfigUtil","Could not get the MusicPackage. "+ e.getMessage());
            return "";
        }
    }
}
