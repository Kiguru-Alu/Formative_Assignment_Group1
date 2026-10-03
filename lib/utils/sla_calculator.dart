import '../models/task.dart';
import '../models/task_enums.dart';

class SlaCalculator {
  SlaCalculator._();

  static const int atRiskWindowHours = 48;

  static SlaStatus calculate(Task task, {DateTime? now}) {
    final currentTime = now ?? DateTime.now();

    if (task.status == TaskStatus.completed) {
      return SlaStatus.completed;
    }

    if (task.dueDate.isBefore(currentTime)) {
      return SlaStatus.overdue;
    }

    final hoursRemaining = task.dueDate.difference(currentTime).inHours;
    if (hoursRemaining <= atRiskWindowHours) {
      return SlaStatus.atRisk;
    }

    return SlaStatus.onTrack;
  }
}