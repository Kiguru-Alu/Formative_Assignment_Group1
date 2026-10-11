import '../models/task.dart';
import '../models/task_enums.dart';
import '../models/task_model.dart' as shared;
import '../services/sla_calculator.dart' as shared_sla;

class SlaCalculator {
  SlaCalculator._();

  static SlaStatus calculate(Task task, {DateTime? now}) {
    return shared_sla.SlaCalculator.calculateSlaStatus(
      shared.Task.fromJson(task.toJson()),
      now: now,
    );
  }
}
