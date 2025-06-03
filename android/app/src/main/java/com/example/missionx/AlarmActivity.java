package com.example.missionx;

import android.app.Activity;
import android.os.Bundle;
import android.view.View;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.TextView;
import android.content.Intent;
import android.app.AlarmManager;
import android.app.PendingIntent;
import android.content.Context;
import android.util.Log;
import android.media.MediaPlayer;
import android.media.AudioManager;
import android.os.Vibrator;
import android.net.Uri;
import android.media.RingtoneManager;
import android.os.Handler;
import android.os.Looper;

public class AlarmActivity extends Activity {
    private static final String TAG = "AlarmActivity";
    private static final int SNOOZE_MINUTES = 5;
    private static final int AUTO_DISMISS_DELAY = 30000; // 30 seconds in milliseconds
    private MediaPlayer mediaPlayer;
    private Vibrator vibrator;
    private Handler autoDissmissHandler;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        
        Log.d(TAG, "Creating AlarmActivity");

        // Set up window flags for full-screen display over lock screen
        getWindow().addFlags(
            WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED |
            WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD |
            WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON |
            WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON |
            WindowManager.LayoutParams.FLAG_ALLOW_LOCK_WHILE_SCREEN_ON
        );

        setContentView(R.layout.activity_alarm);

        // Get alarm data
        String title = getIntent().getStringExtra("title");
        String description = getIntent().getStringExtra("description");
        final int alarmId = getIntent().getIntExtra("alarmId", 0);

        Log.d(TAG, "Showing alarm with title: " + title);

        // Set up UI
        TextView titleText = findViewById(R.id.alarm_title);
        TextView descriptionText = findViewById(R.id.alarm_description);
        Button yesButton = findViewById(R.id.yes_button);
        Button noButton = findViewById(R.id.no_button);

        titleText.setText(title != null ? title : "Task Reminder");
        descriptionText.setText(description != null ? description : "");

        // Start alarm sound and vibration
        startAlarm();

        // Set up auto-dismiss timer
        autoDissmissHandler = new Handler(Looper.getMainLooper());
        autoDissmissHandler.postDelayed(new Runnable() {
            @Override
            public void run() {
                Log.d(TAG, "Auto-dismissing alarm after 30 seconds");
                stopAlarm();
                finish();
            }
        }, AUTO_DISMISS_DELAY);

        yesButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                autoDissmissHandler.removeCallbacksAndMessages(null);
                stopAlarm();
                finish();
            }
        });

        noButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                autoDissmissHandler.removeCallbacksAndMessages(null);
                scheduleSnoozeAlarm(alarmId, title, description);
                stopAlarm();
                finish();
            }
        });
    }

    private void startAlarm() {
        try {
            // Start sound using RingtoneManager for default alarm sound
            Uri alarmSound = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM);
            if (alarmSound == null) {
                alarmSound = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION);
            }
            
            mediaPlayer = new MediaPlayer();
            mediaPlayer.setDataSource(this, alarmSound);
            mediaPlayer.setAudioStreamType(AudioManager.STREAM_ALARM);
            mediaPlayer.setLooping(true);
            mediaPlayer.prepare();
            mediaPlayer.start();

            // Start vibration
            vibrator = (Vibrator) getSystemService(Context.VIBRATOR_SERVICE);
            long[] pattern = {0, 1000, 500, 1000, 500, 1000};
            vibrator.vibrate(pattern, 0);
        } catch (Exception e) {
            Log.e(TAG, "Error starting alarm: " + e.getMessage());
        }
    }

    private void stopAlarm() {
        if (mediaPlayer != null) {
            mediaPlayer.stop();
            mediaPlayer.release();
            mediaPlayer = null;
        }
        if (vibrator != null) {
            vibrator.cancel();
        }
    }

    private void scheduleSnoozeAlarm(int alarmId, String title, String description) {
        try {
            AlarmManager alarmManager = (AlarmManager) getSystemService(Context.ALARM_SERVICE);
            Intent intent = new Intent(this, AlarmReceiver.class);
            intent.putExtra("title", title);
            intent.putExtra("description", description);
            intent.putExtra("alarmId", alarmId);

            PendingIntent pendingIntent = PendingIntent.getBroadcast(
                this,
                alarmId,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE
            );

            long snoozeTime = System.currentTimeMillis() + (SNOOZE_MINUTES * 60 * 1000);
            if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.S) {
                if (alarmManager.canScheduleExactAlarms()) {
                    alarmManager.setAlarmClock(
                        new AlarmManager.AlarmClockInfo(snoozeTime, pendingIntent),
                        pendingIntent
                    );
                } else {
                    alarmManager.setExactAndAllowWhileIdle(
                        AlarmManager.RTC_WAKEUP,
                        snoozeTime,
                        pendingIntent
                    );
                }
            } else {
                alarmManager.setAlarmClock(
                    new AlarmManager.AlarmClockInfo(snoozeTime, pendingIntent),
                    pendingIntent
                );
            }

            Log.d(TAG, "Snooze alarm scheduled for: " + new java.util.Date(snoozeTime).toString());
        } catch (Exception e) {
            Log.e(TAG, "Error scheduling snooze: " + e.getMessage());
        }
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        if (autoDissmissHandler != null) {
            autoDissmissHandler.removeCallbacksAndMessages(null);
        }
        stopAlarm();
    }
} 