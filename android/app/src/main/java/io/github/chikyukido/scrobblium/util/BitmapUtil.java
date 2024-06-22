package io.github.chikyukido.scrobblium.util;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Matrix;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.util.Log;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

public class BitmapUtil {

    private static final int IMAGE_RESOLUTION = 100;

    public static Bitmap drawableToBitmap (Drawable drawable) {
        Bitmap bitmap;

        if (drawable instanceof BitmapDrawable) {
            BitmapDrawable bitmapDrawable = (BitmapDrawable) drawable;
            if(bitmapDrawable.getBitmap() != null) {
                return bitmapDrawable.getBitmap();
            }
        }

        if(drawable.getIntrinsicWidth() <= 0 || drawable.getIntrinsicHeight() <= 0) {
            bitmap = Bitmap.createBitmap(1, 1, Bitmap.Config.ARGB_8888);
        } else {
            bitmap = Bitmap.createBitmap(drawable.getIntrinsicWidth(), drawable.getIntrinsicHeight(), Bitmap.Config.ARGB_8888);
        }

        Canvas canvas = new Canvas(bitmap);
        drawable.setBounds(0, 0, canvas.getWidth(), canvas.getHeight());
        drawable.draw(canvas);
        return bitmap;
    }
    public static Bitmap scaleBitmap(Bitmap bitmap, int newWidth, int newHeight) {
        int width = bitmap.getWidth();
        int height = bitmap.getHeight();

        float scaleWidth = ((float) newWidth) / width;
        float scaleHeight = ((float) newHeight) / height;

        Matrix matrix = new Matrix();
        matrix.postScale(scaleWidth, scaleHeight);

        return Bitmap.createBitmap(bitmap, 0, 0, width, height, matrix, false);
    }
    public static boolean saveBitmapAsPNG(Context context, Bitmap bitmap, String filename) {
        if(bitmap == null) {
            return false;
        }

        Bitmap scaledBitmap = scaleBitmap(bitmap, IMAGE_RESOLUTION, IMAGE_RESOLUTION);

        Path path = Paths.get(context.getCacheDir() + "/arts");
        if (!Files.exists(path)) {
            try {
                Files.createDirectories(path);
            } catch (IOException e) {
                Log.e("BitmapUtil", "Could not create directory because: " + e.getMessage());
                return false;
            }
        }

        File file = path.resolve(filename).toFile();
        FileOutputStream fos = null;
        try {
            fos = new FileOutputStream(file);
            scaledBitmap.compress(Bitmap.CompressFormat.PNG, 100, fos);
            fos.flush();
            return true;
        } catch (IOException e) {
            Log.e("BitmapUtil", "Could not write bitmap because: " + e.getMessage());
            return false;
        } finally {
            if (fos != null) {
                try {
                    fos.close();
                } catch (IOException e) {
                    Log.e("BitmapUtil", "Could not close FileOutputStream because: " + e.getMessage());
                }
            }
        }
    }
}
