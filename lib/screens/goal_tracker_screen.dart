import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/pdf_service.dart';
import '../services/notification_service.dart'; // ✅ notifications
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class GoalTrackerScreen extends StatefulWidget {
  const GoalTrackerScreen({super.key});

  @override
  State<GoalTrackerScreen> createState() => _GoalTrackerScreenState();
}

class _GoalTrackerScreenState extends State<GoalTrackerScreen> {
  List<Map<String, dynamic>> goals = [];

  @override
  void initState() {
    super.initState();
    _loadGoals();
    NotificationService.init(); // ✅ initialize notifications
  }

  Future<void> _loadGoals() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('goals');
    if (saved != null) {
      setState(() {
        goals = List<Map<String, dynamic>>.from(jsonDecode(saved));
      });
    } else {
      goals = [
        {
          'title': 'Master Flutter Widgets',
          'progress': 0.7,
          'status': 'In Progress',
          'deadline': null,
        },
        {
          'title': 'Build Career Mentor MVP',
          'progress': 1.0,
          'status': 'Completed',
          'deadline': null,
        },
      ];
    }
  }

  Future<void> _saveGoals() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('goals', jsonEncode(goals));
  }

  void _addGoal() {
    final titleController = TextEditingController();
    double progress = 0.0;
    String status = 'Not Started';
    DateTime? deadline;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: const Text('Add New Goal'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Goal Title'),
                  ),
                  const SizedBox(height: 12),
                  Slider(
                    value: progress,
                    onChanged: (val) => setDialogState(() => progress = val),
                    min: 0,
                    max: 1,
                  ),
                  DropdownButton<String>(
                    value: status,
                    items: ['Not Started', 'In Progress', 'Completed']
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (val) => setDialogState(() => status = val!),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) {
                        setDialogState(() => deadline = picked);
                      }
                    },
                    child: Text(
                      deadline == null
                          ? 'Pick Deadline'
                          : 'Deadline: ${deadline!.toLocal().toString().split(' ')[0]}',
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      goals.add({
                        'title': titleController.text,
                        'progress': progress,
                        'status': status,
                        'deadline': deadline?.toIso8601String(),
                      });
                    });
                    _saveGoals();

                    if (deadline != null) {
                      NotificationService.scheduleDeadlineReminder(
                        id: goals.length,
                        title: 'Goal Reminder',
                        body: '${titleController.text} is due soon!',
                        deadline: deadline!,
                      );
                    }

                    Navigator.pop(ctx);
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _editGoal(int index, Map<String, dynamic> goal) {
    final titleController = TextEditingController(text: goal['title']);
    double progress = goal['progress'];
    String status = goal['status'];
    DateTime? deadline = goal['deadline'] != null
        ? DateTime.parse(goal['deadline'])
        : null;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: const Text('Edit Goal'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: titleController),
                  Slider(
                    value: progress,
                    onChanged: (val) => setDialogState(() => progress = val),
                    min: 0,
                    max: 1,
                  ),
                  DropdownButton<String>(
                    value: status,
                    items: ['Not Started', 'In Progress', 'Completed']
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (val) => setDialogState(() => status = val!),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: deadline ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) {
                        setDialogState(() => deadline = picked);
                      }
                    },
                    child: Text(
                      deadline == null
                          ? 'Pick Deadline'
                          : 'Deadline: ${deadline!.toLocal().toString().split(' ')[0]}',
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      goals[index] = {
                        'title': titleController.text,
                        'progress': progress,
                        'status': status,
                        'deadline': deadline?.toIso8601String(),
                      };
                    });
                    _saveGoals();

                    NotificationService.cancelNotification(index + 1);
                    if (deadline != null && status != 'Completed') {
                      NotificationService.scheduleDeadlineReminder(
                        id: index + 1,
                        title: 'Goal Reminder',
                        body: '${titleController.text} is due soon!',
                        deadline: deadline!,
                      );
                    }

                    Navigator.pop(ctx);
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🎯 Goal Tracker')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: goals.length,
        itemBuilder: (context, index) {
          final goal = goals[index];
          return Dismissible(
            key: Key(goal['title']),
            direction: DismissDirection.endToStart,
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            onDismissed: (direction) {
              setState(() {
                goals.removeAt(index);
              });
              _saveGoals();
              NotificationService.cancelNotification(index + 1);
            },
            child: GestureDetector(
              onTap: () => _editGoal(index, goal),
              child: Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal['title'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: goal['progress'],
                        color: Colors.indigo,
                        backgroundColor: Colors.grey[300],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Status: ${goal['status']}',
                            style: const TextStyle(fontSize: 12),
                          ),
                          Checkbox(
                            value: goal['status'] == 'Completed',
                            onChanged: (checked) {
                              setState(() {
                                goals[index]['status'] = checked!
                                    ? 'Completed'
                                    : 'In Progress';
                              });
                              _saveGoals();
                              if (checked != null && checked) {
                                NotificationService.cancelNotification(
                                  index + 1,
                                );
                              }
                            },
                          ),
                        ],
                      ),
                      if (goal['deadline'] != null)
                        Text(
                          'Deadline: ${DateTime.parse(goal['deadline']).toLocal().toString().split(' ')[0]}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.red,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.extended(
            heroTag: 'addGoal',
            icon: const Icon(Icons.add),
            label: const Text('Add Goal'),
            onPressed: _addGoal,
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'exportGoals',
            icon: const Icon(Icons.picture_as_pdf),
            label: const Text('Export & Share'),
            onPressed: () async {
              final pdfBytes = await PDFService.generateGoalTrackerReport(
                name: 'Ajay',
                goals: goals,
              );

              final tempDir = await getTemporaryDirectory();
              final file = File('${tempDir.path}/goal_report.pdf');
              await file.writeAsBytes(pdfBytes);

              await Share.shareXFiles([
                XFile(file.path),
              ], text: 'Here’s my goal progress report 📄');
            },
          ),
        ],
      ),
    );
  }
}
