import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart'; // ✅ for daily reminders

class RoadmapScreen extends StatefulWidget {
  const RoadmapScreen({super.key});

  @override
  State<RoadmapScreen> createState() => _RoadmapScreenState();
}

class _RoadmapScreenState extends State<RoadmapScreen> {
  final List<Map<String, dynamic>> roadmap = [
    {
      'sprint': 'Sprint 1: Setup & Basics',
      'tasks': [
        {'title': 'Install VS Code and Flutter SDK', 'done': false},
        {'title': 'Create your first Flutter project', 'done': false},
        {'title': 'Build a Profile form UI', 'done': false},
      ],
    },
    {
      'sprint': 'Sprint 2: Recommendations & Navigation',
      'tasks': [
        {'title': 'Build Recommendation screen', 'done': false},
        {'title': 'Wire up navigation from Profile', 'done': false},
        {'title': 'Add sample recommendation cards', 'done': false},
      ],
    },
    {
      'sprint': 'Sprint 3: Roadmap & Feedback',
      'tasks': [
        {'title': 'Build Roadmap screen with Stepper', 'done': false},
        {'title': 'Add progress indicators', 'done': false},
        {'title': 'Create Feedback module', 'done': false},
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadRoadmapProgress();
  }

  int get totalTasks =>
      roadmap.fold(0, (sum, sprint) => sum + (sprint['tasks'] as List).length);

  int get completedTasks => roadmap.fold(
    0,
    (sum, sprint) =>
        sum +
        (sprint['tasks'] as List).where((task) => task['done'] == true).length,
  );

  double get progress => totalTasks == 0 ? 0 : completedTasks / totalTasks;

  Future<void> _saveRoadmapProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final taskStates = roadmap
        .expand(
          (sprint) => (sprint['tasks'] as List).map((t) => t['done'] as bool),
        )
        .toList();
    await prefs.setStringList(
      'roadmapTasks',
      taskStates.map((b) => b.toString()).toList(),
    );
    await prefs.setDouble('roadmapProgress', progress);

    // ✅ Trigger daily reminder if tasks are incomplete
    if (completedTasks < totalTasks) {
      await NotificationService.scheduleDailyReminder(
        hour: 9,
        minute: 0,
        id: 101,
        title: '🚀 Career Reminder',
        body:
            'You have ${totalTasks - completedTasks} tasks pending. Let’s make progress today!',
      );
    }
  }

  Future<void> _loadRoadmapProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('roadmapTasks');
    if (saved != null) {
      int i = 0;
      for (var sprint in roadmap) {
        for (var task in sprint['tasks']) {
          task['done'] = saved[i] == 'true';
          i++;
        }
      }
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🗺️ Career Roadmap')),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Text(
            'Overall Progress: ${(progress * 100).toInt()}%',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                    value: completedTasks.toDouble(),
                    color: Colors.green,
                    title: 'Done',
                    titleStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  PieChartSectionData(
                    value: (totalTasks - completedTasks).toDouble(),
                    color: Colors.red,
                    title: 'Pending',
                    titleStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
                sectionsSpace: 2,
                centerSpaceRadius: 40,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: roadmap.length,
              itemBuilder: (context, index) {
                final sprint = roadmap[index];
                final tasks = sprint['tasks'] as List;
                final completedCount = tasks
                    .where((task) => task['done'] == true)
                    .length;

                return Card(
                  margin: const EdgeInsets.all(12),
                  child: ExpansionTile(
                    title: Text(
                      sprint['sprint'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Completed: $completedCount / ${tasks.length} tasks',
                    ),
                    children: List.generate(
                      tasks.length,
                      (i) => CheckboxListTile(
                        value: tasks[i]['done'],
                        onChanged: (checked) {
                          setState(() {
                            tasks[i]['done'] = checked ?? false;
                          });
                          _saveRoadmapProgress();
                        },
                        title: Text(tasks[i]['title']),
                        secondary: Icon(
                          tasks[i]['done']
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color: tasks[i]['done'] ? Colors.green : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
