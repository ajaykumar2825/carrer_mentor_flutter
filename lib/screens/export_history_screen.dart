import 'package:career_mentor_flutter/models/export_history.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';

class ExportHistoryScreen extends StatelessWidget {
  final List<ExportHistory> history;

  const ExportHistoryScreen({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Export History')),
      body: ListView.builder(
        itemCount: history.length,
        itemBuilder: (context, index) {
          final item = history[index];

          return ListTile(
            title: Text('Exported on ${item.timestamp.toLocal()}'),
            subtitle: Text(item.filePath),
            trailing: IconButton(
              icon: Icon(Icons.open_in_new),
              onPressed: () async {
                await OpenFilex.open(item.filePath);
                // ignore: use_build_context_synchronously
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Opened ${item.filePath}')),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
