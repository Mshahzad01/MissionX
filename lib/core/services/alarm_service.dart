import 'package:flutter/services.dart';
import '../../domain/entities/task_entity.dart';

class AlarmService {
  static const MethodChannel _channel = MethodChannel('alarm_service');

  Future<void> scheduleAlarm(TaskEntity task) async {
    try {
      await _channel.invokeMethod('scheduleAlarm', {
        'timestamp': task.dateTime.millisecondsSinceEpoch,
        'title': task.title,
        'description': task.description,
        'alarmId': task.hashCode,
      });
    } catch (e) {
      print("Error scheduling alarm: $e");
      rethrow;
    }
  }

  Future<void> cancelAlarm(int alarmId) async {
    try {
      await _channel.invokeMethod('cancelAlarm', {
        'alarmId': alarmId,
      });
    } catch (e) {
      print("Error canceling alarm: $e");
      rethrow;
    }
  }
} 