package io.github.chikyukido.scrobblium.util;

import android.app.Activity;
import android.content.ContentResolver;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.provider.DocumentsContract;
import android.util.Log;

import java.io.IOException;
import java.io.OutputStream;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.time.format.DateTimeFormatter;
import java.util.List;

import io.github.chikyukido.scrobblium.MusicListenerService;
import io.github.chikyukido.scrobblium.database.SongData;

public class ExportUtil {
    public static final int REQUEST_CODE_PICK_EXPORT_MALOJA = 1125;

    private static final String TAG = "ExportUtil";

    public static ExportInfo exportMaloja(Context context, Uri outputDir) {
        if(!BackupDatabaseUtil.makeWALCheckpoint()) {
            return null;
        }
        long startTime = System.currentTimeMillis();
        String fileName = "malojaExport.csv";
        String mimeType = "text/csv";
        ExportInfo exportInfo = new ExportInfo();
        try {
            ContentResolver contentResolver = context.getContentResolver();
            Uri documentUri = DocumentsContract.buildDocumentUriUsingTree(outputDir,
                    DocumentsContract.getTreeDocumentId(outputDir));
            Uri newFileUri = DocumentsContract.createDocument(contentResolver, documentUri, mimeType, fileName);
            if (newFileUri == null) {
                Log.e(TAG, "exportMaloja: Could not create new document");
                return null;
            }
            try (OutputStream os = context.getContentResolver().openOutputStream(newFileUri)) {
                os.write(convertToCsv(MusicListenerService.getInstance().getDatabase().musicTrackDao().getAllTracks(),exportInfo).getBytes(StandardCharsets.UTF_8));
                Log.i(TAG, "exportMaloja: successfully exported database");
                exportInfo.setTime(System.currentTimeMillis()-startTime);
                return exportInfo;
            } catch (IOException e) {
                Log.e(TAG, "exportMaloja: Could not export database", e);
                return null;
            }
        }catch (IOException e) {
            Log.e(TAG, "exportMaloja: Could not export database", e);
            return null;
        }
    }

    private static String convertToCsv(List<SongData> songDataList,ExportInfo exportInfo) {
        StringBuilder csvBuilder = new StringBuilder();
        int exported = 0;
        for (SongData song : songDataList) {
            if(song.getTimeListened() < 240 && (((double) song.getTimeListened()) / ((double) song.getMaxProgress()/1000)) < 0.5) {
                continue;
            }
            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd MMM yyyy HH:mm");

            csvBuilder.append("\"")
                    .append(song.getArtist()).append("\",\"")
                    .append(song.getAlbum()).append("\",\"")
                    .append(song.getTitle()).append("\",\"")
                    .append(formatter.format(song.getStartTime())).append("\"\n");
            exported++;
        }
        exportInfo.setAmount(exported);

        return csvBuilder.toString();
    }

    public static void launchFileChooserForExportMaloja(Context context) {
        Intent intent = new Intent(Intent.ACTION_OPEN_DOCUMENT_TREE);
        ((Activity) context).startActivityForResult(intent, REQUEST_CODE_PICK_EXPORT_MALOJA);
    }

   public static class ExportInfo {
        long time;
        long amount;

        public ExportInfo() {
        }

        public long getTime() {
            return time;
        }
        public long getAmount() {
            return amount;
        }

        public void setTime(long time) {
            this.time = time;
        }

        public void setAmount(long amount) {
            this.amount = amount;
        }
    }

}
