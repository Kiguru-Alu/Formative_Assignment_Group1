import 'package:flutter/material.dart';

enum TaskPriority {
  low,
  medium,
  high;


  String get label {
    switch (this) {
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.high:
        return 'High';
    }
  }

  Color get color {
    switch (this) {
      case TaskPriority.low:
        return const Color(0xFF64748B); 
      case TaskPriority.medium:
        return const Color(0xFFF59E0B); 
      case TaskPriority.high:
        return const Color(0xFFEF4444); 
    }
  }


  String toJson() => name;

  /// Deserializes a string value from JSON into a [TaskPriority] enum.
  static TaskPriority fromJson(String value) {
    return TaskPriority.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => TaskPriority.medium,
    );
  }
}


enum TaskStatus {
  toDo,
  inProgress,
  completed;

  String get label {
    switch (this) {
      case TaskStatus.toDo:
        return 'To Do';
      case TaskStatus.inProgress:
        return 'In Progress';
      case TaskStatus.completed:
        return 'Completed';
    }
  }


  Color get color {
    switch (this) {
      case TaskStatus.toDo:
        return const Color(0xFF64748B); 
      case TaskStatus.inProgress:
        return const Color(0xFF4F46E5); 
      case TaskStatus.completed:
        return const Color(0xFF10B981); 
    }
  }

  
  String toJson() => name;


  static TaskStatus fromJson(String value) {
    return TaskStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => TaskStatus.toDo,
    );
  }
}


enum SlaStatus {
  onTrack,
  atRisk,
  overdue,
  completed;

  
  String get label {
    switch (this) {
      case SlaStatus.onTrack:
        return 'On Track';
      case SlaStatus.atRisk:
        return 'At Risk';
      case SlaStatus.overdue:
        return 'Overdue';
      case SlaStatus.completed:
        return 'Completed';
    }
  }


  Color get color {
    switch (this) {
      case SlaStatus.onTrack:
        return const Color(0xFF10B981); 
      case SlaStatus.atRisk:
        return const Color(0xFFF59E0B); 
      case SlaStatus.overdue:
        return const Color(0xFFEF4444); 
      case SlaStatus.completed:
        return const Color(0xFF64748B); 
    }
  }


  IconData get icon {
    switch (this) {
      case SlaStatus.onTrack:
        return Icons.check_circle_outline;
      case SlaStatus.atRisk:
        return Icons.warning_amber_rounded;
      case SlaStatus.overdue:
        return Icons.error_outline;
      case SlaStatus.completed:
        return Icons.task_alt;
    }
  }

  String toJson() => name;

  /// Deserializes string to enum.
  static SlaStatus fromJson(String value) {
    return SlaStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => SlaStatus.onTrack,
    );
  }
}