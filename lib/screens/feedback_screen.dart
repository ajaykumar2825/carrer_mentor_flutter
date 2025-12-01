import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final List<String> feedbackItems = [
    'Improve Profile completeness',
    'Add more detail to Roadmap tasks',
    'Refine Job preferences',
  ];

  final Set<int> resolvedItems = {};

  Future<void> _saveFeedbackAlerts() async {
    final prefs = await SharedPreferences.getInstance();
    final alerts = feedbackItems.length - resolvedItems.length;
    await prefs.setInt('feedbackAlerts', alerts);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('📝 Feedback')),
      body: ListView.builder(
        itemCount: feedbackItems.length,
        itemBuilder: (context, index) {
          final item = feedbackItems[index];
          final resolved = resolvedItems.contains(index);

          return Card(
            margin: const EdgeInsets.all(8),
            child: CheckboxListTile(
              title: Text(item),
              value: resolved,
              onChanged: (checked) {
                setState(() {
                  if (checked == true) {
                    resolvedItems.add(index);
                  } else {
                    resolvedItems.remove(index);
                  }
                  _saveFeedbackAlerts();
                });
              },
              secondary: Icon(
                resolved ? Icons.check_circle : Icons.warning,
                color: resolved ? Colors.green : Colors.orange,
              ),
            ),
          );
        },
      ),
    );
  }
}
