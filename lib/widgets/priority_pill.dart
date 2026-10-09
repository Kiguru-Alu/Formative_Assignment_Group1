import 'package:flutter/material.dart';

import '../models/task_enums.dart';

class PriorityPill extends StatelessWidget {
  final TaskPriority priority;

  const PriorityPill({super.key, required this.priority});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (bg, fg, border) = switch (priority) {
      TaskPriority.high => (scheme.onSurface, scheme.surface, Colors.transparent),
      TaskPriority.medium => (scheme.surfaceContainerHighest, scheme.onSurface, Colors.transparent),
      TaskPriority.low => (Colors.transparent, scheme.onSurfaceVariant, scheme.outlineVariant),
    };
    return Container(
      padding: const EdgeInsets.fromLTRB(5, 2, 8, 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(priority == TaskPriority.high ? Icons.flag : Icons.flag_outlined, size: 14, color: fg),
          const SizedBox(width: 3),
          Text(priority.label, style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
