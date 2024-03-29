package io.github.chikyukido.scrobblium;

import android.app.Activity;
import android.content.Intent;
import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import io.github.chikyukido.scrobblium.util.BackupDatabaseUtil;
import io.github.chikyukido.scrobblium.util.MethodChannelUtil;

import static io.github.chikyukido.scrobblium.util.BackupDatabaseUtil.*;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "MusicListener";

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        MethodChannelUtil.configureMethodChannel(new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL), this);
    }


    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        //catching activity results for the backups cause its using the main activities context.
        if (resultCode == Activity.RESULT_OK) {
            if (data != null && data.getData() != null) {
                if (requestCode == REQUEST_CODE_PICK_DIRECTORY_EXPORT)
                    BackupDatabaseUtil.exportDatabase(getApplicationContext(), data.getData());
                else if (requestCode == REQUEST_CODE_PICK_DIRECTORY_IMPORT)
                    BackupDatabaseUtil.importDatabase(getApplicationContext(), data.getData());
                else if(requestCode == REQUEST_CODE_PICK_DIRECTORY_BACKUP)
                    BackupDatabaseUtil.saveBackupDatabasePath(getApplicationContext(),data.getData());
            }
        }
    }
}
