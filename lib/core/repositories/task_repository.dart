import '../../domain/entities/task_entity.dart';
import '../../data/local/database_service.dart';


class TaskRepository {
  final DatabaseService _databaseService;
  final String userId;

  TaskRepository({
    required DatabaseService databaseService,
    required this.userId,
  }) : _databaseService = databaseService;

  // Task CRUD Operations
  Future<void> createTask(TaskEntity task) async {
    await _databaseService.addTask(task);
  }

  Future<void> updateTask(TaskEntity task) async {
    await _databaseService.updateTask(task);
  }

  Future<void> deleteTask(int id) async {
    await _databaseService.deleteTask(id);
  }

  Future<TaskEntity?> getTaskById(int id) async {
    return _databaseService.getTask(id);
  }

  Future<List<TaskEntity>> getTasksForDate(DateTime date) async {
    return _databaseService.getTasksForDate(date, userId);
  }

  // Task Status Operations
  Future<void> markTaskAsCompleted(int id) async {
    await _databaseService.markTaskAsCompleted(id);
  }

  Future<void> markTaskAsIncomplete(int id) async {
    await _databaseService.markTaskAsIncomplete(id);
  }

  // Streak Operations
  Future<int> getTaskStreak(int id) async {
    return await _databaseService.getTaskStreak(id);
  }

  // Cleanup Operations
  Future<void> deleteAllTasks() async {
    await _databaseService.deleteAllTasks(userId);
  }
} 