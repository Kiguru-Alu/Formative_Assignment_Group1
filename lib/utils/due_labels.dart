import '../models/task_enums.dart';
import '../models/task_model.dart';

const List<String> _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
const List<String> _monthsLong = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
const List<String> _weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

String shortDate(DateTime d) => '${d.day} ${_months[d.month - 1]}';

String longDate(DateTime d) => '${_weekdays[d.weekday - 1]}, ${d.day} ${_monthsLong[d.month - 1]}';

String dueLabel(Task task, {DateTime? now}) {
  final current = now ?? DateTime.now();
  if (task.status == TaskStatus.completed) return 'Completed';

  if (current.isAfter(task.dueDate)) {
    final over = current.difference(task.dueDate);
    if (over.inDays >= 1) {
      final d = over.inDays;
      return '$d ${d == 1 ? 'day' : 'days'} overdue';
    }
    final h = over.inHours < 1 ? 1 : over.inHours;
    return '$h ${h == 1 ? 'hour' : 'hours'} overdue';
  }

  final left = task.dueDate.difference(current);
  if (left.inHours < 24) {
    final h = left.inHours < 1 ? 1 : left.inHours;
    return 'Due in $h ${h == 1 ? 'hour' : 'hours'}';
  }
  if (left.inHours < 48) return 'Due tomorrow';
  return 'Due in ${left.inDays} days';
}

double elapsedFraction(Task task, {DateTime? now}) {
  if (task.status == TaskStatus.completed) return 1;
  final current = now ?? DateTime.now();
  final total = task.dueDate.difference(task.createdAt).inMinutes;
  if (total <= 0) return 1;
  final done = current.difference(task.createdAt).inMinutes;
  return (done / total).clamp(0.04, 1.0).toDouble();
}
