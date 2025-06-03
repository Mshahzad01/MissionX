package com.example.missionx;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.os.PowerManager;
import android.util.Log;

public class AlarmReceiver extends BroadcastReceiver {
    private static final String TAG = "AlarmReceiver";

    @Override
    public void onReceive(Context context, Intent intent) {
        Log.d(TAG, "Alarm received!");

        try {
            // Wake up the device
            PowerManager powerManager = (PowerManager) context.getSystemService(Context.POWER_SERVICE);
            PowerManager.WakeLock wakeLock = powerManager.newWakeLock(
                PowerManager.FULL_WAKE_LOCK |
                PowerManager.ACQUIRE_CAUSES_WAKEUP |
                PowerManager.ON_AFTER_RELEASE,
                "AlarmReceiver::WakeLock"
            );
            wakeLock.acquire(10*60*1000L /*10 minutes*/);

            // Get alarm data
            String title = intent.getStringExtra("title");
            String description = intent.getStringExtra("description");
            int alarmId = intent.getIntExtra("alarmId", 0);

            Log.d(TAG, "Starting AlarmActivity with title: " + title);

            // Start AlarmActivity
            Intent alarmIntent = new Intent(context, AlarmActivity.class);
            alarmIntent.putExtra("title", title);
            alarmIntent.putExtra("description", description);
            alarmIntent.putExtra("alarmId", alarmId);
            alarmIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK |
                               Intent.FLAG_ACTIVITY_CLEAR_TOP |
                               Intent.FLAG_ACTIVITY_SINGLE_TOP);
            context.startActivity(alarmIntent);

            wakeLock.release();
        } catch (Exception e) {
            Log.e(TAG, "Error in AlarmReceiver: " + e.getMessage());
            e.printStackTrace();
        }
    }
} 