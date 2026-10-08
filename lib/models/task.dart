import 'task_enums.dart';

class Task {
  final String id;
  final String title;
  final String category;
  final String description;
  final String assignedMemberId;
  final DateTime createdAt;
  final DateTime dueDate;
  final TaskPriority priority;
  final TaskStatus status;
  final String notes;
  final DateTime updatedAt;
  final String lastActivityText;

  const Task({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.assignedMemberId,
    required this.createdAt,
    required this.dueDate,
    required this.priority,
    required this.status,
    required this.notes,
    required this.updatedAt,
    required this.lastActivityText,
  });

  Task copyWith({
    String? id,
    String? title,
    String? category,
    String? description,
    String? assignedMemberId,
    DateTime? createdAt,
    DateTime? dueDate,
    TaskPriority? priority,
    TaskStatus? status,
    String? notes,
    DateTime? updatedAt,
    String? lastActivityText,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      description: description ?? this.description,
      assignedMemberId: assignedMemberId ?? this.assignedMemberId,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      updatedAt: updatedAt ?? this.updatedAt,
      lastActivityText: lastActivityText ?? this.lastActivityText,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'description': description,
      'assignedMemberId': assignedMemberId,
      'createdAt': createdAt.toIso8601String(),
      'dueDate': dueDate.toIso8601String(),
      'priority': priority.toJson(),
      'status': status.toJson(),
      'notes': notes,
      'updatedAt': updatedAt.toIso8601String(),
      'lastActivityText': lastActivityText,
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Untitled Task',
      category: json['category'] as String? ?? 'General',
      description: json['description'] as String? ?? '',
      assignedMemberId: json['assignedMemberId'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'] as String)
          : DateTime.now().add(const Duration(days: 1)),
      priority: TaskPriority.fromJson(json['priority'] as String? ?? 'medium'),
      status: TaskStatus.fromJson(json['status'] as String? ?? 'toDo'),
      notes: json['notes'] as String? ?? '',
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
      lastActivityText: json['lastActivityText'] as String? ?? 'Task created',
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Task && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}