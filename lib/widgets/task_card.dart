import 'package:flutter/material.dart';
import '../models/task.dart';
import '../models/task_enums.dart';
import '../models/team_member.dart';
import '../utils/sla_calculator.dart';
import 'sla_chip.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final TeamMember? assignee;
  final VoidCallback onTap;

  const TaskCard({
    super.key,
    required this.task,
    required this.assignee,
    required this.onTap,
  });

  static String _formatDate(DateTime date) {
    final monthNames = <String>[
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];

    return '${monthNames[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final slaStatus = SlaCalculator.calculate(task);
    final assigneeName = assignee?.name ?? 'Unassigned';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      task.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  SlaChip(status: slaStatus, compact: true),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.person_outline, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(assigneeName, style: const TextStyle(color: Colors.grey)),
                  const SizedBox(width: 16),
                  const Icon(Icons.event_outlined, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(_formatDate(task.dueDate), style: const TextStyle(color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 6),
              _PriorityTag(priority: task.priority),
            ],
          ),
        ),
      ),
    );
  }
}

class _PriorityTag extends StatelessWidget {
  final TaskPriority priority;
  const _PriorityTag({required this.priority});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        '${priority.label} priority',
        style: TextStyle(fontSize: 12, color: priority.color, fontWeight: FontWeight.w500),
      ),
    );
  }
}