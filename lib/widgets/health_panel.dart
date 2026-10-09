import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../app/theme.dart';
import '../models/task_enums.dart';

class HealthPanel extends StatelessWidget {
  final Map<SlaStatus, int> counts;
  final double complianceRate;
  final VoidCallback onTileTap;

  const HealthPanel({
    super.key,
    required this.counts,
    required this.complianceRate,
    required this.onTileTap,
  });

  static const List<SlaStatus> _ringOrder = [
    SlaStatus.onTrack,
    SlaStatus.atRisk,
    SlaStatus.overdue,
    SlaStatus.completed,
  ];
  static const List<SlaStatus> _tileOrder = [
    SlaStatus.overdue,
    SlaStatus.atRisk,
    SlaStatus.onTrack,
    SlaStatus.completed,
  ];

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final total = counts.values.fold<int>(0, (a, b) => a + b);
    final needAttention = (counts[SlaStatus.overdue] ?? 0) + (counts[SlaStatus.atRisk] ?? 0);
    final percent = complianceRate.round();
    final summary = needAttention == 0
        ? '$total tasks \u00B7 nothing needs attention'
        : '$total tasks \u00B7 $needAttention need attention';

    return Semantics(
      container: true,
      label: 'Project health. $percent percent SLA compliance. $summary.',
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: dark ? AppColors.navyDark : AppColors.navy,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Row(
              children: [
                SizedBox(
                  width: 100,
                  height: 100,
                  child: ExcludeSemantics(
                    child: CustomPaint(
                      painter: _RingPainter(counts: counts, order: _ringOrder),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('$percent%',
                                style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
                            const Text('compliance',
                                style: TextStyle(color: AppColors.onNavyMuted, fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Project health',
                          style: TextStyle(color: AppColors.onNavy, fontSize: 16, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      Text(summary, style: const TextStyle(color: AppColors.onNavyMuted, fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(child: _tile(_tileOrder[0])),
              const SizedBox(width: 8),
              Expanded(child: _tile(_tileOrder[1])),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: _tile(_tileOrder[2])),
              const SizedBox(width: 8),
              Expanded(child: _tile(_tileOrder[3])),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _tile(SlaStatus status) {
    final count = counts[status] ?? 0;
    return Semantics(
      button: true,
      label: '${status.label}: $count ${count == 1 ? 'task' : 'tasks'}',
      excludeSemantics: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTileTap,
          child: Ink(
            decoration: BoxDecoration(
              color: const Color(0x0DFFFFFF),
              border: Border.all(color: const Color(0x1FFFFFFF)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 48),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(color: status.color, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(status.label,
                          style: const TextStyle(color: AppColors.onNavy, fontSize: 13)),
                    ),
                    Text('$count',
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final Map<SlaStatus, int> counts;
  final List<SlaStatus> order;

  _RingPainter({required this.counts, required this.order});

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 12.0;
    final arcRect = (Offset.zero & size).deflate(stroke / 2);
    final total = counts.values.fold<int>(0, (a, b) => a + b);

    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = const Color(0x1FFFFFFF);
    canvas.drawArc(arcRect, 0, 2 * math.pi, false, track);
    if (total == 0) return;

    var start = -math.pi / 2;
    for (final status in order) {
      final c = counts[status] ?? 0;
      if (c == 0) continue;
      final sweep = c / total * 2 * math.pi;
      final gap = c == total ? 0.0 : 0.04;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = status.color;
      canvas.drawArc(arcRect, start, math.max(sweep - gap, 0.01), false, paint);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) => true;
}
