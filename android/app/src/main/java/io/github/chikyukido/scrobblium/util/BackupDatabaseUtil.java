package io.github.chikyukido.scrobblium.util;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.util.Log;

import androidx.documentfile.provider.DocumentFile;

import java.io.BufferedReader;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Locale;

import io.github.chikyukido.scrobblium.MainActivity;
import io.github.chikyukido.scrobblium.MusicListenerService;
import io.github.chikyukido.scrobblium.dao.MethodChannelData;


public class BackupDatabaseUtil {
    private static final String TAG = "BackupDatabaseUtil";

    public static boolean importDatabase(Context context, Uri databaseFile) {
        if (MusicListenerService.getInstance() == null) return false;
        if (MusicListenerService.getInstance().getDatabase() == null) return false;

        Log.i(TAG, "importDatabase: Import file: "+databaseFile);
        MusicListenerService.getInstance().getDatabase().close();
        Log.i(TAG, "importDatabase: closed database connection");
        try {
            Files.deleteIfExists(context.getDataDir().toPath().resolve("databases/song_database"));
            Files.deleteIfExists(context.getDataDir().toPath().resolve("databases/song_database-wal"));
            Files.deleteIfExists(context.getDataDir().toPath().resolve("databases/song_database-shm"));
            Log.i(TAG, "importDatabase: deleted old database");
        } catch (IOException e) {
            Log.e(TAG, "importDatabase: Could not delete database. Maybe do not exists or is still in use", e);
        }

        Path file = context.getDataDir().toPath().resolve("databases/song_database");
        try (FileOutputStream fos = new FileOutputStream(file.toFile());
             InputStream in = context.getContentResolver().openInputStream(databaseFile)) {
            int bytesRead;
            byte[] buffer = new byte[4096];
            while ((bytesRead = in.read(buffer)) != -1) {
                fos.write(buffer, 0, bytesRead);
            }
            Log.i(TAG, "importDatabase: successfully imported database");
        } catch (IOException e) {
            Log.e(TAG, "importDatabase: Error while writing database file", e);
            return false;
        }
        MusicListenerService.getInstance().connectToDatabase();
        Log.i(TAG, "importDatabase: connected to database");
        return true;
    }

    public static boolean exportDatabase(Context context, Uri outputDir) {
        if(!makeWALCheckpoint()) {
            return false;
        }
        Path file = context.getDataDir().toPath().resolve("databases/song_database");
        try (OutputStream os = context.getContentResolver().openOutputStream(outputDir)) {
            os.write(Files.readAllBytes(file));
            Log.i(TAG, "exportDatabase: successfully exported database");
            return true;
        } catch (IOException e) {
            Log.e(TAG, "exportDatabase: Could not export database", e);
            return false;
        }
    }


    public static boolean saveBackupDatabasePath(Context context, Uri path) {
        String filename = "backup_uri.txt";
        String data = path.toString();
        try {
            FileOutputStream fos = context.openFileOutput(filename, Context.MODE_PRIVATE);
            fos.write(data.getBytes());
            fos.close();
            Log.i(TAG, "saveBackupDatabasePath: BackupDatabasePath saved successfully.");
            return true;
        } catch (IOException e) {
            Log.e(TAG, "saveBackupDatabasePath: Error saving BackupDatabasePath: " + e.getMessage());
            return false;
        }
    }

    public static String backupDatabase(Context context) {
        Uri backupDatabasePath = readBackupDatabasePath(context);
        if (backupDatabasePath == null) return "No backup path set";

        DocumentFile docFile = DocumentFile.fromTreeUri(context,backupDatabasePath);
        if(docFile == null) {
            return "Backup path is invalid";
        }
        DocumentFile[] allFiles = docFile.listFiles();
        List<DocumentFile> currentBackups = new ArrayList<>();
        for (DocumentFile file : allFiles) {
            if(file.isDirectory()) continue;
            if(file.getName() == null) continue;
            if(!file.getName().contains(".db")) continue;
            currentBackups.add(file);
        }

        if(currentBackups.size() >= 3) {
            DocumentFile oldest = currentBackups.get(0);
            for (int i = 1;i<currentBackups.size();i++) {
                if(currentBackups.get(i).lastModified() < oldest.lastModified()) {
                    oldest = currentBackups.get(i);
                }
            }
            Log.i(TAG, "backupDatabase: More than 3 backups found delete one");
            oldest.delete();
        }

        String fileName = new SimpleDateFormat("yyyyMMdd", Locale.getDefault()).format(new Date()) + ".db";
        if(docFile.findFile(fileName) == null) {
            DocumentFile fileToWrite = docFile.createFile("application/vnd.sqlite3",fileName);
            if(fileToWrite == null) {
                Log.w(TAG, "backupDatabase: Could not write document because could not create file");
                return "Could not write database";
            }
            exportDatabase(context,fileToWrite.getUri());
        }else {
            Log.i(TAG, "backupDatabase: Already found a file with the same name. Overwrite it");
            exportDatabase(context,docFile.findFile(fileName).getUri());
        }
        Log.i(TAG, "backupDatabase: Successfully created a backup");
        return null;
    }

