package io.github.chikyukido.scrobblium.util;

import android.app.Activity;
import android.content.ContentResolver;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.provider.DocumentsContract;
import android.util.Log;
import io.github.chikyukido.scrobblium.MainActivity;
import io.github.chikyukido.scrobblium.MusicListenerService;
import io.github.chikyukido.scrobblium.dao.MethodChannelData;
import io.github.chikyukido.scrobblium.database.SongData;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.nio.charset.StandardCharsets;
import java.time.LocalDateTime;
import java.time.ZoneOffset;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Locale;
import java.util.zip.ZipEntry;
import java.util.zip.ZipOutputStream;

public class ExportUtil {
    private static final String TAG = "ExportUtil";


    public static void launchFileChooserForExportMaloja(Context context, MethodChannelData data) {
        MainActivity.activityResultCallbacks.put(data.getCallbackId(),(c, intent, resultCode) -> {
            if(resultCode != Activity.RESULT_OK && intent != null && intent.getData() != null) {
                data.setDataAsString("Could not export data for Maloja");
                data.reply();
                return;
            }
            new Thread(() -> {
                ExportInfo exportInfo = exportMaloja(context,intent.getData());
                if(exportInfo == null) {
                    data.setDataAsString("Could not export data for Maloja");
                }else {
                    data.setDataAsString("Successfully create a maloja export\nTook: "
                            + exportInfo.getTime()+"ms\n Exported:"
                            + exportInfo.getAmount());
                }
                data.reply();
            }).start();
        });
        Intent intent = new Intent(Intent.ACTION_OPEN_DOCUMENT_TREE);
        ((Activity) context).startActivityForResult(intent, data.getCallbackId());
    }

