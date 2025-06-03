class TaskEntity {
  final int id;
  final String uuid;
  final String title;
  final String description;
  final DateTime dateTime;
  final bool isCompleted;
  final List<String> repeatDays;
  final String alarmSound;
  final int streakCount;
  final DateTime lastCompletedAt;
  final String userId;

  TaskEntity({
    this.id = 0,
    required this.uuid,
    required this.title,
    required this.description,
    required this.dateTime,
    this.isCompleted = false,
    this.repeatDays = const [],
    required this.alarmSound,
    this.streakCount = 0,
    DateTime? lastCompletedAt,
    required this.userId,
  }) : lastCompletedAt = lastCompletedAt ?? DateTime.now();

  TaskEntity copyWith({
    int? id,
    String? uuid,
    String? title,
    String? description,
    DateTime? dateTime,
    bool? isCompleted,
    List<String>? repeatDays,
    String? alarmSound,
    int? streakCount,
    DateTime? lastCompletedAt,
    String? userId,
  }) {
    return TaskEntity(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      title: title ?? this.title,
      description: description ?? this.description,
      dateTime: dateTime ?? this.dateTime,
      isCompleted: isCompleted ?? this.isCompleted,
      repeatDays: repeatDays ?? this.repeatDays,
      alarmSound: alarmSound ?? this.alarmSound,
      streakCount: streakCount ?? this.streakCount,
      lastCompletedAt: lastCompletedAt ?? this.lastCompletedAt,
      userId: userId ?? this.userId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uuid': uuid,
      'title': title,
      'description': description,
      'dateTime': dateTime.toIso8601String(),
      'isCompleted': isCompleted ? 1 : 0,
      'repeatDays': repeatDays.join(','),
      'alarmSound': alarmSound,
      'streakCount': streakCount,
      'lastCompletedAt': lastCompletedAt.toIso8601String(),
      'userId': userId,
    };
  }

  factory TaskEntity.fromMap(Map<String, dynamic> map) {
    return TaskEntity(
      id: map['id'] as int,
      uuid: map['uuid'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      dateTime: DateTime.parse(map['dateTime'] as String),
      isCompleted: map['isCompleted'] == 1,
      repeatDays: (map['repeatDays'] as String).split(',').where((s) => s.isNotEmpty).toList(),
      alarmSound: map['alarmSound'] as String,
      streakCount: map['streakCount'] as int,
      lastCompletedAt: DateTime.parse(map['lastCompletedAt'] as String),
      userId: map['userId'] as String,
    );
  }

  bool get isDue {
    final now = DateTime.now();
    return dateTime.isBefore(now) && !isCompleted;
  }

  bool get isRepeating => repeatDays.isNotEmpty;

  DateTime get nextDueDate {
    if (!isRepeating) return dateTime;

    final now = DateTime.now();
    if (dateTime.isAfter(now)) return dateTime;

    final daysOfWeek = {
      'Mon': 1, 'Tue': 2, 'Wed': 3, 'Thu': 4,
      'Fri': 5, 'Sat': 6, 'Sun': 7
    };

    final taskDays = repeatDays.map((day) => daysOfWeek[day]!).toList();
    var nextDate = dateTime;

    while (nextDate.isBefore(now) || !taskDays.contains(nextDate.weekday)) {
      nextDate = nextDate.add(const Duration(days: 1));
    }

    return DateTime(
      nextDate.year,
      nextDate.month,
      nextDate.day,
      dateTime.hour,
      dateTime.minute,
    );
  }
} 