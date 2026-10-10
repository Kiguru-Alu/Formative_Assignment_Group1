import '../models/task.dart';
import '../models/task_enums.dart';

const _uuid = Uuid();

class Uuid {
  const new();

  String v4() => DateTime.now().microsecondsSinceEpoch.toString();
}

/// Sample tasks covering every SLA state, used for development/testing
/// before real usage data exists.
List<Task> buildSampleTasks() {
  final now = DateTime.now();
  return [
    Task(
      id: _uuid.v4(),
      title: 'Design login screen',
      category: 'UI',
      description: 'Create the sign-in / user selection UI and wire up navigation.',
      assignedMemberId: 'u1',
      createdAt: now.subtract(const Duration(days: 2)),
      dueDate: now.add(const Duration(days: 5)),
      priority: TaskPriority.high,
      status: TaskStatus.inProgress,
      notes: '',
      updatedAt: now,
      lastActivityText: 'Task created',
    ),
    Task(
      id: _uuid.v4(),
      title: 'Implement SLA calculation',
      category: 'Logic',
      description: 'Pure function mapping a task to On Track / At Risk / Overdue / Completed.',
      assignedMemberId: 'u3',
      createdAt: now.subtract(const Duration(days: 1)),
      dueDate: now.add(const Duration(hours: 20)),
      priority: TaskPriority.high,
      status: TaskStatus.toDo,
      notes: '',
      updatedAt: now,
      lastActivityText: 'Task created',
    ),
    Task(
      id: _uuid.v4(),
      title: 'Fix overflow on task card',
      category: 'Bug',
      description: 'Long titles overflow on small screens, wrap text instead.',
      assignedMemberId: 'u2',
      createdAt: now.subtract(const Duration(days: 4)),
      dueDate: now.subtract(const Duration(days: 1)),
      priority: TaskPriority.medium,
      status: TaskStatus.toDo,
      notes: '',
      updatedAt: now,
      lastActivityText: 'Task created',
    ),
    Task(
      id: _uuid.v4(),
      title: 'Write AI usage declaration',
      category: 'Docs',
      description: 'Summarize what AI tools were used for and how output was verified.',
      assignedMemberId: 'u4',
      createdAt: now.subtract(const Duration(days: 6)),
      dueDate: now.subtract(const Duration(days: 3)),
      priority: TaskPriority.low,
      status: TaskStatus.completed,
      notes: 'Reviewed by whole team.',
      updatedAt: now.subtract(const Duration(days: 3)),
      lastActivityText: 'Marked completed',
    ),
    Task(
      id: _uuid.v4(),
      title: 'Record demo video',
      category: 'Demo',
      description: 'Each member records their section explaining their code.',
      assignedMemberId: 'u1',
      createdAt: now,
      dueDate: now.add(const Duration(days: 14)),
      priority: TaskPriority.medium,
      status: TaskStatus.toDo,
      notes: '',
      updatedAt: now,
      lastActivityText: 'Task created',
    ),
  ];
}