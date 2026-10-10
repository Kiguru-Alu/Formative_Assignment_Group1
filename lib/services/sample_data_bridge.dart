import 'package:shared_preferences/shared_preferences.dart';

import '../models/task_model.dart';
import 'local_storage_service.dart';
import 'sample_data.dart' show buildSampleTasks;

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
  final existingTitles = {for (final t in await target.loadTasks()) t.title};

  final samples = buildSampleTasks();
  for (var i = 0; i < samples.length; i++) {
    final original = samples[i];
    if (existingTitles.contains(original.title)) continue;
    final preferred = _assignments[original.title];
    final memberId = (preferred != null && memberIds.contains(preferred))
        ? preferred
        : members[i % members.length].id;
    final updated = original.copyWith(assignedMemberId: memberId);
    await target.addTask(Task.fromJson(updated.toJson()));
  }

  await prefs.setBool(_appliedKey, true);
}
