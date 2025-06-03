import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/task_controller.dart';
import '../controllers/auth_controller.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import '../routes/app_pages.dart';
import 'package:fl_chart/fl_chart.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final taskController = Get.find<TaskController>();
    final authController = Get.find<AuthController>();
    final theme = Theme.of(context);

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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'MissionX',
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.bar_chart, color: Colors.white),
                          onPressed: () => Get.toNamed('/statistics'),
                        ),
                        IconButton(
                          icon: const Icon(Icons.settings, color: Colors.white),
                          onPressed: () => Get.toNamed('/settings'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Calendar Strip with Gradient Background
              Container(
                height: 100,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: _buildDateSelector(taskController),
              ),

              // Progress Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Today\'s Progress',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Obx(() {
                                final completedCount = taskController.completedTasks.length;
                                final totalCount = taskController.tasks.length;
                                return Text(
                                  '$completedCount of $totalCount tasks completed',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: theme.colorScheme.primary.withOpacity(0.7),
                                  ),
                                );
                              }),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.local_fire_department,
                                  color: theme.colorScheme.primary,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Obx(() {
                                  final maxStreak = taskController.tasks
                                      .map((task) => task.streakCount)
                                      .fold(0, (max, streak) => streak > max ? streak : max);
                                  return Text(
                                    '$maxStreak day streak',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 70,
                        child: Obx(() {
                          final tasks = taskController.tasks;
                          if (tasks.isEmpty) {
                            return Center(
                              child: Text(
                                'No tasks for today',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: theme.colorScheme.primary.withOpacity(0.5),
                                ),
                              ),
                            );
                          }

                          final completedTasks = tasks.where((task) => task.isCompleted).toList();
                          final spots = List.generate(24, (hour) {
                            final tasksAtHour = tasks.where((task) =>
                                task.dateTime.hour == hour).length;
                            final completedAtHour = completedTasks.where((task) =>
                                task.dateTime.hour == hour).length;
                            return FlSpot(
                              hour.toDouble(),
                              tasksAtHour > 0 ? completedAtHour / tasksAtHour : 0,
                            );
                          });

                          return LineChart(
                            LineChartData(
                              gridData: FlGridData(show: false),
                              titlesData: FlTitlesData(
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                rightTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                topTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      if (value % 6 == 0) {
                                        return Text(
                                          '${value.toInt()}:00',
                                          style: TextStyle(
                                            color: theme.colorScheme.primary.withOpacity(0.5),
                                            fontSize: 10,
                                          ),
                                        );
                                      }
                                      return const Text('');
                                    },
                                  ),
                                ),
                              ),
                              borderData: FlBorderData(show: false),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: spots,
                                  isCurved: true,
                                  color: theme.colorScheme.primary,
                                  barWidth: 2,
                                  isStrokeCapRound: true,
                                  dotData: FlDotData(show: false),
                                  belowBarData: BarAreaData(
                                    show: true,
                                    color: theme.colorScheme.primary.withOpacity(0.1),
                                  ),
                                ),
                              ],
                              minY: 0,
                              maxY: 1,
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),

              // Task List
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
                    child: Obx(() {
                      if (taskController.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (taskController.tasks.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.task,
                                size: 64,
                                color: theme.colorScheme.primary.withOpacity(0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No tasks for today',
                                style: TextStyle(
                                  color: theme.colorScheme.primary.withOpacity(0.5),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: taskController.tasks.length,
                        itemBuilder: (context, index) {
                          final task = taskController.tasks[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Slidable(
                              endActionPane: ActionPane(
                                motion: const ScrollMotion(),
                                children: [
                                  SlidableAction(
                                    onPressed: (_) => taskController.deleteTask(task.id),
                                    backgroundColor: Colors.red.shade400,
                                    foregroundColor: Colors.white,
                                    icon: Icons.delete,
                                    label: 'Delete',
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ],
                              ),
                              child: Container(
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
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: task.isCompleted
                                        ? Colors.green.withOpacity(0.3)
                                        : theme.colorScheme.primary.withOpacity(0.3),
                                  ),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  leading: Container(
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
                                  title: Text(
                                    task.title,
                                    style: TextStyle(
                                      decoration: task.isCompleted
                                          ? TextDecoration.lineThrough
                                          : null,
                                      color: task.isCompleted
                                          ? Colors.grey
                                          : theme.textTheme.titleMedium?.color,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Row(
                                    children: [
                                      Icon(
                                        Icons.access_time,
                                        size: 16,
                                        color: theme.colorScheme.primary,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        DateFormat('HH:mm').format(task.dateTime),
                                        style: TextStyle(
                                          color: theme.colorScheme.primary,
                                        ),
                                      ),
                                      if (task.repeatDays.isNotEmpty) ...[
                                        const SizedBox(width: 8),
                                        Icon(
                                          Icons.repeat,
                                          size: 16,
                                          color: theme.colorScheme.primary,
                                        ),
                                      ],
                                      if (task.streakCount > 0) ...[
                                        const SizedBox(width: 8),
                                        Icon(
                                          Icons.local_fire_department,
                                          size: 16,
                                          color: Colors.orange,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${task.streakCount}',
                                          style: const TextStyle(
                                            color: Colors.orange,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  onTap: () =>
                                      Get.toNamed('/task-detail', arguments: task),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed('/task-creation'),
        icon: const Icon(Icons.add,color: Colors.white,),
        label: const Text('New Task',style: TextStyle(color: Colors.white),),
        backgroundColor: const Color.fromARGB(255, 238, 9, 207),
        elevation: 4,
      ),
    );
  }

  Widget _buildDateSelector(TaskController controller) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      itemCount: 7,
      itemBuilder: (context, index) {
        final date = DateTime.now().add(Duration(days: index));

        return GestureDetector(
          onTap: () => controller.selectDate(date),
          child: Obx(() {
            final isSelected = DateUtils.isSameDay(date, controller.selectedDate);
            return Container(
              width: 65,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('EEE').format(date),
                    style: TextStyle(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    DateFormat('d').format(date),
                    style: TextStyle(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }),
        );
      },
    );
  }
} 