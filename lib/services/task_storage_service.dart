import '../models/task.dart';
import '../models/task_model.dart' as shared;
import 'local_storage_service.dart';

class TaskStorageService {
  final LocalStorageService _shared = LocalStorageService();

  Future<List<Task>> loadTasks() async {
    final tasks = await _shared.loadTasks();
    return tasks.map((t) => Task.fromJson(t.toJson())).toList();
  }

  Future<void> addTask(Task task) {
    return _shared.addTask(shared.Task.fromJson(task.toJson()));
  }

  Future<void> updateTask(Task updatedTask) {
    return _shared.updateTask(shared.Task.fromJson(updatedTask.toJson()));
  }

  Future<void> deleteTask(String taskId) {
    return _shared.deleteTask(taskId);
  }

  Future<void> seedIfEmpty(List<Task> sample) async {}
}
