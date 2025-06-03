import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/task_controller.dart';
import '../../domain/entities/task_entity.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import '../controllers/auth_controller.dart';

class TaskDetailScreen extends StatelessWidget {
  const TaskDetailScreen({super.key});

  TaskEntity? _getTaskFromArguments() {
    final args = Get.arguments;
    if (args is TaskEntity) {
      return args;
    } else if (args is Map<String, dynamic>) {
      try {
        final authController = Get.find<AuthController>();
        return TaskEntity(
          uuid: const Uuid().v4(),
          userId: authController.currentUser?.uid ?? 'offline',
          id: int.tryParse(args['task_id']?.toString() ?? '0') ?? 0,
          title: args['title'] ?? '',
          description: args['description'] ?? '',
          dateTime: DateTime.parse(args['dateTime'] ?? DateTime.now().toIso8601String()),
          isCompleted: (args['isCompleted'] ?? 'false') == 'true',
          repeatDays: (args['repeatDays'] ?? '').split(',').where((day) => day.isNotEmpty).toList(),
          alarmSound: args['alarmSound'] ?? 'default',
          streakCount: int.tryParse(args['streakCount'] ?? '0') ?? 0,
          lastCompletedAt: args['lastCompletedAt'] != null ? DateTime.parse(args['lastCompletedAt']) : null,
        );
      } catch (e) {
        print('Error parsing task from arguments: $e');
        return null;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final taskController = Get.find<TaskController>();
    final task = _getTaskFromArguments();
    final theme = Theme.of(context);

    if (task == null) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.secondary,
              ],
              stops: const [0.0, 0.3],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Task not found',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Go Back'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.secondary,
            ],
            stops: const [0.0, 0.3],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App Bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    ),
                    const Expanded(
                      child: Text(
                        'Task Details',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.white),
                      onPressed: () {
                        Get.toNamed(
                          '/task-creation',
                          arguments: task,
                        )?.then((_) {
                          taskController.loadTasks();
                          Get.back();
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.white),
                      onPressed: () {
                        Get.dialog(
                          AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            title: const Text('Delete Task'),
                            content: const Text('Are you sure you want to delete this task?'),
                            actions: [
                              TextButton(
                                onPressed: () => Get.back(),
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () async {
                                  await taskController.deleteTask(task.id);
                                  Get.back();
                                  Get.back();
                                  Get.snackbar(
                                    'Success',
                                    'Task deleted successfully',
                                    snackPosition: SnackPosition.TOP,
                                    backgroundColor: Colors.green,
                                    colorText: Colors.white,
                                  );
                                },
                                child: const Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title Section
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: task.isCompleted
                                    ? [
                                        Colors.green.withOpacity(0.1),
                                        Colors.green.withOpacity(0.05),
                                      ]
                                    : [
                                        theme.colorScheme.primary.withOpacity(0.1),
                                        theme.colorScheme.secondary.withOpacity(0.05),
                                      ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: task.isCompleted
                                    ? Colors.green.withOpacity(0.3)
                                    : theme.colorScheme.primary.withOpacity(0.3),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: task.isCompleted
                                              ? Colors.green
                                              : theme.colorScheme.primary,
                                          width: 2,
                                        ),
                                      ),
                                      child: Checkbox(
                                        value: task.isCompleted,
                                        onChanged: (_) =>
                                            taskController.toggleTaskCompletion(task.id),
                                        shape: const CircleBorder(),
                                        side: BorderSide.none,
                                        activeColor: Colors.green,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Text(
                                        task.title,
                                        style: GoogleFonts.poppins(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          decoration: task.isCompleted
                                              ? TextDecoration.lineThrough
                                              : null,
                                          color: task.isCompleted
                                              ? Colors.grey
                                              : theme.textTheme.titleLarge?.color,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (task.description.isNotEmpty) ...[
                                  const SizedBox(height: 16),
                                  Text(
                                    task.description,
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      color: theme.textTheme.bodyLarge?.color?.withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Date & Time Section
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: theme.colorScheme.primary.withOpacity(0.1),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.event,
                                      color: theme.colorScheme.primary,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Date & Time',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                ListTile(
                                  leading: Icon(
                                    Icons.calendar_today,
                                    color: theme.colorScheme.primary,
                                  ),
                                  title: Text(
                                    DateFormat('EEEE, MMMM d, y').format(task.dateTime),
                                    style: const TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                ),
                                ListTile(
                                  leading: Icon(
                                    Icons.access_time,
                                    color: theme.colorScheme.primary,
                                  ),
                                  title: Text(
                                    DateFormat('h:mm a').format(task.dateTime),
                                    style: const TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Repeat Section
                          if (task.repeatDays.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: theme.colorScheme.primary.withOpacity(0.1),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.repeat,
                                        color: theme.colorScheme.primary,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Repeats On',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: theme.colorScheme.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: task.repeatDays.map((day) {
                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.primary.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(
                                            color: theme.colorScheme.primary.withOpacity(0.3),
                                          ),
                                        ),
                                        child: Text(
                                          day,
                                          style: TextStyle(
                                            color: theme.colorScheme.primary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ),
                          if (task.repeatDays.isNotEmpty)
                            const SizedBox(height: 24),

                          // Streak Section
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  theme.colorScheme.primary.withOpacity(0.1),
                                  theme.colorScheme.secondary.withOpacity(0.05),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: theme.colorScheme.primary.withOpacity(0.3),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.local_fire_department,
                                      color: theme.colorScheme.primary,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Statistics',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(16),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.05),
                                              blurRadius: 10,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          children: [
                                            Text(
                                              '${task.streakCount}',
                                              style: GoogleFonts.poppins(
                                                fontSize: 32,
                                                fontWeight: FontWeight.bold,
                                                color: theme.colorScheme.primary,
                                              ),
                                            ),
                                            const Text(
                                              'Day Streak',
                                              style: TextStyle(
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (task.lastCompletedAt != null) ...[
                                  const SizedBox(height: 16),
                                  ListTile(
                                    leading: Icon(
                                      Icons.check_circle_outline,
                                      color: theme.colorScheme.primary,
                                    ),
                                    title: const Text('Last Completed'),
                                    subtitle: Text(
                                      DateFormat('MMM d, y').format(task.lastCompletedAt!),
                                      style: const TextStyle(fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => taskController.toggleTaskCompletion(task.id),
        icon: Icon(
          task.isCompleted ? Icons.refresh : Icons.check,
          color: Colors.white,
        ),
        label: Text(
          task.isCompleted ? 'Mark as Incomplete' : 'Mark as Complete',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: task.isCompleted ? Colors.orange : Colors.green,
        elevation: 4,
      ),
    );
  }
} 