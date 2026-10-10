import '../models/task_enums.dart';
import '../models/task_model.dart';

/// Calculation engine for computing SLA statuses, warning windows, compliance rates,
/// and detailed SLA explanations across the application.
class SlaCalculator {
  /// Priority warning threshold hours as per SLA guidelines.
  static const double highPriorityWarningHours = 72.0;
  static const double mediumPriorityWarningHours = 48.0;
  static const double lowPriorityWarningHours = 24.0;

  /// Evaluates and returns the precise [SlaStatus] of a given [Task].
  ///
  /// Rules applied in order:
  /// 1. Completed tasks -> [SlaStatus.completed]
  /// 2. Current time past due date -> [SlaStatus.overdue]
  /// 3. Remaining time within priority early-warning threshold -> [SlaStatus.atRisk]
  ///    - High priority: <= 72 hours
  ///    - Medium priority: <= 48 hours
  ///    - Low priority: <= 24 hours
  /// 4. Otherwise -> [SlaStatus.onTrack]
  static SlaStatus calculateSlaStatus(Task task, {DateTime? now}) {
    final currentTime = now ?? DateTime.now();

    // Rule 1: Task completed
    if (task.status == TaskStatus.completed) {
      return SlaStatus.completed;
    }

    // Rule 2: Deadline passed
    if (currentTime.isAfter(task.dueDate)) {
      return SlaStatus.overdue;
    }

    // Rule 3: Priority-Weighted Early-Warning SLA Window
    final double remainingHours =
        task.dueDate.difference(currentTime).inMinutes / 60.0;

    switch (task.priority) {
      case TaskPriority.high:
        if (remainingHours <= highPriorityWarningHours) {
          return SlaStatus.atRisk;
        }
        break;
      case TaskPriority.medium:
        if (remainingHours <= mediumPriorityWarningHours) {
          return SlaStatus.atRisk;
        }
        break;
      case TaskPriority.low:
        if (remainingHours <= lowPriorityWarningHours) {
          return SlaStatus.atRisk;
        }
        break;
    }

    // Rule 4: On Track
    return SlaStatus.onTrack;
  }

  /// Returns a human-readable diagnosis string describing the SLA state of a task.
  static String getSlaExplanation(Task task, {DateTime? now}) {
    final currentTime = now ?? DateTime.now();
    final status = calculateSlaStatus(task, now: currentTime);

    switch (status) {
      case SlaStatus.completed:
        return 'Completed — Task has been delivered successfully.';

      case SlaStatus.overdue:
        final overdueDuration = currentTime.difference(task.dueDate);
        if (overdueDuration.inDays >= 1) {
          final days = overdueDuration.inDays;
          return 'Overdue — Deadline passed $days ${days == 1 ? "day" : "days"} ago.';
        } else {
          final hours = overdueDuration.inHours;
          return 'Overdue — Deadline passed $hours ${hours == 1 ? "hour" : "hours"} ago.';
        }

      case SlaStatus.atRisk:
        final remaining = task.dueDate.difference(currentTime);
        final hoursLeft = remaining.inHours;
        final threshold = task.priority == TaskPriority.high
            ? '72h'
            : (task.priority == TaskPriority.medium ? '48h' : '24h');
        return 'At Risk — ${task.priority.label} priority task within $threshold warning window ($hoursLeft hours left).';

      case SlaStatus.onTrack:
        final remaining = task.dueDate.difference(currentTime);
        final daysLeft = remaining.inDays;
        if (daysLeft >= 1) {
          return 'On Track — $daysLeft ${daysLeft == 1 ? "day" : "days"} remaining until deadline.';
        } else {
          return 'On Track — ${remaining.inHours} hours remaining until deadline.';
        }
    }
  }

  /// Calculates SLA status summary counts for a list of tasks.
  /// Used by Member 1's Dashboard and Member 3's Statistics screen.
  static Map<SlaStatus, int> getSlaSummaryCounts(List<Task> tasks, {DateTime? now}) {
    final Map<SlaStatus, int> counts = {
      SlaStatus.onTrack: 0,
      SlaStatus.atRisk: 0,
      SlaStatus.overdue: 0,
      SlaStatus.completed: 0,
    };

    for (final task in tasks) {
      final status = calculateSlaStatus(task, now: now);
      counts[status] = (counts[status] ?? 0) + 1;
    }

    return counts;
  }

  /// Computes the SLA Compliance Rate percentage across a list of tasks.
  /// Compliance Rate = % of tasks that are NOT overdue.
  static double getSlaComplianceRate(List<Task> tasks, {DateTime? now}) {
    if (tasks.isEmpty) return 100.0;

    final summary = getSlaSummaryCounts(tasks, now: now);
    final overdueCount = summary[SlaStatus.overdue] ?? 0;
    final nonOverdueCount = tasks.length - overdueCount;

    return (nonOverdueCount / tasks.length) * 100.0;
  }
}
