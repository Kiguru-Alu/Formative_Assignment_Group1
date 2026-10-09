import 'package:flutter/material.dart';

import '../screens/task_details_screen.dart';
import '../screens/task_form_screen.dart';
import '../screens/task_list_screen.dart';

Widget buildTaskListTab() => const TaskListScreen();

Future<bool?> openTaskDetails(BuildContext context, String taskId) {
  return Navigator.of(context).push<bool>(
    MaterialPageRoute(builder: (_) => TaskDetailsScreen(taskId: taskId)),
  );
}

Future<bool?> openCreateTask(BuildContext context) {
  return Navigator.of(context).push<bool>(
    MaterialPageRoute(builder: (_) => const TaskFormScreen()),
  );
}
