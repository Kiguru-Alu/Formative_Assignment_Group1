import 'package:shared_preferences/shared_preferences.dart';

import '../models/task.dart' as leila;
import '../models/task_model.dart';
import 'local_storage_service.dart';
import 'sample_data.dart' show buildSampleTasks;
import 'task_storage_service.dart' show TaskStorageService;

const String _appliedKey = 'sample_data_bridge_applied_v1';

const Map<String, String> _assignments = {
  'Design login screen': 'member_2',
  'Implement SLA calculation': 'member_5',
  'Fix overflow on task card': 'member_3',
  'Write AI usage declaration': 'member_1',
  'Record demo video': 'member_4',
};

Future<void> loadLeilaSampleData(LocalStorageService target) async {
  final prefs = await SharedPreferences.getInstance();
  if (prefs.getBool(_appliedKey) == true) return;

  final members = await target.loadTeamMembers();
  if (members.isEmpty) return;
  final memberIds = {for (final m in members) m.id};

  final source = TaskStorageService();
  await source.seedIfEmpty(buildSampleTasks());

  final sharedTasks = await target.loadTasks();
  final sharedIds = {for (final t in sharedTasks) t.id};
  final sourceTasks = await source.loadTasks();
  final sourceIds = {for (final t in sourceTasks) t.id};

  for (var i = 0; i < sourceTasks.length; i++) {
    final original = sourceTasks[i];
    final preferred = _assignments[original.title];
    final memberId = (preferred != null && memberIds.contains(preferred))
        ? preferred
        : members[i % members.length].id;
    final updated = original.copyWith(assignedMemberId: memberId);
    await source.updateTask(updated);
    if (!sharedIds.contains(updated.id)) {
      await target.addTask(Task.fromJson(updated.toJson()));
    }
  }

  for (final task in sharedTasks) {
    if (!sourceIds.contains(task.id)) {
      await source.addTask(leila.Task.fromJson(task.toJson()));
    }
  }

  await prefs.setBool(_appliedKey, true);
}
