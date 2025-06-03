import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

class AlarmScreen extends StatefulWidget {
  final String title;
  final String description;
  final int alarmId;

  const AlarmScreen({
    Key? key,
    required this.title,
    required this.description,
    required this.alarmId,
  }) : super(key: key);

  @override
  _AlarmScreenState createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen> {
  @override
  void initState() {
    super.initState();
  }

  void _handleYes() {
    AwesomeNotifications().dismiss(widget.alarmId);
    Get.back();
  }

  void _handleNo() {
    // Schedule for 5 minutes later
    final snoozeTime = DateTime.now().add(const Duration(minutes: 5));
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: widget.alarmId,
        channelKey: 'task_alarm',
        title: widget.title,
        body: widget.description,
        category: NotificationCategory.Alarm,
        autoDismissible: true,
        fullScreenIntent: true,
        wakeUpScreen: true,
        displayOnForeground: true,
        displayOnBackground: true,
        backgroundColor: Colors.deepPurple,
        color: Colors.white,
      ),
      schedule: NotificationCalendar.fromDate(date: snoozeTime),
    );
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Prevent back button
      child: Scaffold(
        backgroundColor: Colors.deepPurple,
        body: SafeArea(
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(20),
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
                    widget.title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    widget.description,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 50),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: _handleYes,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 15,
                          ),
                        ),
                        child: const Text(
                          'YES',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _handleNo,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 15,
                          ),
                        ),
                        child: const Text(
                          'NO',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
} 