import'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'dart:io' show Platform;
import '../../domain/entities/task_entity.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

import '../../presentation/controllers/task_controller.dart';
import '../../presentation/screens/alarm_screen.dart';
import 'alarm_service.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _flutterLocalNotifications =
      FlutterLocalNotificationsPlugin();
  final AlarmService _alarmService = AlarmService();

  static const int insistentFlag = 4; // Android's FLAG_INSISTENT
  static final List<int> highVibrationPattern = List<int>.from([0, 1000, 500, 1000, 500, 1000, 500, 1000]);

  // Static methods for handling background notifications
  @pragma('vm:entry-point')
  static Future<void> onActionReceivedMethod(ReceivedAction receivedAction) async {
    if (receivedAction.buttonKeyPressed == "YES") {
      // Just dismiss the notification
      await AwesomeNotifications().dismiss(receivedAction.id!);
    } else if (receivedAction.buttonKeyPressed == "NO") {
      // Schedule a new notification for 5 minutes later
      final snoozeTime = DateTime.now().add(const Duration(minutes: 5));
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: receivedAction.id!,
          channelKey: 'task_alarm',
          title: receivedAction.title,
          body: receivedAction.body,
          category: NotificationCategory.Alarm,
          autoDismissible: false,
          displayOnForeground: true,
          displayOnBackground: true,
          fullScreenIntent: true,
          wakeUpScreen: true,
          criticalAlert: true,
          locked: true,
          notificationLayout: NotificationLayout.BigText,
          backgroundColor: Colors.deepPurple,
          color: Colors.white,
          payload: receivedAction.payload,
        ),
        actionButtons: [
          NotificationActionButton(
            key: 'YES',
            label: 'Yes',
            actionType: ActionType.DismissAction,
            color: Colors.green,
            showInCompactView: true,
            autoDismissible: true,
          ),
          NotificationActionButton(
            key: 'NO',
            label: 'No',
            color: Colors.red,
            showInCompactView: true,
            autoDismissible: false,
          ),
        ],
        schedule: NotificationCalendar.fromDate(date: snoozeTime),
      );
    }
  }

  @pragma('vm:entry-point')
  static Future<void> onNotificationCreatedMethod(ReceivedNotification receivedNotification) async {
    // Handle notification creation
  }

  @pragma('vm:entry-point')
  static Future<void> onNotificationDisplayedMethod(ReceivedNotification receivedNotification) async {
    // Show full-screen alarm dialog
    Get.dialog(
      WillPopScope(
        onWillPop: () async => false,
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: EdgeInsets.zero,
          child: Container(
            width: Get.width,
            height: Get.height,
            color: Colors.black.withOpacity(0.9),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.alarm,
                  size: 80,
                  color: Colors.white,
                ),
                const SizedBox(height: 30),
                Text(
                  receivedNotification.title ?? 'Task Alarm',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    receivedNotification.body ?? '',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 20,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 50),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Get.back();
                        AwesomeNotifications().dismiss(receivedNotification.id ?? 0);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 15,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'YES',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Get.back();
                        // Schedule for 5 minutes later
                        final snoozeTime = DateTime.now().add(const Duration(minutes: 5));
                        AwesomeNotifications().createNotification(
                          content: NotificationContent(
                            id: receivedNotification.id ?? 0,
                            channelKey: 'task_alarm',
                            title: receivedNotification.title,
                            body: receivedNotification.body,
                            category: NotificationCategory.Alarm,
                            fullScreenIntent: true,
                            wakeUpScreen: true,
                            autoDismissible: false,
                            displayOnForeground: false,
                            displayOnBackground: false,
                            backgroundColor: Colors.deepPurple,
                            color: Colors.white,
                            customSound: 'resource://raw/alarm',
                            criticalAlert: true,
                            showWhen: false,
                            locked: true,
                            notificationLayout: NotificationLayout.Messaging,
                          ),
                          schedule: NotificationCalendar.fromDate(date: snoozeTime),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 15,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'NO',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
      useSafeArea: false,
    );

    // Auto dismiss after 30 seconds
    Future.delayed(const Duration(seconds: 30), () {
      Get.back();
      AwesomeNotifications().dismiss(receivedNotification.id ?? 0);
    });
  }

  @pragma('vm:entry-point')
  static Future<void> onDismissActionReceivedMethod(ReceivedAction receivedAction) async {
    // Handle notification dismissal
  }

  Future<NotificationService> init() async {
    // Initialize timezone
    tz.initializeTimeZones();

    // Request permissions first
    await requestPermissions();

    // Initialize Flutter Local Notifications
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _flutterLocalNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Initialize Awesome Notifications for full-screen alarms
    await AwesomeNotifications().initialize(
      'resource://drawable/notification_icon',
      [
        NotificationChannel(
          channelKey: 'task_alarm',
          channelName: 'Task Alarms',
          channelDescription: 'Channel for task alarms and reminders',
          defaultColor: Colors.deepPurple,
          ledColor: Colors.white,
          importance: NotificationImportance.Max,
          defaultPrivacy: NotificationPrivacy.Secret,
          defaultRingtoneType: DefaultRingtoneType.Alarm,
          playSound: true,
          enableVibration: true,
          vibrationPattern: Int64List.fromList(highVibrationPattern),
          enableLights: true,
          criticalAlerts: true,
          onlyAlertOnce: false,
          channelShowBadge: false,
          locked: true,
        ),
      ],
    );

    // Set up background action handlers
    await AwesomeNotifications().setListeners(
      onActionReceivedMethod: onActionReceivedMethod,
      onNotificationCreatedMethod: onNotificationCreatedMethod,
      onNotificationDisplayedMethod: onNotificationDisplayedMethod,
      onDismissActionReceivedMethod: onDismissActionReceivedMethod,
    );

    return this;
  }

  void _onNotificationTap(NotificationResponse response) {
    if (response.payload != null) {
      try {
        final payload = jsonDecode(response.payload!) as Map<String, dynamic>;
        Get.defaultDialog(
          title: payload['title']?.toString() ?? "Notification",
          middleText: payload['description']?.toString() ?? "No Description",
          textConfirm: "OK",
          textCancel: "Cancel",
          confirmTextColor: Colors.white,
          buttonColor: Colors.deepPurple,
          backgroundColor: Colors.white,
          titleStyle: const TextStyle(
            color: Colors.deepPurple,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
          middleTextStyle: const TextStyle(
            fontSize: 16,
          ),
          radius: 12,
          onConfirm: () async {
            Get.back(); // Close dialog
            if (payload.containsKey('task_id')) {
              final taskController = Get.find<TaskController>();
              final task = await taskController.getTaskById(payload['task_id'].toString());
              if (task != null) {
                Get.toNamed('/task-detail', arguments: task);
              }
            }
          },
          onCancel: () {
            Get.back(); // Close dialog
          },
        );
      } catch (e) {
        print('Error parsing payload: $e');
        Get.snackbar(
          'Error',
          'Failed to parse notification payload',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  Future<void> requestPermissions() async {
    if (Platform.isAndroid) {
      // Request all required permissions
      await Future.wait([
        Permission.notification.request(),
        Permission.scheduleExactAlarm.request(),
        Permission.systemAlertWindow.request(),
      ]);

      // Check if permissions are granted
      final notificationStatus = await Permission.notification.status;
      final alarmStatus = await Permission.scheduleExactAlarm.status;
      final overlayStatus = await Permission.systemAlertWindow.status;

      if (notificationStatus.isDenied || alarmStatus.isDenied || overlayStatus.isDenied) {
        Get.snackbar(
          'Permissions Required',
          'Please enable all required permissions for the app to work properly',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
          mainButton: TextButton(
            onPressed: () async {
              await openAppSettings();
            },
            child: const Text(
              'SETTINGS',
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
      }
    }
  }

  Future<void> scheduleTaskAlarm(TaskEntity task) async {
    if (Platform.isAndroid) {
      // Check for required permissions
      final hasAlarmPermission = await Permission.scheduleExactAlarm.isGranted;
      final hasNotificationPermission = await Permission.notification.isGranted;
      final hasOverlayPermission = await Permission.systemAlertWindow.isGranted;

      if (!hasAlarmPermission || !hasNotificationPermission || !hasOverlayPermission) {
        Get.snackbar(
          'Permissions Required',
          'Please grant all required permissions in settings',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
          mainButton: TextButton(
            onPressed: () async {
              await openAppSettings();
            },
            child: const Text(
              'SETTINGS',
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
        return;
      }

      try {
        // Calculate the exact timestamp for the alarm
        final now = DateTime.now();
        final scheduledTime = DateTime(
          task.dateTime.year,
          task.dateTime.month,
          task.dateTime.day,
          task.dateTime.hour,
          task.dateTime.minute,
        );

        // Only schedule if the time is in the future
        if (scheduledTime.isAfter(now)) {
          print('Scheduling alarm for: ${task.dateTime}');
          await _alarmService.scheduleAlarm(task);
          
          // Show confirmation
          Get.snackbar(
            'Alarm Scheduled',
            'Task alarm set for ${DateFormat('MMM dd, yyyy HH:mm').format(scheduledTime)}',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
          );
        } else {
          print('Cannot schedule alarm for past time: ${task.dateTime}');
          Get.snackbar(
            'Invalid Time',
            'Cannot schedule alarm for past time',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } catch (e) {
        print('Error scheduling alarm: $e');
        Get.snackbar(
          'Error',
          'Failed to schedule alarm: ${e.toString()}',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  Future<void> cancelTaskAlarm(int taskId) async {
    await _alarmService.cancelAlarm(taskId);
    await AwesomeNotifications().cancel(taskId);
  }

  DateTimeComponents? _getDateTimeComponents(List<String> repeatDays) {
    if (repeatDays.isEmpty) return null;
    if (repeatDays.length == 7) return DateTimeComponents.time;
    return DateTimeComponents.dayOfWeekAndTime;
  }

  int? _getWeekday(List<String> repeatDays) {
    if (repeatDays.isEmpty) return null;
    final weekdays = {
      'Mon': 1,
      'Tue': 2,
      'Wed': 3,
      'Thu': 4,
      'Fri': 5,
      'Sat': 6,
      'Sun': 7,
    };
    return weekdays[repeatDays.first];
  }

  tz.TZDateTime _nextInstanceOfTime(DateTime dateTime) {
    final now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      dateTime.year,
      dateTime.month,
      dateTime.day,
      dateTime.hour,
      dateTime.minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }
} 