import 'package:flutter/material.dart';

import '../app/theme.dart';
import '../models/task_enums.dart';

class SlaStatusBadge extends StatelessWidget {
  final SlaStatus status;

  const SlaStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final fg = AppColors.slaForeground(status, brightness);
    final bg = AppColors.slaBackground(status, brightness);
    return Container(
      padding: const EdgeInsets.fromLTRB(6, 3, 8, 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.icon, size: 14, color: fg),
          const SizedBox(width: 4),
          Text(
            status.label,
            style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
