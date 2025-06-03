import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import '../controllers/task_controller.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final taskController = Get.find<TaskController>();
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
          ),
        ),
        child: SafeArea(
          child: Obx(() {
            final completedTasks = taskController.completedTasks;
            final incompleteTasks = taskController.incompleteTasks;
            final completionRate = taskController.completionRate;

            return CustomScrollView(
              slivers: [
                // App Bar
                SliverAppBar(
                  backgroundColor: Colors.transparent,
                  expandedHeight: 200,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    title: const Text(
                      'Your Progress',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    background: Center(
                      child: Lottie.asset(
                        'assets/animations/achievement.json',
                        width: 150,
                        height: 150,
                      ),
                    ),
                  ),
                ),

                // Statistics Cards
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Completion Rate Card
                        Card(
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                Text(
                                  'Completion Rate',
                                  style: theme.textTheme.titleLarge,
                                ),
                                const SizedBox(height: 20),
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    SizedBox(
                                      height: 150,
                                      width: 150,
                                      child: CircularProgressIndicator(
                                        value: completionRate,
                                        strokeWidth: 12,
                                        backgroundColor: theme
                                            .colorScheme.primary
                                            .withOpacity(0.2),
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          theme.colorScheme.primary,
                                        ),
                                      ),
                                    ),
                                    Column(
                                      children: [
                                        Text(
                                          '${(completionRate * 100).toInt()}%',
                                          style: theme.textTheme.headlineMedium
                                              ?.copyWith(
                                            color: theme.colorScheme.primary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          'Completed',
                                          style: theme.textTheme.bodySmall,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Task Summary Card
                        Card(
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                Text(
                                  'Task Summary',
                                  style: theme.textTheme.titleLarge,
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    _buildSummaryItem(
                                      context,
                                      Icons.check_circle_outline,
                                      completedTasks.length.toString(),
                                      'Completed',
                                      Colors.green,
                                    ),
                                    _buildSummaryItem(
                                      context,
                                      Icons
                                          .cancel_outlined, // New icon for incomplete
                                      taskController
                                          .currentIncompleteTasks.length
                                          .toString(),
                                      'Incomplete',
                                      Colors.red,
                                    ),
                                    _buildSummaryItem(
                                      context,
                                      Icons.pending_outlined,
                                      taskController.overdueTasks.length
                                          .toString(),
                                      'Pending',
                                      Colors.orange,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Task Streaks
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Task Streaks 🔥',
                              style: theme.textTheme.titleLarge,
                            ),
                            const SizedBox(height: 20),
                            ...completedTasks.map((task) {
                              return FutureBuilder<int>(
                                future: taskController.getTaskStreak(task.id),
                                builder: (context, snapshot) {
                                  final streak = snapshot.data ?? 0;
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: theme
                                            .colorScheme.primary
                                            .withOpacity(0.1),
                                        child: Text(
                                          '${streak}d',
                                          style: TextStyle(
                                            color: theme.colorScheme.primary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      title: Text(
                                        task.title,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      subtitle: Text(
                                        'Last completed: ${DateFormat('MMM d, y').format(task.lastCompletedAt)}',
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: List.generate(
                                          5,
                                          (index) => Icon(
                                            Icons.local_fire_department,
                                            color: index < (streak ~/ 2)
                                                ? Colors.orange
                                                : Colors.grey.withOpacity(0.3),
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildSummaryItem(
    BuildContext context,
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 40),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
