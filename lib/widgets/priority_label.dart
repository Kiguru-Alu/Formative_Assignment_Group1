import 'package:flutter/material.dart';

import '../models/task_enums.dart';

class PriorityLabel extends StatelessWidget {
  final TaskPriority priority;

  const PriorityLabel({super.key, required this.priority});

  @override
  Widget build(BuildContext context) {
    return Text(
      '${priority.label} priority',
      style: TextStyle(fontSize: 12, color: priority.color, fontWeight: FontWeight.w500),
    );
  }
}