    private static ExportInfo exportMaloja(Context context, Uri outputDir) {
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
            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd MMM yyyy HH:mm", Locale.ENGLISH);

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
    public static void launchFileChooserForExportListenBrainz(Context context, MethodChannelData data) {
        MainActivity.activityResultCallbacks.put(data.getCallbackId(), (c, intent, resultCode) -> {
            if (resultCode != Activity.RESULT_OK || intent == null || intent.getData() == null) {
                data.setDataAsString("Could not export data for ListenBrainz");
                data.reply();
                return;
            }
            new Thread(() -> {
                ExportInfo exportInfo = exportListenBrainz(context, intent.getData());
                if (exportInfo == null) {
                    data.setDataAsString("Could not export data for ListenBrainz");
                } else {
                    data.setDataAsString(
                            "Successfully created a ListenBrainz export zip\nTook: "
                                    + exportInfo.getTime() + "ms\nExported: "
                                    + exportInfo.getAmount()
                    );
                }
                data.reply();
            }).start();
        });

        Intent intent = new Intent(Intent.ACTION_OPEN_DOCUMENT_TREE);
        ((Activity) context).startActivityForResult(intent, data.getCallbackId());
    }

    private static ExportInfo exportListenBrainz(Context context, Uri outputDir) {
        if (!BackupDatabaseUtil.makeWALCheckpoint()) {
            return null;
        }

        long startTimeMs = System.currentTimeMillis();
        ExportInfo exportInfo = new ExportInfo();

        String fileName = "listenbrainz_export.zip";
        String mimeType = "application/zip";

        try {
            ContentResolver contentResolver = context.getContentResolver();
            Uri documentUri = DocumentsContract.buildDocumentUriUsingTree(
                    outputDir,
                    DocumentsContract.getTreeDocumentId(outputDir)
            );

            Uri newFileUri = DocumentsContract.createDocument(contentResolver, documentUri, mimeType, fileName);
            if (newFileUri == null) {
                Log.e(TAG, "exportListenBrainz: Could not create new document");
                return null;
            }

            List<SongData> tracks = MusicListenerService.getInstance()
                    .getDatabase()
                    .musicTrackDao()
                    .getAllTracks();

            try (OutputStream os = context.getContentResolver().openOutputStream(newFileUri)) {
                if (os == null) {
                    Log.e(TAG, "exportListenBrainz: OutputStream was null");
                    return null;
                }

                writeKoitoListenBrainzZip(os, tracks, exportInfo);

                exportInfo.setTime(System.currentTimeMillis() - startTimeMs);
                Log.i(TAG, "exportListenBrainz: successfully exported database");
                return exportInfo;

            } catch (IOException e) {
                Log.e(TAG, "exportListenBrainz: Could not write zip", e);
                return null;
            }

        } catch (IOException e) {
            Log.e(TAG, "exportListenBrainz: Could not create zip file", e);
            return null;
        }
    }

    /**
     * Writes a Koito-recognized ListenBrainz export zip:
     *  - contains exactly: listens/listens.jsonl
     *  - each line is one JSON object
     */
    private static void writeKoitoListenBrainzZip(OutputStream out, List<SongData> songDataList, ExportInfo exportInfo)
            throws IOException {

        int exported = 0;

        ByteArrayOutputStream jsonlBuffer = new ByteArrayOutputStream(128 * 1024);

        for (SongData song : songDataList) {
            if(song.getTimeListened() < 240 && (((double) song.getTimeListened()) / ((double) song.getMaxProgress()/1000)) < 0.5) {
                continue;
            }

            String title = nullSafeTrim(song.getTitle());
            String album = nullSafeTrim(song.getAlbum());

            String artist = nullSafeTrim(song.getArtist());
            if (artist == null) artist = nullSafeTrim(song.getAlbumAuthor());

            long listenedAt = computeListenedAtUnixSeconds(song);

            if (title == null || artist == null || listenedAt <= 0) {
                continue;
            }

            String jsonLine = buildListenBrainzJsonLine(song, listenedAt, title, artist, album);
            jsonlBuffer.write(jsonLine.getBytes(StandardCharsets.UTF_8));
            jsonlBuffer.write('\n');

            exported++;
        }

        exportInfo.setAmount(exported);

        try (ZipOutputStream zos = new ZipOutputStream(out)) {
            ZipEntry entry = new ZipEntry("listens/listens.jsonl");
            zos.putNextEntry(entry);
            zos.write(jsonlBuffer.toByteArray());
            zos.closeEntry();
            zos.finish();
        }
    }

    private static long computeListenedAtUnixSeconds(SongData song) {
        LocalDateTime end = song.getEndTime();
        if (end != null) {
            return end.toEpochSecond(ZoneOffset.UTC);
        }
        LocalDateTime start = song.getStartTime();
        if (start == null) return 0L;

        long startSec = start.toEpochSecond(ZoneOffset.UTC);
        int tl = song.getTimeListened();
        if (tl > 0) return startSec + tl;
        return startSec;
    }

    private static String nullSafeTrim(String s) {
        if (s == null) return null;
        String t = s.trim();
        return t.isEmpty() ? null : t;
    }

    private static String buildListenBrainzJsonLine(
            SongData song,
            long listenedAt,
            String title,
            String artist,
            String album
    ) {
        long durationMs = song.getMaxProgress();

        StringBuilder sb = new StringBuilder(512);
        sb.append("{");
        sb.append("\"listened_at\":").append(listenedAt).append(",");
        sb.append("\"track_metadata\":{");
        sb.append("\"artist_name\":").append(jsonString(artist)).append(",");
        sb.append("\"track_name\":").append(jsonString(title)).append(",");
        sb.append("\"release_name\":").append(jsonString(album != null ? album : "")).append(",");
        sb.append("\"additional_info\":{");
        sb.append("\"artist_mbids\":[],");
        sb.append("\"artist_names\":[],");
        sb.append("\"release_group_mbid\":\"\",");
        sb.append("\"release_mbid\":\"\",");
        sb.append("\"recording_mbid\":\"\",");
        sb.append("\"media_player\":\"\",");
        sb.append("\"submission_client\":\"\",");
        sb.append("\"duration\":0,");
        sb.append("\"duration_ms\":").append(durationMs > 0 ? durationMs : 0);
        sb.append("},");
        sb.append("\"mbid_mapping\":{");
        sb.append("\"artist_mbids\":[],");
        sb.append("\"release_mbid\":\"\",");
        sb.append("\"recording_mbid\":\"\",");
        sb.append("\"artists\":[]");
        sb.append("}");
        sb.append("}");
        sb.append("}");
        return sb.toString();
    }

    private static String jsonString(String s) {
        if (s == null) return "\"\"";
        String escaped = s.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r")
                .replace("\t", "\\t");
        return "\"" + escaped + "\"";
    }

   public static class ExportInfo {
        long time;
        long amount;

        public ExportInfo() {}

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
