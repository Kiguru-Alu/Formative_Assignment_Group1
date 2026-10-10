import 'package:flutter/material.dart';

import '../screens/home_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/team_members_screen.dart';
import '../services/local_storage_service.dart';
import 'task_screens.dart';

class AppShell extends StatefulWidget {
  final LocalStorageService storageService;

  const AppShell({super.key, required this.storageService});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;
  final ValueNotifier<int> _homeRefresh = ValueNotifier<int>(0);
  final List<int> _versions = [0, 0, 0, 0];

  @override
  void initState() {
    super.initState();
    _syncAssignees();
  }

  Future<void> _syncAssignees() async {
    final changed = await syncAssigneeOptions(widget.storageService);
    if (changed && mounted) {
      setState(() => _versions[1]++);
    }
  }

  @override
  void dispose() {
    _homeRefresh.dispose();
    super.dispose();
  }

  void _select(int index) {
    setState(() {
      _index = index;
      if (index == 2 || index == 3) _versions[index]++;
    });
    if (index == 0) _homeRefresh.value++;
    _syncAssignees();
  }

  void _dataChangedOnHome() {
    setState(() {
      _versions[1]++;
      _versions[2]++;
      _versions[3]++;
    });
  }

  void _userChanged() {
    _homeRefresh.value++;
    _syncAssignees();
  }

  @override
  Widget build(BuildContext context) {
    final storage = widget.storageService;

    final pages = <Widget>[
      HomeScreen(
        storageService: storage,
        refreshSignal: _homeRefresh,
        onOpenTasks: () => _select(1),
        onOpenProfile: () => _select(3),
        onTasksChanged: _dataChangedOnHome,
      ),
      KeyedSubtree(key: ValueKey('tasks-${_versions[1]}'), child: buildTaskListTab()),
      KeyedSubtree(
        key: ValueKey('team-${_versions[2]}'),
        child: TeamMembersScreen(storageService: storage, onActiveUserChanged: _userChanged),
      ),
      KeyedSubtree(
        key: ValueKey('profile-${_versions[3]}'),
        child: ProfileScreen(storageService: storage, onProfileUpdated: _userChanged),
      ),
    ];

    return PopScope(
      canPop: _index == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _select(0);
      },
      child: Scaffold(
        body: IndexedStack(index: _index, children: pages),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: _select,
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
            NavigationDestination(icon: Icon(Icons.task_alt_outlined), selectedIcon: Icon(Icons.task_alt), label: 'Tasks'),
            NavigationDestination(icon: Icon(Icons.group_outlined), selectedIcon: Icon(Icons.group), label: 'Team'),
            NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}
