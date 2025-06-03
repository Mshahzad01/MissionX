import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/task_entity.dart';
import '../../core/repositories/task_repository.dart';
import '../../core/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../controllers/auth_controller.dart';

class TaskController extends GetxController {
  final TaskRepository taskRepository;
  final NotificationService notificationService;
  final _uuid = const Uuid();

  // Observable state
  final _tasks = <TaskEntity>[].obs;
  final _isLoading = false.obs;
  final _selectedDate = DateTime.now().obs;
  final _error = Rxn<String>();

  // Getters
  List<TaskEntity> get tasks => _tasks;
  List<TaskEntity> get incompleteTasks =>
      _tasks.where((task) => !task.isCompleted).toList();
  List<TaskEntity> get completedTasks =>
      _tasks.where((task) => task.isCompleted).toList();
  bool get isLoading => _isLoading.value;
  DateTime get selectedDate => _selectedDate.value;
  String? get error => _error.value;
  int get totalTasks => _tasks.length;
  int get completedTasksCount => completedTasks.length;
  double get completionRate =>
      totalTasks > 0 ? completedTasksCount / totalTasks : 0.0;

  List<TaskEntity> get currentIncompleteTasks => tasks
      .where(
          (task) => !task.isCompleted && task.dateTime.isAfter(DateTime.now()))
      .toList();

// Overdue/pending tasks (past due date)
  List<TaskEntity> get overdueTasks => tasks
      .where(
          (task) => !task.isCompleted && task.dateTime.isBefore(DateTime.now()))
      .toList();

  TaskController({
    required this.taskRepository,
    required this.notificationService,
  });

  @override
  void onInit() {
    super.onInit();
    loadTasks();
  }

  Future<void> loadTasks() async {
    _isLoading.value = true;
    try {
      final tasks = await taskRepository.getTasksForDate(_selectedDate.value);
      _tasks.assignAll(tasks);
      _error.value = null;
    } catch (e) {
      _error.value = 'Failed to load tasks: ${e.toString()}';
      print(e);
      Get.snackbar(
        'Error',
        'Failed to load tasks',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  void selectDate(DateTime date) {
    _selectedDate.value = date;
    loadTasks();
  }

  void showCustomPopup(String title, String message, bool isSuccess) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSuccess ? Icons.check_circle : Icons.error,
                color: isSuccess ? Colors.green : Colors.red,
                size: 50,
              ),
              const SizedBox(height: 15),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );

    // Auto dismiss after 2 seconds
    Future.delayed(const Duration(seconds: 1), () {
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
    });
  }

