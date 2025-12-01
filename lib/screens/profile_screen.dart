import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final nameController = TextEditingController();
  final goalController = TextEditingController();
  final skillsController = TextEditingController();
  final experienceController = TextEditingController();

  double flutterSkill = 3;
  double dartSkill = 3;
  double dataScienceSkill = 3;
  double problemSolvingSkill = 3;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      nameController.text = prefs.getString('name') ?? '';
      goalController.text = prefs.getString('goal') ?? '';
      skillsController.text = prefs.getString('skills') ?? '';
      experienceController.text = prefs.getString('experience') ?? '';
      flutterSkill = prefs.getDouble('flutterSkill') ?? 3;
      dartSkill = prefs.getDouble('dartSkill') ?? 3;
      dataScienceSkill = prefs.getDouble('dataScienceSkill') ?? 3;
      problemSolvingSkill = prefs.getDouble('problemSolvingSkill') ?? 3;
    });
  }

  double _calculateCompletion() {
    int filled = 0;
    if (nameController.text.trim().isNotEmpty) filled++;
    if (goalController.text.trim().isNotEmpty) filled++;
    if (skillsController.text.trim().isNotEmpty) filled++;
    if (experienceController.text.trim().isNotEmpty) filled++;
    return filled / 4;
  }

  Future<void> _saveProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', nameController.text.trim());
    await prefs.setString('goal', goalController.text.trim());
    await prefs.setString('skills', skillsController.text.trim());
    await prefs.setString('experience', experienceController.text.trim());
    await prefs.setDouble('flutterSkill', flutterSkill);
    await prefs.setDouble('dartSkill', dartSkill);
    await prefs.setDouble('dataScienceSkill', dataScienceSkill);
    await prefs.setDouble('problemSolvingSkill', problemSolvingSkill);

    final complete = _calculateCompletion() == 1.0;
    await prefs.setBool('profileComplete', complete);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          complete
              ? '✅ Profile saved and marked complete'
              : 'Profile saved. Complete all fields to finish',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final completion = _calculateCompletion();

    return Scaffold(
      appBar: AppBar(title: const Text('👤 Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            LinearProgressIndicator(
              value: completion,
              minHeight: 6,
              color: Colors.indigo,
              backgroundColor: Colors.grey.shade300,
            ),
            const SizedBox(height: 8),
            Text(
              '${(completion * 100).toInt()}% profile complete',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Your Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: goalController,
              decoration: const InputDecoration(labelText: 'Career Goal'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: skillsController,
              decoration: const InputDecoration(labelText: 'Skills'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: experienceController,
              decoration: const InputDecoration(labelText: 'Experience'),
            ),
            const SizedBox(height: 20),
            const Text(
              'Rate Your Skills',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Flutter'),
            Slider(
              value: flutterSkill,
              min: 0,
              max: 5,
              divisions: 5,
              label: '$flutterSkill',
              onChanged: (value) => setState(() => flutterSkill = value),
            ),
            Text('Dart'),
            Slider(
              value: dartSkill,
              min: 0,
              max: 5,
              divisions: 5,
              label: '$dartSkill',
              onChanged: (value) => setState(() => dartSkill = value),
            ),
            Text('Data Science'),
            Slider(
              value: dataScienceSkill,
              min: 0,
              max: 5,
              divisions: 5,
              label: '$dataScienceSkill',
              onChanged: (value) => setState(() => dataScienceSkill = value),
            ),
            Text('Problem Solving'),
            Slider(
              value: problemSolvingSkill,
              min: 0,
              max: 5,
              divisions: 5,
              label: '$problemSolvingSkill',
              onChanged: (value) => setState(() => problemSolvingSkill = value),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: const Text('Save Profile'),
              onPressed: _saveProfile,
            ),
          ],
        ),
      ),
    );
  }
}
