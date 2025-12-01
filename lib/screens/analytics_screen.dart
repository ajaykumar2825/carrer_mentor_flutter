import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/pdf_service.dart';
import 'package:printing/printing.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  double flutter = 3;
  double dart = 3;
  double dataScience = 3;
  double problemSolving = 3;

  final GlobalKey radarKey = GlobalKey();
  final GlobalKey lineKey = GlobalKey();
  final GlobalKey barKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _loadSkillRatings();
  }

  Future<void> _loadSkillRatings() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      flutter = prefs.getDouble('flutterSkill') ?? 3;
      dart = prefs.getDouble('dartSkill') ?? 3;
      dataScience = prefs.getDouble('dataScienceSkill') ?? 3;
      problemSolving = prefs.getDouble('problemSolvingSkill') ?? 3;
    });
  }

  Future<Uint8List> captureChart(GlobalKey key) async {
    final ctx = key.currentContext;
    if (ctx == null) {
      throw Exception(
        'Chart capture failed: key is not attached to the widget tree',
      );
    }

    final renderObject = ctx.findRenderObject();
    if (renderObject is! RenderRepaintBoundary) {
      throw Exception(
        'Chart capture failed: Render object is not a RenderRepaintBoundary',
      );
    }

    final boundary = renderObject;
    final image = await boundary.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      throw Exception('Chart capture failed: unable to convert image to bytes');
    }
    return byteData.buffer.asUint8List();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('📈 Analytics Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text(
              'Feedback Alerts Over Time',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            RepaintBoundary(
              key: lineKey,
              child: SizedBox(
                height: 200,
                child: LineChart(
                  LineChartData(
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, _) =>
                              Text('Day ${value.toInt()}'),
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, _) =>
                              Text('${value.toInt()}'),
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: true),
                    lineBarsData: [
                      LineChartBarData(
                        spots: const [
                          FlSpot(0, 3),
                          FlSpot(1, 2),
                          FlSpot(2, 4),
                          FlSpot(3, 1),
                          FlSpot(4, 0),
                        ],
                        isCurved: true,
                        color: Colors.orange,
                        barWidth: 3,
                        dotData: FlDotData(show: true),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Roadmap Completion by Sprint',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            RepaintBoundary(
              key: barKey,
              child: SizedBox(
                height: 200,
                child: BarChart(
                  BarChartData(
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, _) {
                            switch (value.toInt()) {
                              case 0:
                                return const Text('Sprint 1');
                              case 1:
                                return const Text('Sprint 2');
                              case 2:
                                return const Text('Sprint 3');
                              default:
                                return const Text('');
                            }
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, _) =>
                              Text('${(value * 100).toInt()}%'),
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: [
                      BarChartGroupData(
                        x: 0,
                        barRods: [
                          BarChartRodData(
                            toY: 0.6,
                            color: Colors.indigo,
                            width: 20,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ],
                      ),
                      BarChartGroupData(
                        x: 1,
                        barRods: [
                          BarChartRodData(
                            toY: 0.8,
                            color: Colors.indigo,
                            width: 20,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ],
                      ),
                      BarChartGroupData(
                        x: 2,
                        barRods: [
                          BarChartRodData(
                            toY: 0.4,
                            color: Colors.indigo,
                            width: 20,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Skill Growth Radar',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            RepaintBoundary(
              key: radarKey,
              child: SizedBox(
                height: 250,
                child: RadarChart(
                  RadarChartData(
                    dataSets: [
                      RadarDataSet(
                        dataEntries: [
                          RadarEntry(value: flutter),
                          RadarEntry(value: dart),
                          RadarEntry(value: dataScience),
                          RadarEntry(value: problemSolving),
                        ],
                        borderColor: Colors.indigo,
                        fillColor: Colors.indigo.withAlpha(80),
                      ),
                    ],
                    radarBorderData: const BorderSide(color: Colors.grey),
                    tickCount: 5,
                    ticksTextStyle: const TextStyle(color: Colors.black),
                    titleTextStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    getTitle: (index, angle) {
                      switch (index) {
                        case 0:
                          return const RadarChartTitle(text: 'Flutter');
                        case 1:
                          return const RadarChartTitle(text: 'Dart');
                        case 2:
                          return const RadarChartTitle(text: 'Data Science');
                        case 3:
                          return const RadarChartTitle(text: 'Problem Solving');
                        default:
                          return const RadarChartTitle(text: '');
                      }
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.picture_as_pdf),
        label: const Text('Export PDF'),
        onPressed: () async {
          // capture messenger early to avoid using BuildContext across await gaps
          final messenger = ScaffoldMessenger.of(context);

          try {
            final radarBytes = await captureChart(radarKey);
            final lineBytes = await captureChart(lineKey);
            final barBytes = await captureChart(barKey);

            final pdfBytes = await PDFService.generateCareerReportWithCharts(
              name: 'Ajay',
              roadmapProgress: 0.6,
              feedbackAlerts: 3,
              jobMatch: 0.75,
              radarImage: radarBytes,
              lineImage: lineBytes,
              barImage: barBytes,
            );

            if (!mounted) return;
            await Printing.layoutPdf(onLayout: (_) => pdfBytes);
          } catch (e) {
            if (!mounted) return;
            messenger.showSnackBar(
              SnackBar(content: Text('PDF export failed: $e')),
            );
          }
        },
      ),
    );
  }
}
