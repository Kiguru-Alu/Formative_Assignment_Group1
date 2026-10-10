import 'package:flutter/material.dart';

import '../models/task_enums.dart';
import '../models/task_model.dart';
import '../models/team_member.dart';
import '../services/sla_calculator.dart';
import '../utils/due_labels.dart';
import 'member_avatar.dart';
import 'priority_label.dart';
import 'sla_status_badge.dart';

class UrgencyTaskCard extends StatelessWidget {
  final Task task;
  final TeamMember? assignee;
  final VoidCallback onTap;
  final VoidCallback? onComplete;

  const UrgencyTaskCard({
    super.key,
    required this.task,
    required this.assignee,
    required this.onTap,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sla = SlaCalculator.calculateSlaStatus(task);
    final meta = theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant, fontSize: 12);
    final firstName = assignee?.name.split(' ').first ?? 'Unassigned';
    final canComplete = onComplete != null && sla != SlaStatus.completed;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 4, color: sla.color),
              Expanded(
                child: InkWell(
                  onTap: onTap,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                task.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                              ),
                            ),
                            const SizedBox(width: 8),
                            SlaStatusBadge(status: sla),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 12,
                          runSpacing: 6,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Row(mainAxisSize: MainAxisSize.min, children: [
                              MemberAvatar(member: assignee, size: 20),
                              const SizedBox(width: 4),
                              Text(firstName, style: meta),
                            ]),
                            Row(mainAxisSize: MainAxisSize.min, children: [
                              Icon(Icons.event_outlined, size: 16, color: scheme.onSurfaceVariant),
                              const SizedBox(width: 4),
                              Text('${dueLabel(task)} \u00B7 ${shortDate(task.dueDate)}', style: meta),
                            ]),
                            PriorityLabel(priority: task.priority),
                          ],
                        ),
                        if (sla != SlaStatus.completed) ...[
                          const SizedBox(height: 8),
                          ExcludeSemantics(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(2),
                              child: LinearProgressIndicator(
                                value: elapsedFraction(task),
                                minHeight: 4,
                                backgroundColor: scheme.surfaceContainerHighest,
                                color: sla.color,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              if (canComplete)
                Container(
                  width: 52,
                  decoration: BoxDecoration(border: Border(left: BorderSide(color: scheme.outlineVariant))),
                  child: Center(
                    child: IconButton(
                      tooltip: 'Mark "${task.title}" complete',
                      icon: Icon(Icons.check, color: scheme.primary),
                      onPressed: onComplete,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
