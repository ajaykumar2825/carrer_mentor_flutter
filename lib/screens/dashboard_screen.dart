import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';
// ✅ new preview screen
import 'package:fl_chart/fl_chart.dart';
import 'package:path_provider/path_provider.dart'; // <-- Add this import
import 'dart:io'; // <-- Add this import for File operations
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';
import '../models/export_history.dart';

/// Minimal placeholder PDF service to satisfy calls to PDFService.generateCareerDashboard.
/// Replace with your real implementation (for example using the `pdf` package) when available.
class PDFService {
  static Future<Uint8List> generateCareerDashboard({
    required String name,
    required List<Map<String, dynamic>> goals,
    required double profileCompletion,
    required List<Map<String, dynamic>> skills,
    required Uint8List skillChartBytes,
    required Uint8List goalChartBytes,
    required Uint8List timelineChartBytes,
    required String summary,
  }) async {
    // Return an empty byte buffer as a placeholder.
    // Implement real PDF generation here.
    return Uint8List.fromList(<int>[]);
  }
}

final GlobalKey goalChartKey = GlobalKey();
final GlobalKey timelineChartKey = GlobalKey();

class TimelineChart extends StatelessWidget {
  final List<Map<String, dynamic>> timeline;

  const TimelineChart({super.key, required this.timeline});

  @override
  Widget build(BuildContext context) {
    final spots = <FlSpot>[];
    for (int i = 0; i < timeline.length; i++) {
      final level = timeline[i]['level'] ?? 0.0;
      spots.add(FlSpot(i.toDouble(), level));
    }

    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          titlesData: FlTitlesData(show: false),
          gridData: FlGridData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: Colors.purple,
              barWidth: 3,
              dotData: FlDotData(show: true),
            ),
          ],
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class GoalChart extends StatelessWidget {
  List<Map<String, dynamic>> goals;

  GoalChart({super.key, required this.goals});

  @override
  Widget build(BuildContext context) {
    final barGroups = <BarChartGroupData>[];

    for (int i = 0; i < goals.length; i++) {
      final goal = goals[i];
      final progress = goal['progress'] ?? 0.0; // value between 0.0 and 1.0

      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: progress * 100,
              color: Colors.green,
              width: 16,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          barGroups: barGroups,
          titlesData: FlTitlesData(show: false),
          gridData: FlGridData(show: false),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  DashboardScreen({super.key});

  final List<Map<String, dynamic>> goals = [
    {'title': 'Learn Flutter', 'progress': 0.8},
    {'title': 'Build Portfolio', 'progress': 0.6},
    {'title': 'Master Data Science', 'progress': 0.4},
  ];

  final List<Map<String, dynamic>> timelineEvents = [
    {'month': 'Jan', 'skill': 'Flutter', 'level': 0.4},
    {'month': 'Feb', 'skill': 'Dart', 'level': 0.5},
    {'month': 'Mar', 'skill': 'Firebase', 'level': 0.6},
    {'month': 'Apr', 'skill': 'UI Polish', 'level': 0.8},
  ];

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class SkillChart extends StatelessWidget {
  const SkillChart({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          lineBarsData: [
            LineChartBarData(
              spots: [
                FlSpot(0, 0.4), // Jan
                FlSpot(1, 0.5), // Feb
                FlSpot(2, 0.6), // Mar
                FlSpot(3, 0.8), // Apr
              ],
              isCurved: true,
              color: Colors.blue,
              barWidth: 3,
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool profileComplete = false;
  double roadmapProgress = 0.0;
  int feedbackAlerts = 0;
  double jobMatch = 0.0;
  String name = 'Ajay';
  String goal = 'Become a Data Scientist';

  List<ExportHistory> exportHistory = [];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      profileComplete = prefs.getBool('profileComplete') ?? false;
      roadmapProgress = prefs.getDouble('roadmapProgress') ?? 0.0;
      feedbackAlerts = prefs.getInt('feedbackAlerts') ?? 0;
      jobMatch = prefs.getDouble('jobMatch') ?? 0.0;
      name = prefs.getString('name') ?? 'Ajay';
      goal = prefs.getString('goal') ?? 'Become a Data Scientist';
    });
  }

  String generateSummary() {
    final latestSkill = widget.timelineEvents.isNotEmpty
        ? widget.timelineEvents.last['skill']
        : 'N/A';
    final topGoal = widget.goals.isNotEmpty
        ? widget.goals.first['title']
        : 'N/A';
    final timelinePeak = widget.timelineEvents.fold<double>(
      0.0,
      (max, e) => e['level'] > max ? e['level'] : max,
    );

    return '$name has shown consistent growth, recently focusing on $latestSkill. '
        'Their top goal, "$topGoal", is progressing well. '
        'Skill levels peaked at ${(timelinePeak * 100).toInt()}%, reflecting strong momentum.';
  }

  Future<void> exportReport(dynamic skillChartKey) async {
    final boundary =
        skillChartKey.currentContext!.findRenderObject()
            as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final chartBytes = byteData!.buffer.asUint8List();

    // ✅ Generate summary
    final summaryText = generateSummary();

    // ✅ Generate full PDF
    final pdfBytes = await PDFService.generateCareerDashboard(
      name: name,
      goals: widget.goals,
      profileCompletion: roadmapProgress,
      skills: widget
          .timelineEvents, // use timelineEvents as the available skills data
      skillChartBytes: chartBytes,
      goalChartBytes: Uint8List(0), // Add real data if available
      timelineChartBytes: Uint8List(0), // Add real data if available
      summary: summaryText,
    );

    // ✅ Save to device
    final output = await getTemporaryDirectory();
    final file = File("${output.path}/career_report.pdf");
    await file.writeAsBytes(pdfBytes);

    // ✅ Preview the PDF
    await OpenFilex.open(file.path);

    // ✅ Share the PDF
    Share.shareXFiles([
      XFile(file.path),
    ], text: 'Here is my Career Mentor Report!');
  }

  final GlobalKey goalChartKey =
      GlobalKey(); // put this at the top of your widget class

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('📊 Career Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Card(
              child: ListTile(
                leading: Icon(
                  profileComplete ? Icons.check_circle : Icons.error,
                  color: profileComplete ? Colors.green : Colors.red,
                ),
                title: const Text('Profile Status'),
                subtitle: Text(profileComplete ? 'Complete' : 'Incomplete'),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                title: const Text('Roadmap Progress'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LinearProgressIndicator(
                      value: roadmapProgress,
                      minHeight: 6,
                      color: Colors.indigo,
                      backgroundColor: Colors.grey.shade300,
                    ),
                    const SizedBox(height: 4),
                    Text('${(roadmapProgress * 100).toInt()}% completed'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const Icon(Icons.warning, color: Colors.orange),
                title: const Text('Feedback Alerts'),
                subtitle: Text('$feedbackAlerts items need attention'),
              ),
            ),
            RepaintBoundary(
              key: goalChartKey,
              child: GoalChart(
                goals: [
                  {'name': goal, 'progress': roadmapProgress},
                ],
              ),
            ),
            RepaintBoundary(
              key: timelineChartKey,
              child: TimelineChart(timeline: widget.timelineEvents),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                title: const Text('Job Match Score'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LinearProgressIndicator(
                      value: jobMatch,
                      minHeight: 6,
                      color: Colors.green,
                      backgroundColor: Colors.grey.shade300,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(jobMatch * 100).toInt()}% match with current skills',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('Preview Career Report'),
              onPressed: () => exportReport(goalChartKey),
            ),
          ],
        ),
      ),
    );
  }
}