  Future<void> createTask({
    required String title,
    required String description,
    required DateTime dateTime,
    List<String> repeatDays = const [],
    String alarmSound = 'default',
  }) async {
    _isLoading.value = true;
    try {
      final authController = Get.find<AuthController>();
      final task = TaskEntity(
        uuid: _uuid.v4(),
        title: title,
        description: description,
        dateTime: dateTime,
        repeatDays: repeatDays,
        alarmSound: alarmSound,
        userId: authController.currentUser?.uid ?? 'offline',
      );

      await taskRepository.createTask(task);
      await notificationService.scheduleTaskAlarm(task);

      // Add task to local list if it's for the selected date
      if (DateUtils.isSameDay(dateTime, _selectedDate.value)) {
        _tasks.add(task);
      }

      _error.value = null;
      Get.back(); // Return to previous screen

      showCustomPopup(
        'Success',
        'Task created successfully!',
        true,
      );

      //await Get.offAllNamed('/home');
    } catch (e) {
      _error.value = 'Failed to create task: ${e.toString()}';
      print(e);
      showCustomPopup(
        'Error',
        'Failed to create task',
        false,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> updateTask(TaskEntity task) async {
    _isLoading.value = true;
    try {
      await taskRepository.updateTask(task);
      await notificationService.scheduleTaskAlarm(task);
      await loadTasks();
      _error.value = null;
    } catch (e) {
      _error.value = 'Failed to update task: ${e.toString()}';
      Get.snackbar(
        'Error',
        'Failed to update task',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> deleteTask(int id) async {
    _isLoading.value = true;
    try {
      await taskRepository.deleteTask(id);
      await notificationService.cancelTaskAlarm(id);
      _tasks.removeWhere((task) => task.id == id);
      _error.value = null;
    } catch (e) {
      _error.value = 'Failed to delete task: ${e.toString()}';
      Get.snackbar(
        'Error',
        'Failed to delete task',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> toggleTaskCompletion(int id) async {
    try {
      final task = _tasks.firstWhere((task) => task.id == id);
      final updatedTask = task.copyWith(
        isCompleted: !task.isCompleted,
        lastCompletedAt: !task.isCompleted ? DateTime.now() : null,
        streakCount: !task.isCompleted ? task.streakCount + 1 : 0,
      );

      final index = _tasks.indexWhere((t) => t.id == id);
      _tasks[index] = updatedTask;
      update();

      if (updatedTask.isCompleted) {
        await taskRepository.markTaskAsCompleted(id);
        await notificationService.cancelTaskAlarm(id);
        showCustomPopup(
          'Success',
          'Task completed successfully!',
          true,
        );
      } else {
        await taskRepository.markTaskAsIncomplete(id);
        if (updatedTask.dateTime.isAfter(DateTime.now())) {
          await notificationService.scheduleTaskAlarm(updatedTask);
        }
        showCustomPopup(
          'Task Incomplete',
          'Task marked as incomplete',
          false,
        );
      }
    } catch (e) {
      print('Error toggling task completion: $e');
      await loadTasks();
      showCustomPopup(
        'Success',
        'Task completed successfully!',
        true,
      );
    }
  }

  Future<int> getTaskStreak(int id) async {
    try {
      return await taskRepository.getTaskStreak(id);
    } catch (e) {
      _error.value = 'Failed to get task streak: ${e.toString()}';
      return 0;
    }
  }

  Future<TaskEntity?> getTaskById(dynamic id) async {
    try {
      final taskId = id is String ? int.tryParse(id) ?? 0 : id as int;
      return taskRepository.getTaskById(taskId);
    } catch (e) {
      _error.value = 'Failed to get task: ${e.toString()}';
      return null;
    }
  }
}

// Current incomplete tasks (not yet due)
// Current incomplete tasks (not yet due)
// import 'package:get/get.dart';

// import 'package:uuid/uuid.dart';

// import '../../domain/entities/task_entity.dart';

// import '../../core/repositories/task_repository.dart';

// import '../../core/services/notification_service.dart';

// import 'package:flutter/material.dart';

// import 'package:intl/intl.dart';

// import '../controllers/auth_controller.dart';

// class TaskController extends GetxController {
//   final TaskRepository taskRepository;

//   final NotificationService notificationService;

//   final _uuid = const Uuid();

//   // Observable state

//   final _tasks = <TaskEntity>[].obs;

//   final _isLoading = false.obs;

//   final _selectedDate = DateTime.now().obs;

//   final _error = Rxn<String>();

//   // Getters

//   List<TaskEntity> get tasks => _tasks;

//   List<TaskEntity> get incompleteTasks =>
//       _tasks.where((task) => !task.isCompleted).toList();

//   List<TaskEntity> get completedTasks =>
//       _tasks.where((task) => task.isCompleted).toList();

//   bool get isLoading => _isLoading.value;

//   DateTime get selectedDate => _selectedDate.value;

//   String? get error => _error.value;

//   int get totalTasks => _tasks.length;

//   int get completedTasksCount => completedTasks.length;

//   double get completionRate =>
//       totalTasks > 0 ? completedTasksCount / totalTasks : 0.0;

//   // Current incomplete tasks (not yet due)

//   List<TaskEntity> get currentIncompleteTasks => tasks
//       .where(
//           (task) => !task.isCompleted && task.dateTime.isAfter(DateTime.now()))
//       .toList();

//   // Overdue/pending tasks (past due date)

//   List<TaskEntity> get overdueTasks => tasks
//       .where(
//           (task) => !task.isCompleted && task.dateTime.isBefore(DateTime.now()))
//       .toList();

//   TaskController({
//     required this.taskRepository,
//     required this.notificationService,
//   });

//   @override
//   void onInit() {
//     super.onInit();

//     loadTasks();
//   }

//   Future<void> loadTasks() async {
//     _isLoading.value = true;

//     try {
//       final tasks = await taskRepository.getTasksForDate(_selectedDate.value);

//       _tasks.assignAll(tasks);

//       _error.value = null;
//     } catch (e) {
//       _error.value = 'Failed to load tasks: ${e.toString()}';

//       print(e);

//       Get.snackbar(
//         'Error',
//         'Failed to load tasks',
//         snackPosition: SnackPosition.TOP,
//         backgroundColor: Colors.red.shade400,
//         colorText: Colors.white,
//       );
//     } finally {
//       _isLoading.value = false;
//     }
//   }

//   void selectDate(DateTime date) {
//     _selectedDate.value = date;

//     loadTasks();
//   }

//   Future<void> createTask({
//     required String title,
//     required String description,
//     required DateTime dateTime,
//     List<String> repeatDays = const [],
//     String alarmSound = 'default',
//   }) async {
//     _isLoading.value = true;

//     try {
//       final authController = Get.find<AuthController>();

//       final task = TaskEntity(
//         uuid: _uuid.v4(),
//         title: title,
//         description: description,
//         dateTime: dateTime,
//         repeatDays: repeatDays,
//         alarmSound: alarmSound,
//         userId: authController.currentUser?.uid ?? 'offline',
//       );

//       await taskRepository.createTask(task);

//       await notificationService.scheduleTaskAlarm(task);

//       // Add task to local list if it's for the selected date

//       if (DateUtils.isSameDay(dateTime, _selectedDate.value)) {
//         _tasks.add(task);
//       }

//       _error.value = null;

//       Get.back(); // Return to previous screen

//       Get.snackbar(
//         'Success',
//         'Task created successfully',
//         snackPosition: SnackPosition.TOP,
//         backgroundColor: Colors.green.shade400,
//         colorText: Colors.white,
//       );
//     } catch (e) {
//       _error.value = 'Failed to create task: ${e.toString()}';

//       print(e);

//       Get.snackbar(
//         'Error',
//         'Failed to create task',
//         snackPosition: SnackPosition.TOP,
//         backgroundColor: Colors.red.shade400,
//         colorText: Colors.white,
//       );
//     } finally {
//       _isLoading.value = false;
//     }
//   }

//   Future<void> updateTask(TaskEntity task) async {
//     _isLoading.value = true;

//     try {
//       await taskRepository.updateTask(task);

//       await notificationService.scheduleTaskAlarm(task);

//       await loadTasks();

//       _error.value = null;
//     } catch (e) {
//       _error.value = 'Failed to update task: ${e.toString()}';

//       Get.snackbar(
//         'Error',
//         'Failed to update task',
//         snackPosition: SnackPosition.TOP,
//         backgroundColor: Colors.red.shade400,
//         colorText: Colors.white,
//       );
//     } finally {
//       _isLoading.value = false;
//     }
//   }

//   Future<void> deleteTask(int id) async {
//     _isLoading.value = true;

//     try {
//       await taskRepository.deleteTask(id);

//       await notificationService.cancelTaskAlarm(id);

//       _tasks.removeWhere((task) => task.id == id);

//       _error.value = null;
//     } catch (e) {
//       _error.value = 'Failed to delete task: ${e.toString()}';

//       Get.snackbar(
//         'Error',
//         'Failed to delete task',
//         snackPosition: SnackPosition.TOP,
//         backgroundColor: Colors.red.shade400,
//         colorText: Colors.white,
//       );
//     } finally {
//       _isLoading.value = false;
//     }
//   }

//   Future<void> toggleTaskCompletion(int id) async {
//     _isLoading.value = true;

//     try {
//       final task = _tasks.firstWhere((task) => task.id == id);

//       if (task.isCompleted) {
//         await taskRepository.markTaskAsIncomplete(id);

//         await notificationService.scheduleTaskAlarm(task);
//       } else {
//         await taskRepository.markTaskAsCompleted(id);

//         await notificationService.cancelTaskAlarm(id);
//       }

//       await loadTasks();

//       _error.value = null;
//     } catch (e) {
//       _error.value = 'Failed to toggle task completion: ${e.toString()}';

//       Get.snackbar(
//         'Error',
//         'Failed to update task',
//         snackPosition: SnackPosition.TOP,
//         backgroundColor: Colors.red.shade400,
//         colorText: Colors.white,
//       );
//     } finally {
//       _isLoading.value = false;
//     }
//   }

//   Future<int> getTaskStreak(int id) async {
//     try {
//       return await taskRepository.getTaskStreak(id);
//     } catch (e) {
//       _error.value = 'Failed to get task streak: ${e.toString()}';

//       return 0;
//     }
//   }

//   Future<TaskEntity?> getTaskById(dynamic id) async {
//     try {
//       final taskId = id is String ? int.tryParse(id) ?? 0 : id as int;

//       return taskRepository.getTaskById(taskId);
//     } catch (e) {
//       _error.value = 'Failed to get task: ${e.toString()}';

//       return null;
//     }
//   }
// }

// Current incomplete tasks (not yet due)
