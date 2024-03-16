package io.github.chikyukido.scrobblium.util;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.util.Log;
import io.github.chikyukido.scrobblium.MusicListenerService;

import java.io.IOException;
import java.io.OutputStream;
import java.nio.file.Files;
import java.nio.file.Path;

public class BackupDatabaseUtil {
    public static final int REQUEST_CODE_PICK_DIRECTORY_EXPORT = 123;
    public static final int REQUEST_CODE_PICK_DIRECTORY_IMPORT = 124;
    public static final int REQUEST_CODE_PICK_DIRECTORY_BACKUP = 125;

    public static void exportDatabase(Context context,Uri outputDir) {
        makeWALCheckpoint();
        Path file = context.getDataDir().toPath().resolve("databases/song_database");
        Log.i("test", "exportDatabase: "+outputDir);

        try (OutputStream os = context.getContentResolver().openOutputStream(outputDir)){
            os.write(Files.readAllBytes(file));
        } catch (IOException e) {
            Log.e("BackupDatabaseUtil", "exportDatabase: Could not export database", e);
        }
    }
    public static void launchDirectoryChooserForExport(Context context) {
        Intent intent = new Intent(Intent.ACTION_CREATE_DOCUMENT)
                .addCategory(Intent.CATEGORY_OPENABLE)
                .setType("data/json")
                .putExtra(Intent.EXTRA_TITLE,"song_database");
        ((Activity) context).startActivityForResult(intent, REQUEST_CODE_PICK_DIRECTORY_EXPORT);
    }
    public static void makeWALCheckpoint() {
        if (MusicListenerService.getInstance() == null) return;
        if (MusicListenerService.getInstance().getDatabase() != null) {
            MusicListenerService.getInstance().getDatabase().close();
        }
        MusicListenerService.getInstance().connectToDatabase();
        Log.i("BackupDatabaseUtil", "makeWALCheckpoint: checkpoint for database");
    }
}