    public static Uri readBackupDatabasePath(Context context) {
        Uri backupDatabasePath = null;
        try {
            FileInputStream fis = context.openFileInput("backup_uri.txt");
            InputStreamReader isr = new InputStreamReader(fis);
            BufferedReader br = new BufferedReader(isr);
            String path = br.readLine();
            if (path != null && !path.isEmpty()) {
                backupDatabasePath = Uri.parse(path.trim());
            }
            br.close();
            isr.close();
            fis.close();
        } catch (IOException e) {
            Log.e("BackupHelper", "Error reading backup database path: " + e.getMessage());
        }
        return backupDatabasePath;
    }
    public static void launchDirectoryChooserForExport(Context context,MethodChannelData data) {
        MainActivity.activityResultCallbacks.put(data.getCallbackId(),(c, intent, resultCode) -> {
            if(resultCode != Activity.RESULT_OK && intent != null && intent.getData() != null) {
                data.setDataAsString("Could not start the export of the database");
                data.reply();
                return;
            }
            if(exportDatabase(c, intent.getData()))
                data.setDataAsString("Export database successfully");
            else
                data.setDataAsString("Smth went wrong exporting the database");
            data.reply();
        });
        Intent intent = new Intent(Intent.ACTION_CREATE_DOCUMENT)
                .addCategory(Intent.CATEGORY_OPENABLE)
                .setType("data/json")
                .putExtra(Intent.EXTRA_TITLE, "song_database");
        ((Activity) context).startActivityForResult(intent, data.getCallbackId());
    }

    public static void launchFileChooserForImport(Context context,MethodChannelData data) {
        MainActivity.activityResultCallbacks.put(data.getCallbackId(),(c, intent, resultCode) -> {
            if(resultCode != Activity.RESULT_OK && intent != null && intent.getData() != null) {
                data.setDataAsString("Could not start the import of the database");
                data.reply();
                return;
            }
            if(importDatabase(c, intent.getData()))
                data.setDataAsString("Imported database successfully");
            else
                data.setDataAsString("Smth went wrong importing the database");
            data.reply();
        });
        Intent intent = new Intent(Intent.ACTION_GET_CONTENT);
        intent.addCategory(Intent.CATEGORY_OPENABLE);
        intent.setType("*/*");
        ((Activity) context).startActivityForResult(intent, data.getCallbackId());
    }

    public static void launchFileChooserForBackup(Context context, MethodChannelData data) {
        MainActivity.activityResultCallbacks.put(data.getCallbackId(),(c, intent, resultCode) -> {
            if(resultCode != Activity.RESULT_OK && intent != null && intent.getData() != null) {
                data.setDataAsString("Could set backup path");
                data.reply();
                return;
            }
            if(!saveBackupDatabasePath(c, intent.getData())) {
                data.setDataAsString("Could not save backup path");
                data.reply();
                return;
            }
            data.setDataAsString("Backup path successfully set");
            c.getContentResolver().takePersistableUriPermission(intent.getData(),
                    Intent.FLAG_GRANT_READ_URI_PERMISSION | Intent.FLAG_GRANT_WRITE_URI_PERMISSION);
            data.reply();
        });
        Intent intent = new Intent(Intent.ACTION_OPEN_DOCUMENT_TREE);
        ((Activity) context).startActivityForResult(intent, data.getCallbackId());
    }

    public static boolean makeWALCheckpoint() {
        if (MusicListenerService.getInstance() == null) return false;
        if (MusicListenerService.getInstance().getDatabase() != null) {
            MusicListenerService.getInstance().getDatabase().close();
        }
        MusicListenerService.getInstance().connectToDatabase();
        Log.i("BackupDatabaseUtil", "makeWALCheckpoint: checkpoint for database");
        return true;
    }
}
