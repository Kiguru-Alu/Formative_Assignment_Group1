import 'package:flutter/material.dart';

import '../models/team_member.dart';
import '../screens/task_details_screen.dart';
import '../screens/task_form_screen.dart';
import '../screens/task_list_screen.dart';
import '../services/local_storage_service.dart';
import '../services/sample_team_members.dart';

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

Future<bool> syncAssigneeOptions(LocalStorageService storage) async {
  final members = await storage.loadTeamMembers();
  String signature(List<TeamMember> list) =>
      list.map((m) => '${m.id}|${m.name}|${m.role}').join(';');
  if (signature(members) == signature(sampleTeamMembers)) return false;
  replaceSampleTeamMembers(members);
  return true;
}
