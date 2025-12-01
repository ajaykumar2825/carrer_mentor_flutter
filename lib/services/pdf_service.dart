import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../models/skill_data.dart';
import 'package:flutter/services.dart';

class PDFService {
  /// Simple text-only career report
  static Future<Uint8List> generateCareerReport({
    required String name,
    required double roadmapProgress,
    required int feedbackAlerts,
    required double jobMatch,
  }) async {
    final pdf = pw.Document();
    final formattedDate = DateFormat(
      'yyyy-MM-dd – kk:mm',
    ).format(DateTime.now());

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => pw.Padding(
          padding: const pw.EdgeInsets.all(24),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Career Report for $name',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Divider(),
              pw.SizedBox(height: 10),
              pw.Text('Roadmap Progress: ${(roadmapProgress * 100).toInt()}%'),
              pw.Text('Feedback Alerts: $feedbackAlerts items need attention'),
              pw.Text('Job Match Score: ${(jobMatch * 100).toInt()}%'),
              pw.SizedBox(height: 20),
              pw.Divider(),
              pw.SizedBox(height: 10),
              pw.Text(
                'Generated on: $formattedDate',
                style: pw.TextStyle(fontSize: 12, color: PdfColors.grey),
              ),
              pw.Spacer(),
              pw.Align(
                alignment: pw.Alignment.center,
                child: pw.Text(
                  'Career Mentor © ${DateTime.now().year}',
                  style: pw.TextStyle(fontSize: 10, color: PdfColors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return pdf.save();
  }

  static Future<Uint8List> generateCareerDashboard({
    required String name,
    required List<Map<String, dynamic>> goals,
    required double profileCompletion,
    required List<SkillData> skills,
    required Uint8List skillChartBytes,
    required Uint8List goalChartBytes,
    required Uint8List timelineChartBytes, // ✅ new
    required String summary,
  }) async {
    final pdf = pw.Document();

    final skillChartImage = pw.MemoryImage(skillChartBytes);
    // final goalChartImage = pw.MemoryImage(goalChartBytes);
    final timelineChartImage = pw.MemoryImage(timelineChartBytes); // ✅ new
    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Text(
            'Career Dashboard for $name',
            style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 16),
          pw.Text(
            'Profile Completion: ${(profileCompletion * 100).toStringAsFixed(1)}%',
          ),
          pw.SizedBox(height: 12),
          pw.Text('Skill Growth:', style: pw.TextStyle(fontSize: 18)),
          pw.Column(
            children: [
              pw.Text('Skill Timeline', style: pw.TextStyle(fontSize: 18)),
              pw.SizedBox(height: 8),
              pw.Image(timelineChartImage, height: 200),
              pw.SizedBox(height: 20),
              ...skills.map(
                (s) => pw.Text(
                  '${s.name}: ${(s.level * 100).toStringAsFixed(1)}%',
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 16),
          pw.Text('Skill Chart:', style: pw.TextStyle(fontSize: 18)),
          pw.Center(child: pw.Image(skillChartImage, width: 350, height: 200)),
          pw.SizedBox(height: 24),
          pw.Text('Goal Timeline:', style: pw.TextStyle(fontSize: 18)),
          pw.Center(
            child: pw.Image(timelineChartImage, width: 350, height: 200),
          ), // <-- Use the timeline chart image
          pw.SizedBox(height: 16),
          pw.Column(
            children: [
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Text(summary, style: pw.TextStyle(fontSize: 14)),
              ),
              ...goals.map((g) {
                final deadline = g['deadline'] != null
                    ? DateTime.parse(g['deadline']).toLocal()
                    : null;
                final deadlineStr = deadline != null
                    ? deadline.toString().split(' ')[0]
                    : 'No deadline';

                final status = g['status'];
                final title = g['title'];

                return pw.Container(
                  margin: const pw.EdgeInsets.symmetric(vertical: 6),
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Container(
                        color: PdfColors.grey300,
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          'Skill Growth',
                          style: pw.TextStyle(fontSize: 18),
                        ),
                      ),
                      pw.Image(skillChartImage, height: 200),
                      pw.Container(
                        width: 8,
                        height: 8,
                        decoration: pw.BoxDecoration(
                          shape: pw.BoxShape.circle,
                          color: status == 'Completed'
                              ? PdfColors.green
                              : (deadline != null &&
                                    deadline.isBefore(DateTime.now()))
                              ? PdfColors.red
                              : PdfColors.orange,
                        ),
                      ),
                      pw.SizedBox(width: 12),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            title,
                            style: pw.TextStyle(
                              fontSize: 14,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.Text(
                            'Due: $deadlineStr — Status: $status',
                            style: pw.TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ],
      ),
    );
    return pdf.save();
  }

  /// Career report with embedded charts (Radar, Line, Bar)
  static Future<Uint8List> generateCareerReportWithCharts({
    required String name,
    required double roadmapProgress,
    required int feedbackAlerts,
    required double jobMatch,
    required Uint8List radarImage,
    required Uint8List lineImage,
    required Uint8List barImage,
  }) async {
    final pdf = pw.Document();
    final formattedDate = DateFormat(
      'yyyy-MM-dd – kk:mm',
    ).format(DateTime.now());

    final radar = pw.MemoryImage(radarImage);
    final line = pw.MemoryImage(lineImage);
    final bar = pw.MemoryImage(barImage);

    // Load logo from assets (ensure the asset path is declared in pubspec.yaml, e.g. assets/logo.png)
    final logoData = await rootBundle.load('assets/logo.png');
    final logo = pw.MemoryImage(logoData.buffer.asUint8List());

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (context) => [
          pw.Container(
            width: double.infinity,
            color: PdfColors.blue,
            padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: pw.Text(
              'Skill Growth',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
            ),
          ),
          pw.Header(
            level: 0,
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Row(
                  children: [
                    pw.Image(logo, height: 40), // ✅ logo
                    pw.SizedBox(width: 10),
                    pw.Text(
                      'Career Mentor Report',
                      style: pw.TextStyle(
                        fontSize: 22,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                pw.Text(name, style: pw.TextStyle(fontSize: 16)),
              ],
            ),
          ),
          pw.Divider(),
          pw.Header(
            level: 0,
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Career Mentor Report',
                  style: pw.TextStyle(
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(name, style: pw.TextStyle(fontSize: 16)),
              ],
            ),
          ),
          pw.Divider(),
          pw.Text(
            'Generated on: $formattedDate',
            style: pw.TextStyle(fontSize: 10, color: PdfColors.grey),
          ),
          pw.SizedBox(height: 8),
          pw.Divider(),
          pw.SizedBox(height: 8),

          pw.Text(
            'Summary',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
          pw.Bullet(
            text:
                'Roadmap completion: ${(roadmapProgress * 100).toStringAsFixed(0)}%',
          ),
          pw.Bullet(text: 'Feedback alerts: $feedbackAlerts'),
          pw.Bullet(
            text: 'Job match score: ${(jobMatch * 100).toStringAsFixed(0)}%',
          ),
          pw.SizedBox(height: 12),
          pw.Divider(),
          pw.SizedBox(height: 12),

          pw.Text(
            'Skill Radar',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          pw.Center(child: pw.Image(radar, width: 350, height: 250)),
          pw.SizedBox(height: 16),

          pw.Text(
            'Feedback Alerts Over Time',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          pw.Center(child: pw.Image(line, width: 400, height: 200)),
          pw.SizedBox(height: 16),

          pw.Text(
            'Roadmap Completion by Sprint',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          pw.Center(child: pw.Image(bar, width: 400, height: 200)),

          pw.SizedBox(height: 20),
          pw.Divider(),
          pw.SizedBox(height: 8),

          pw.Align(
            alignment: pw.Alignment.center,
            child: pw.Text(
              'Career Mentor © ${DateTime.now().year}',
              style: pw.TextStyle(fontSize: 10, color: PdfColors.grey),
            ),
          ),
        ],
      ),
    );

    return pdf.save();
  }

  /// Goal tracker report
  static Future<Uint8List> generateGoalTrackerReport({
    required String name,
    required List<Map<String, dynamic>> goals,
  }) async {
    final pdf = pw.Document();
    final formattedDate = DateFormat(
      'yyyy-MM-dd – kk:mm',
    ).format(DateTime.now());

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text(
              'Goal Tracker Report for $name',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Text(
            'Generated on: $formattedDate',
            style: pw.TextStyle(fontSize: 10, color: PdfColors.grey),
          ),
          pw.SizedBox(height: 8),
          pw.Divider(),
          pw.SizedBox(height: 12),

          pw.Text(
            'Milestones',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),

          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.blue, width: 2),
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Text(
              'Mentor Notes:\nKeep iterating on your skills and goals. '
              'Your timeline shows steady growth — stay consistent!',
              style: pw.TextStyle(fontSize: 14, color: PdfColors.blueGrey),
            ),
          ),
          ...goals.map(
            (goal) => pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 12),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    goal['title'],
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text('Progress: ${(goal['progress'] * 100).toInt()}%'),
                  pw.Text('Status: ${goal['status']}'),
                ],
              ),
            ),
          ),

          pw.SizedBox(height: 20),
          pw.Divider(),
          pw.SizedBox(height: 8),

          pw.Align(
            alignment: pw.Alignment.center,
            child: pw.Text(
              'Career Mentor © ${DateTime.now().year}',
              style: pw.TextStyle(fontSize: 10, color: PdfColors.grey),
            ),
          ),
        ],
      ),
    );

    return pdf.save();
  }
}
