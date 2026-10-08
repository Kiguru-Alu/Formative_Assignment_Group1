import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';

class TaskStorageService {
  static const String _tasksKey = 'tasks_data_v1';

  Future<List<Task>> loadTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rawList = prefs.getStringList(_tasksKey) ?? [];
      debugPrint('DEBUG loadTasks: found ${rawList.length} raw entries');
      return rawList
          .map((raw) => Task.fromJson(jsonDecode(raw) as Map<String, dynamic>))
          .toList();
    } catch (e, stackTrace) {
      debugPrint('DEBUG loadTasks: EXCEPTION: $e');
      debugPrint('DEBUG loadTasks: stack: $stackTrace');
      return [];
    }
  }

  Future<void> _saveAll(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final rawList = tasks.map((t) => jsonEncode(t.toJson())).toList();
    final success = await prefs.setStringList(_tasksKey, rawList);
    debugPrint('DEBUG _saveAll: saved ${tasks.length} tasks, success=$success');
  }

  Future<void> addTask(Task task) async {
    final tasks = await loadTasks();
    tasks.add(task);
    debugPrint('DEBUG addTask: adding "${task.title}", new total ${tasks.length}');
    await _saveAll(tasks);
  }

  Future<void> updateTask(Task updatedTask) async {
    final tasks = await loadTasks();
    final index = tasks.indexWhere((t) => t.id == updatedTask.id);
    debugPrint('DEBUG updateTask: found at index $index');
    if (index != -1) {
      tasks[index] = updatedTask;
      await _saveAll(tasks);
    }
  }

  Future<void> deleteTask(String taskId) async {
    final tasks = await loadTasks();
    tasks.removeWhere((t) => t.id == taskId);
    debugPrint('DEBUG deleteTask: removed $taskId, remaining ${tasks.length}');
    await _saveAll(tasks);
  }

  Future<void> seedIfEmpty(List<Task> sample) async {
    final existing = await loadTasks();
    debugPrint('DEBUG seedIfEmpty: existing count = ${existing.length}');
    if (existing.isEmpty) {
      debugPrint('DEBUG seedIfEmpty: seeding ${sample.length} sample tasks');
      await _saveAll(sample);
    }
  }
}