package io.github.chikyukido.scrobblium.util;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.util.Log;
import io.github.chikyukido.scrobblium.MusicListenerService;

import java.io.*;
import java.nio.file.Files;
import java.nio.file.Path;
import java.text.SimpleDateFormat;
import java.util.Date;

public class BackupDatabaseUtil {
    public static final int REQUEST_CODE_PICK_DIRECTORY_EXPORT = 123;
    public static final int REQUEST_CODE_PICK_DIRECTORY_IMPORT = 124;
    public static final int REQUEST_CODE_PICK_DIRECTORY_BACKUP = 125;


    public static void importDatabase(Context context, Uri databaseFile) {
        if (MusicListenerService.getInstance() == null) return;
        if (MusicListenerService.getInstance().getDatabase() == null) return;

        Log.i("test", "importDatabase: "+databaseFile);
        MusicListenerService.getInstance().getDatabase().close();
        try {
            Files.deleteIfExists(context.getDataDir().toPath().resolve("databases/song_database"));
            Files.deleteIfExists(context.getDataDir().toPath().resolve("databases/song_database-wal"));
            Files.deleteIfExists(context.getDataDir().toPath().resolve("databases/song_database-shm"));
        } catch (IOException e) {
            Log.e("BackupDatabaseUtil", "importDatabase: Could not delete database. Maybe do not exists or is still in use", e);
        }
        Path file = context.getDataDir().toPath().resolve("databases/song_database");
        try (FileOutputStream fos = new FileOutputStream(file.toFile());
             InputStream in = context.getContentResolver().openInputStream(databaseFile)) {
            int bytesRead;
            byte[] buffer = new byte[4096];
            while ((bytesRead = in.read(buffer)) != -1) {
                fos.write(buffer, 0, bytesRead);
            }
        } catch (IOException e) {
            Log.e("BackupDatabaseUtil", "importDatabase: Error while writing database file", e);
        }
        MusicListenerService.getInstance().connectToDatabase();
    }

    public static void exportDatabase(Context context, Uri outputDir) {
        makeWALCheckpoint();
        Path file = context.getDataDir().toPath().resolve("databases/song_database");
        try (OutputStream os = context.getContentResolver().openOutputStream(outputDir)) {
            os.write(Files.readAllBytes(file));
        } catch (IOException e) {
            Log.e("BackupDatabaseUtil", "exportDatabase: Could not export database", e);
        }
    }


    public static void saveBackupDatabasePath(Context context, Uri path) {
        String filename = "backup_uri.txt";
        String data = path.toString();
        try {
            FileOutputStream fos = context.openFileOutput(filename, Context.MODE_PRIVATE);
            fos.write(data.getBytes());
            fos.close();
            Log.i("FileHelper", "URI saved successfully.");
        } catch (IOException e) {
            Log.e("FileHelper", "Error saving URI: " + e.getMessage());
        }
        backupDatabase(context);
    }

    public static void backupDatabase(Context context) {
        Uri backupDatabasePath = readBackupDatabasePath(context);
        if (backupDatabasePath == null) return;

        String filename = new SimpleDateFormat("dd.MM.yyyy").format(new Date()) + ".db";

//        exportDatabase(context, backupFileUri);
    }

    public static Uri readBackupDatabasePath(Context context) {
        Uri backupDatabasePath = null;
        try {
            FileInputStream fis = context.openFileInput("backup_uri.txt");
            InputStreamReader isr = new InputStreamReader(fis);
            BufferedReader br = new BufferedReader(isr);
            String path = br.readLine();
            if (path != null && !path.isEmpty()) {
                backupDatabasePath = Uri.parse(path);
            }
            br.close();
            isr.close();
            fis.close();
        } catch (IOException e) {
            Log.e("BackupHelper", "Error reading backup database path: " + e.getMessage());
        }
        return backupDatabasePath;
    }
    public static void launchDirectoryChooserForExport(Context context) {
        Intent intent = new Intent(Intent.ACTION_CREATE_DOCUMENT)
                .addCategory(Intent.CATEGORY_OPENABLE)
                .setType("data/json")
                .putExtra(Intent.EXTRA_TITLE, "song_database");
        ((Activity) context).startActivityForResult(intent, REQUEST_CODE_PICK_DIRECTORY_EXPORT);
    }

    public static void launchFileChooserForImport(Context context) {
        Intent intent = new Intent(Intent.ACTION_GET_CONTENT);
        intent.addCategory(Intent.CATEGORY_OPENABLE);
        intent.setType("*/*");
        ((Activity) context).startActivityForResult(intent, REQUEST_CODE_PICK_DIRECTORY_IMPORT);
    }

    public static void launchFileChooserForBackup(Context context) {
        Intent intent = new Intent(Intent.ACTION_OPEN_DOCUMENT_TREE);
        ((Activity) context).startActivityForResult(intent, REQUEST_CODE_PICK_DIRECTORY_BACKUP);
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
