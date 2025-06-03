import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;
import '../../domain/entities/task_entity.dart';
import 'package:get/get.dart';

class DatabaseService extends GetxService {
  static Database? _database;
  
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final pathToDb = path.join(dbPath, 'tasks.db');

    return await openDatabase(
      pathToDb,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE tasks(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            uuid TEXT UNIQUE,
            title TEXT,
            description TEXT,
            dateTime TEXT,
            isCompleted INTEGER,
            repeatDays TEXT,
            alarmSound TEXT,
            streakCount INTEGER,
            lastCompletedAt TEXT,
            userId TEXT
          )
        ''');
      },
    );
  }

  Future<DatabaseService> init() async {
    await database; // Ensure database is initialized
    return this;
  }

  // Task CRUD Operations
  Future<void> addTask(TaskEntity task) async {
    final db = await database;
    await db.insert(
      'tasks',
      {
        'uuid': task.uuid,
        'title': task.title,
        'description': task.description,
        'dateTime': task.dateTime.toIso8601String(),
        'isCompleted': task.isCompleted ? 1 : 0,
        'repeatDays': task.repeatDays.join(','),
        'alarmSound': task.alarmSound,
        'streakCount': task.streakCount,
        'lastCompletedAt': task.lastCompletedAt.toIso8601String(),
        'userId': task.userId,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateTask(TaskEntity task) async {
    final db = await database;
    await db.update(
      'tasks',
      {
        'title': task.title,
        'description': task.description,
        'dateTime': task.dateTime.toIso8601String(),
        'isCompleted': task.isCompleted ? 1 : 0,
        'repeatDays': task.repeatDays.join(','),
        'alarmSound': task.alarmSound,
        'streakCount': task.streakCount,
        'lastCompletedAt': task.lastCompletedAt.toIso8601String(),
      },
      where: 'uuid = ?',
      whereArgs: [task.uuid],
    );
  }

  Future<void> deleteTask(int id) async {
    final db = await database;
    await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<TaskEntity?> getTask(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return _mapToTask(maps.first);
  }

  Future<List<TaskEntity>> getAllTasks(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: 'userId = ?',
      whereArgs: [userId],
    );

    return List.generate(maps.length, (i) => _mapToTask(maps[i]));
  }

  Future<List<TaskEntity>> getUncompletedTasks(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: 'userId = ? AND isCompleted = 0',
      whereArgs: [userId],
    );

    return List.generate(maps.length, (i) => _mapToTask(maps[i]));
  }

  Future<List<TaskEntity>> getTasksForDate(DateTime date, String userId) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: 'userId = ? AND dateTime BETWEEN ? AND ?',
      whereArgs: [userId, startOfDay.toIso8601String(), endOfDay.toIso8601String()],
    );

    return List.generate(maps.length, (i) => _mapToTask(maps[i]));
  }

  Future<void> markTaskAsCompleted(int id) async {
    final db = await database;
    final task = await getTask(id);
    if (task != null) {
      await db.update(
        'tasks',
        {
          'isCompleted': 1,
          'streakCount': task.streakCount + 1,
          'lastCompletedAt': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [id],
      );
    }
  }

  Future<void> markTaskAsIncomplete(int id) async {
    final db = await database;
    await db.update(
      'tasks',
      {
        'isCompleted': 0,
        'streakCount': 0,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> getTaskStreak(int id) async {
    final task = await getTask(id);
    return task?.streakCount ?? 0;
  }

  Future<void> deleteAllTasks(String userId) async {
    final db = await database;
    await db.delete(
      'tasks',
      where: 'userId = ?',
      whereArgs: [userId],
    );
  }

  TaskEntity _mapToTask(Map<String, dynamic> map) {
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

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
} 