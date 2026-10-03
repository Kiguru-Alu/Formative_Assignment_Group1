import 'package:flutter/material.dart';
import 'screens/task_list_screen.dart';

void main() {
  runApp(const TaskTrackerApp());
}

class TaskTrackerApp extends StatelessWidget {
  const TaskTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Project & SLA Task Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF3B5BFE),
      ),
      home: const TaskListScreen(),
    );
  }
}