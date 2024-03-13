package io.github.chikyukido.music_tracker.util;

import android.content.Context;
import android.graphics.Bitmap;
import android.os.Environment;
import android.util.Log;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

public class BitmapUtil {
    public static boolean saveBitmapAsPNG(Context context, Bitmap bitmap, String filename) {
        Path path = Paths.get(context.getCacheDir() + "/arts");
        if (!Files.exists(path)) {
            try {
                Files.createDirectories(path);
            }catch (IOException e) {
                Log.e("BitmapUtil","Could not create directory because: "+e.getMessage());
                return false;
            }
        }

        File file = path.resolve(filename).toFile();
        FileOutputStream fos = null;
        try {
            fos = new FileOutputStream(file);
            bitmap.compress(Bitmap.CompressFormat.PNG, 100, fos);
            fos.flush();
            return true;
        } catch (IOException e) {
            Log.e("BitmapUtil","Could not write bitmap because: "+e.getMessage());
            return false;
        } finally {
            if (fos != null) {
                try {
                    fos.close();
                } catch (IOException e) {
                    Log.e("BitmapUtil","Could not close FileOutputStream because: "+e.getMessage());
                }
            }
        }
    }
}
