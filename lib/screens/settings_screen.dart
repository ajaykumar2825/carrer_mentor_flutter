import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart'; // Access CareerMentorAppState for theme updates

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isDarkMode = false;
  String name = 'Ajay';
  String goal = 'Become a Data Scientist';

  final nameController = TextEditingController();
  final goalController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString('name') ?? 'Ajay';
      goal = prefs.getString('goal') ?? 'Become a Data Scientist';
      isDarkMode = prefs.getBool('darkMode') ?? false;
      nameController.text = name;
      goalController.text = goal;
    });
  }

  Future<void> _saveName(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', value);
  }

  Future<void> _saveGoal(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('goal', value);
  }

  Future<void> _saveDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('⚙️ Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text(
              'Profile Info',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Your Name'),
              onChanged: (value) {
                setState(() => name = value);
                _saveName(value);
              },
            ),
            const SizedBox(height: 8),
            TextField(
              controller: goalController,
              decoration: const InputDecoration(labelText: 'Career Goal'),
              onChanged: (value) {
                setState(() => goal = value);
                _saveGoal(value);
              },
            ),
            const SizedBox(height: 16),
            const Divider(),
            SwitchListTile(
              title: const Text('Dark Mode'),
              value: isDarkMode,
              onChanged: (value) {
                setState(() => isDarkMode = value);
                _saveDarkMode(value);

                // Notify main.dart to update theme
                final appState = context
                    .findAncestorStateOfType<CareerMentorAppState>();
                appState?.updateTheme(value);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.restore),
              title: const Text('Reset Progress'),
              subtitle: const Text('Clear roadmap and feedback data'),
              onTap: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                setState(() {
                  name = 'Ajay';
                  goal = 'Become a Data Scientist';
                  isDarkMode = false;
                  nameController.text = name;
                  goalController.text = goal;
                });

                // ignore: use_build_context_synchronously
                final appState = context
                    .findAncestorStateOfType<CareerMentorAppState>();
                appState?.updateTheme(false);

                ScaffoldMessenger.of(
                  // ignore: use_build_context_synchronously
                  context,
                ).showSnackBar(const SnackBar(content: Text('Progress reset')));
              },
            ),
          ],
        ),
      ),
    );
  }
}
