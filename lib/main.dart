import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/notification_service.dart';
import 'screens/profile_screen.dart';
import 'screens/recommendation_screen.dart';
import 'screens/roadmap_screen.dart';
import 'screens/feedback_screen.dart';
import 'screens/job_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init(); // ✅ initialize notifications
  runApp(const CareerMentorApp()); // ✅ use correct root widget
}

class CareerMentorApp extends StatefulWidget {
  const CareerMentorApp({super.key});

  @override
  State<CareerMentorApp> createState() => CareerMentorAppState();
}

class CareerMentorAppState extends State<CareerMentorApp> {
  int _selectedIndex = 0;
  bool isDarkMode = false;

  final List<Widget> _screens = [
    DashboardScreen(),
    ProfileScreen(),
    RecommendationScreen(),
    RoadmapScreen(),
    FeedbackScreen(),
    JobScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('darkMode') ?? false;
    });
  }

  void updateTheme(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', value);
    setState(() => isDarkMode = value);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Career Mentor',
      theme: isDarkMode
          ? ThemeData.dark(useMaterial3: true)
          : ThemeData.light(useMaterial3: true).copyWith(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
            ),
      home: Scaffold(
        body: _screens[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: Colors.indigo,
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
            BottomNavigationBarItem(
              icon: Icon(Icons.lightbulb),
              label: 'Recommendations',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Roadmap'),
            BottomNavigationBarItem(
              icon: Icon(Icons.feedback),
              label: 'Feedback',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.work), label: 'Jobs'),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
