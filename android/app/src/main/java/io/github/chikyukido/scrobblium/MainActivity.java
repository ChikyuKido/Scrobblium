package io.github.chikyukido.scrobblium;

import android.app.Activity;
import android.content.Intent;
import android.util.Log;

import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import io.github.chikyukido.scrobblium.intergrations.IntegrationHandler;
import io.github.chikyukido.scrobblium.util.BackupDatabaseUtil;
import io.github.chikyukido.scrobblium.util.ExportUtil;
import io.github.chikyukido.scrobblium.util.MethodChannelUtil;

import static io.github.chikyukido.scrobblium.util.BackupDatabaseUtil.*;
import static io.github.chikyukido.scrobblium.util.ExportUtil.REQUEST_CODE_PICK_EXPORT_MALOJA;

import java.util.concurrent.atomic.AtomicBoolean;
import java.util.concurrent.atomic.AtomicReference;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "MusicListener";

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        IntegrationHandler.getInstance().init(getApplicationContext());
        MethodChannelUtil.configureMethodChannel(new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL), this);


    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        //catching activity results for the backups cause its using the main activities context.
        if (resultCode == Activity.RESULT_OK) {
            if (data != null && data.getData() != null) {
                if (requestCode == REQUEST_CODE_PICK_DIRECTORY_EXPORT) {
                    if(BackupDatabaseUtil.exportDatabase(getApplicationContext(), data.getData()))
                        MethodChannelUtil.showToast("Exported database successfully");
                    else
                        MethodChannelUtil.showToast("Smth went wrong exporting the database");
                } else if (requestCode == REQUEST_CODE_PICK_DIRECTORY_IMPORT) {
                    if(BackupDatabaseUtil.importDatabase(getApplicationContext(), data.getData()))
                        MethodChannelUtil.showToast("Imported database successfully");
                    else
                        MethodChannelUtil.showToast("Smth went wrong importing the database");
                } else if(requestCode == REQUEST_CODE_PICK_DIRECTORY_BACKUP) {
                    if(!BackupDatabaseUtil.saveBackupDatabasePath(getApplicationContext(), data.getData())) {
                        MethodChannelUtil.showToast("Could not save backup path");
                        return;
                    }
                    MethodChannelUtil.showToast("Backup path successfully set");
                    getContext().getContentResolver().takePersistableUriPermission(data.getData(),
                            Intent.FLAG_GRANT_READ_URI_PERMISSION | Intent.FLAG_GRANT_WRITE_URI_PERMISSION);
                } else if(requestCode == REQUEST_CODE_PICK_EXPORT_MALOJA) {
                    final ExportUtil.ExportInfo[] success = new ExportUtil.ExportInfo[1];
                    Thread t = new Thread(() -> success[0] = ExportUtil.exportMaloja(getApplicationContext(), data.getData()));
                    t.start();
                    try {
                        t.join();
                    } catch (InterruptedException e) {
                        throw new RuntimeException(e);
                    }
                    if(success[0] == null) {
                        MethodChannelUtil.showToast("Could not export for maloja");
                    } else
                        MethodChannelUtil.showToast("Successfully create a maloja export\nTook: "
                                + success[0].getTime()+"ms\n Exported:"
                                + success[0].getAmount());
                    }

            }
        }
    }
}
