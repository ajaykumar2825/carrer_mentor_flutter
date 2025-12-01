import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class JobScreen extends StatefulWidget {
  const JobScreen({super.key});

  @override
  State<JobScreen> createState() => _JobScreenState();
}

class _JobScreenState extends State<JobScreen> {
  double jobMatchScore = 0.75; // initial simulated score

  Future<void> _saveJobMatch(double score) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('jobMatch', score);
  }

  void _updateScore(double value) {
    setState(() {
      jobMatchScore = value;
    });
    _saveJobMatch(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('💼 Job Matching')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Your Job Match Score: ${(jobMatchScore * 100).toInt()}%',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            LinearProgressIndicator(
              value: jobMatchScore,
              minHeight: 8,
              color: Colors.green,
              backgroundColor: Colors.grey.shade300,
            ),
            const SizedBox(height: 20),
            Slider(
              value: jobMatchScore,
              min: 0,
              max: 1,
              divisions: 20,
              label: '${(jobMatchScore * 100).toInt()}%',
              onChanged: _updateScore,
            ),
            const SizedBox(height: 20),
            const Text(
              'Adjust the slider to simulate how well your current skills match job requirements.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
