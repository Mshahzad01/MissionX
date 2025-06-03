import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/task_controller.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/task_entity.dart';

class TaskCreationScreen extends StatefulWidget {
  const TaskCreationScreen({super.key});

  @override
  State<TaskCreationScreen> createState() => _TaskCreationScreenState();
}

class _TaskCreationScreenState extends State<TaskCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  final List<String> _selectedDays = [];
  String _selectedAlarmSound = 'default';
  TaskEntity? _existingTask;

  final List<String> _weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  final List<String> _alarmSounds = ['default', 'bell', 'digital', 'gentle', 'urgent'];

  @override
  void initState() {
    super.initState();
    if (Get.arguments != null && Get.arguments is TaskEntity) {
      _existingTask = Get.arguments as TaskEntity;
      _titleController.text = _existingTask!.title;
      _descriptionController.text = _existingTask!.description;
      _selectedDate = _existingTask!.dateTime;
      _selectedTime = TimeOfDay.fromDateTime(_existingTask!.dateTime);
      _selectedDays.addAll(_existingTask!.repeatDays);
      _selectedAlarmSound = _existingTask!.alarmSound;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final taskController = Get.find<TaskController>();
      final dateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      if (_existingTask != null) {
        taskController.updateTask(
          TaskEntity(
            id: _existingTask!.id,
            uuid: _existingTask!.uuid,
            userId: _existingTask!.userId,
            title: _titleController.text,
            description: _descriptionController.text,
            dateTime: dateTime,
            repeatDays: _selectedDays,
            alarmSound: _selectedAlarmSound,
            isCompleted: _existingTask!.isCompleted,
            streakCount: _existingTask!.streakCount,
            lastCompletedAt: _existingTask!.lastCompletedAt,
          ),
        );
      } else {
        taskController.createTask(
          title: _titleController.text,
          description: _descriptionController.text,
          dateTime: dateTime,
          repeatDays: _selectedDays,
          alarmSound: _selectedAlarmSound,
        );
      }
    }
  }

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
                    Text(
                      _existingTask != null ? 'Edit Task' : 'Create Task',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              // Form Content
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Title Field
                          TextFormField(
                            controller: _titleController,
                            decoration: InputDecoration(
                              labelText: 'Title',
                              hintText: 'Enter task title',
                              prefixIcon: Icon(
                                Icons.title,
                                color: theme.colorScheme.primary,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: theme.colorScheme.primary,
                                  width: 2,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a title';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),

                          // Description Field
                          TextFormField(
                            controller: _descriptionController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              labelText: 'Description',
                              hintText: 'Enter task description',
                              prefixIcon: Icon(
                                Icons.description,
                                color: theme.colorScheme.primary,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: theme.colorScheme.primary,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Date & Time Section
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
                                const SizedBox(height: 20),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: () async {
                                          final date = await showDatePicker(
                                            context: context,
                                            initialDate: _selectedDate,
                                            firstDate: DateTime.now(),
                                            lastDate: DateTime.now().add(
                                              const Duration(days: 365),
                                            ),
                                          );
                                          if (date != null) {
                                            setState(() => _selectedDate = date);
                                          }
                                        },
                                        icon: const Icon(Icons.calendar_today),
                                        label: Text(
                                          DateFormat('MMM dd, yyyy').format(_selectedDate),
                                        ),
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.all(16),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: () async {
                                          final time = await showTimePicker(
                                            context: context,
                                            initialTime: _selectedTime,
                                          );
                                          if (time != null) {
                                            setState(() => _selectedTime = time);
                                          }
                                        },
                                        icon: const Icon(Icons.access_time),
                                        label: Text(_selectedTime.format(context)),
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.all(16),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Repeat Days Section
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
                                      Icons.repeat,
                                      color: theme.colorScheme.primary,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Repeat Days',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: _weekDays.map((day) {
                                    final isSelected = _selectedDays.contains(day);
                                    return FilterChip(
                                      label: Text(day),
                                      selected: isSelected,
                                      onSelected: (selected) {
                                        setState(() {
                                          if (selected) {
                                            _selectedDays.add(day);
                                          } else {
                                            _selectedDays.remove(day);
                                          }
                                        });
                                      },
                                      selectedColor: theme.colorScheme.primary.withOpacity(0.2),
                                      checkmarkColor: theme.colorScheme.primary,
                                      backgroundColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                        side: BorderSide(
                                          color: isSelected
                                              ? theme.colorScheme.primary
                                              : theme.colorScheme.primary.withOpacity(0.3),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Alarm Sound Section
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
                                      Icons.music_note,
                                      color: theme.colorScheme.primary,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Alarm Sound',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                DropdownButtonFormField<String>(
                                  value: _selectedAlarmSound,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    prefixIcon: Icon(
                                      Icons.music_note,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                  items: _alarmSounds.map((sound) {
                                    return DropdownMenuItem(
                                      value: sound,
                                      child: Text(sound.capitalize!),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() => _selectedAlarmSound = value);
                                    }
                                  },
                                ),
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
      floatingActionButton: Obx(() => FloatingActionButton.extended(
        onPressed: taskController.isLoading ? null : _submitForm,
        icon: taskController.isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(Icons.save,color: Colors.white,),
        label: Text(
          _existingTask != null ? 'Update Task' : 'Create Task',
          style: const TextStyle(fontWeight: FontWeight.bold,color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 238, 9, 207),
        elevation: 4,
      )),
    );
  }
} 