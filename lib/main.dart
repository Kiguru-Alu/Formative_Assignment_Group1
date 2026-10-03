import 'package:flutter/material.dart';
import 'screens/profile_screen.dart';
import 'screens/statistics_screen.dart';
import 'screens/team_members_screen.dart';
import 'services/local_storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storageService = LocalStorageService();
  await storageService.initAndSeedIfNeeded();

  runApp(ProjectSlaApp(storageService: storageService));
}

/// Root Application widget configuring the Material 3 Deep Indigo theme.
class ProjectSlaApp extends StatelessWidget {
  final LocalStorageService storageService;

  const ProjectSlaApp({
    super.key,
    required this.storageService,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Project & SLA Task Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4F46E5), // Indigo Primary
          primary: const Color(0xFF4F46E5),
          secondary: const Color(0xFF06B6D4), // Cyan Secondary
          surface: const Color(0xFFF8FAFC),
          onSurface: const Color(0xFF1E293B), // Dark Slate
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
          backgroundColor: Color(0xFFF8FAFC),
          foregroundColor: Color(0xFF1E293B)
         // scaffoldLineWidth: 0,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      home: StandalonePreviewShell(storageService: storageService),
    );
  }
}

/// Member 3 Standalone Preview Shell.
///
/// NOTE FOR MEMBER 1 (Dashboard Lead):
/// When integrating into the combined 4-tab application shell, import:
/// - `TeamMembersScreen` from 'package:task_management_app/screens/team_members_screen.dart'
/// - `StatisticsScreen` from 'package:task_management_app/screens/statistics_screen.dart'
/// - `ProfileScreen` from 'package:task_management_app/screens/profile_screen.dart'
/// - `LocalStorageService` from 'package:task_management_app/services/local_storage_service.dart'
///
/// Simply add these screens as tabs in your primary `IndexedStack` or `PageView`!
class StandalonePreviewShell extends StatefulWidget {
  final LocalStorageService storageService;

  const StandalonePreviewShell({
    super.key,
    required this.storageService,
  });

  @override
  State<StandalonePreviewShell> createState() => _StandalonePreviewShellState();
}

class _StandalonePreviewShellState extends State<StandalonePreviewShell> {
  int _currentIndex = 0;

  void _onDataOrUserChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      TeamMembersScreen(
        storageService: widget.storageService,
        onActiveUserChanged: _onDataOrUserChanged,
      ),
      StatisticsScreen(
        storageService: widget.storageService,
      ),
      ProfileScreen(
        storageService: widget.storageService,
        onProfileUpdated: _onDataOrUserChanged,
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people, color: Color(0xFF4F46E5)),
            label: 'Team',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart, color: Color(0xFF4F46E5)),
            label: 'Statistics',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: Color(0xFF4F46E5)),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}