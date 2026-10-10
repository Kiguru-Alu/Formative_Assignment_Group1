import 'package:flutter/material.dart';

/// Defines the priority levels available for tasks in the SLA tracker.
enum TaskPriority {
  low,
  medium,
  high;

  /// Human-readable label for UI display.
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

  /// Semantic badge color for the priority level.
  Color get color {
    switch (this) {
      case TaskPriority.low:
        return const Color(0xFF64748B); // Slate
      case TaskPriority.medium:
        return const Color(0xFFF59E0B); // Amber
      case TaskPriority.high:
        return const Color(0xFFEF4444); // Rose
    }
  }

  /// Serializes the enum value to string for JSON persistence.
  String toJson() => name;

  /// Deserializes a string value from JSON into a [TaskPriority] enum.
  static TaskPriority fromJson(String value) {
    return TaskPriority.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => TaskPriority.medium,
    );
  }
}

/// Defines the operational status of a task.
enum TaskStatus {
  toDo,
  inProgress,
  completed;

  /// Human-readable display label.
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

  /// Color coding for task status badges.
  Color get color {
    switch (this) {
      case TaskStatus.toDo:
        return const Color(0xFF64748B); // Slate
      case TaskStatus.inProgress:
        return const Color(0xFF4F46E5); // Indigo
      case TaskStatus.completed:
        return const Color(0xFF10B981); // Emerald
    }
  }

  /// Serializes enum to string.
  String toJson() => name;

  /// Deserializes string to enum.
  static TaskStatus fromJson(String value) {
    return TaskStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => TaskStatus.toDo,
    );
  }
}

/// Defines the Service Level Agreement (SLA) status of a task.
enum SlaStatus {
  onTrack,
  atRisk,
  overdue,
  completed;

  /// Human-readable label for dashboard and reports.
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

  /// Semantic badge and background color matching the design system.
  Color get color {
    switch (this) {
      case SlaStatus.onTrack:
        return const Color(0xFF10B981); // Emerald
      case SlaStatus.atRisk:
        return const Color(0xFFF59E0B); // Amber
      case SlaStatus.overdue:
        return const Color(0xFFEF4444); // Rose
      case SlaStatus.completed:
        return const Color(0xFF64748B); // Slate
    }
  }

  /// Icon representing SLA status visually.
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

  /// Serializes enum to string.
  String toJson() => name;

  /// Deserializes string to enum.
  static SlaStatus fromJson(String value) {
    return SlaStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => SlaStatus.onTrack,
    );
  }
}
