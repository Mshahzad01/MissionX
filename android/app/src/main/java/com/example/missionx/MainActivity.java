package com.example.missionx;

import android.app.AlarmManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import java.util.Map;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "alarm_service";

    @Override
    public void configureFlutterEngine(FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
            .setMethodCallHandler((call, result) -> {
                if (call.method.equals("scheduleAlarm")) {
                    try {
                        Map<String, Object> arguments = (Map<String, Object>) call.arguments;
                        long timestamp = ((Number) arguments.get("timestamp")).longValue();
                        String title = (String) arguments.get("title");
                        String description = (String) arguments.get("description");
                        int alarmId = ((Number) arguments.get("alarmId")).intValue();

                        scheduleAlarm(timestamp, title, description, alarmId);
                        result.success(true);
                    } catch (Exception e) {
                        result.error("ALARM_ERROR", "Failed to schedule alarm", e.getMessage());
                    }
                } else if (call.method.equals("cancelAlarm")) {
                    try {
                        int alarmId = call.argument("alarmId");
                        cancelAlarm(alarmId);
                        result.success(true);
                    } catch (Exception e) {
                        result.error("ALARM_ERROR", "Failed to cancel alarm", e.getMessage());
                    }
                } else {
                    result.notImplemented();
                }
            });
    }

    private void scheduleAlarm(long timestamp, String title, String description, int alarmId) {
        try {
            AlarmManager alarmManager = (AlarmManager) getSystemService(Context.ALARM_SERVICE);
            Intent intent = new Intent(this, AlarmReceiver.class);
            intent.putExtra("title", title);
            intent.putExtra("description", description);
            intent.putExtra("alarmId", alarmId);

            // Cancel any existing alarm with the same ID
            PendingIntent existingIntent = PendingIntent.getBroadcast(
                this,
                alarmId,
                intent,
                PendingIntent.FLAG_NO_CREATE | PendingIntent.FLAG_IMMUTABLE
            );
            if (existingIntent != null) {
                alarmManager.cancel(existingIntent);
                existingIntent.cancel();
            }

            // Create new pending intent
            PendingIntent pendingIntent = PendingIntent.getBroadcast(
                this,
                alarmId,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE
            );

            // Ensure the alarm time is in the future
            long currentTime = System.currentTimeMillis();
            if (timestamp <= currentTime) {
                System.out.println("Warning: Alarm time is in the past, adjusting to near future");
                timestamp = currentTime + 5000; // 5 seconds from now
            }

            // Schedule the alarm with high priority
            if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.S) {
                if (alarmManager.canScheduleExactAlarms()) {
                    alarmManager.setAlarmClock(
                        new AlarmManager.AlarmClockInfo(timestamp, pendingIntent),
                        pendingIntent
                    );
                } else {
                    alarmManager.setExactAndAllowWhileIdle(
                        AlarmManager.RTC_WAKEUP,
                        timestamp,
                        pendingIntent
                    );
                }
            } else {
                alarmManager.setAlarmClock(
                    new AlarmManager.AlarmClockInfo(timestamp, pendingIntent),
                    pendingIntent
                );
            }

            System.out.println("Alarm scheduled successfully for: " + new java.util.Date(timestamp).toString());
        } catch (Exception e) {
            System.err.println("Error scheduling alarm: " + e.getMessage());
            e.printStackTrace();
            throw e;
        }
    }

    private void cancelAlarm(int alarmId) {
        AlarmManager alarmManager = (AlarmManager) getSystemService(Context.ALARM_SERVICE);
        Intent intent = new Intent(this, AlarmReceiver.class);
        PendingIntent pendingIntent = PendingIntent.getBroadcast(
            this,
            alarmId,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE
        );
        alarmManager.cancel(pendingIntent);
    }
} 