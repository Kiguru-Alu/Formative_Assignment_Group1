import 'package:flutter/material.dart';
import '../models/task_enums.dart';
import '../models/task_model.dart';
import '../models/team_member.dart';
import '../services/local_storage_service.dart';
import '../services/sla_calculator.dart';

/// Screen presenting comprehensive SLA performance metrics, vertical status bar chart,
/// priority breakdown, team workload distribution, and SLA rule guidelines.
class StatisticsScreen extends StatefulWidget {
  final LocalStorageService storageService;

  const StatisticsScreen({
    super.key,
    required this.storageService,
  });

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  List<Task> _tasks = [];
  List<TeamMember> _members = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final tasks = await widget.storageService.loadTasks();
    final members = await widget.storageService.loadTeamMembers();

    if (mounted) {
      setState(() {
        _tasks = tasks;
        _members = members;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final summaryCounts = SlaCalculator.getSlaSummaryCounts(_tasks);
    final complianceRate = SlaCalculator.getSlaComplianceRate(_tasks);
    final overdueCount = summaryCounts[SlaStatus.overdue] ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SLA Analytics & Metrics',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- 1. SLA OVERVIEW METRICS CARDS ---
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricCard(
                          title: 'Total Tasks',
                          value: '${_tasks.length}',
                          icon: Icons.task_outlined,
                          color: const Color(0xFF4F46E5), // Indigo
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildMetricCard(
                          title: 'SLA Compliance',
                          value: '${complianceRate.toStringAsFixed(1)}%',
                          icon: Icons.verified_outlined,
                          color: complianceRate >= 80.0
                              ? const Color(0xFF10B981)
                              : const Color(0xFFF59E0B),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildMetricCard(
                          title: 'Overdue',
                          value: '$overdueCount',
                          icon: Icons.error_outline,
                          color: const Color(0xFFEF4444),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // --- 2. TASK STATUS VERTICAL BAR CHART ---
                  _buildBarChartCard(summaryCounts),
                  const SizedBox(height: 20),

                  // --- 3. PRIORITY & WORKLOAD BREAKDOWN ---
                  _buildPriorityBreakdownCard(),
                  const SizedBox(height: 20),
                  _buildWorkloadBreakdownCard(),
                  const SizedBox(height: 20),

                  // --- 4. SLA RULE REFERENCE CARD ---
                  _buildSlaRulesReferenceCard(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChartCard(Map<SlaStatus, int> summaryCounts) {
    final maxCount = summaryCounts.values.fold<int>(
      1,
      (max, count) => count > max ? count : max,
    );

    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'SLA Status Distribution',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Icon(Icons.bar_chart, color: Colors.grey[600]),
              ],
            ),
            const SizedBox(height: 24),

            // Pure Flutter Bar Chart Container
            SizedBox(
              height: 180,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: SlaStatus.values.map((status) {
                  final count = summaryCounts[status] ?? 0;
                  final double heightRatio =
                      _tasks.isEmpty ? 0 : (count / maxCount);
                  final double barHeight = (heightRatio * 120).clamp(8.0, 120.0);

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '$count',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: status.color,
                        ),
                      ),
                      const SizedBox(height: 6),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeOutCubic,
                        width: 42,
                        height: barHeight,
                        decoration: BoxDecoration(
                          color: status.color,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(8),
                          ),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              status.color,
                              status.color.withValues(alpha: 0.7),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        status.label,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityBreakdownCard() {
    final Map<TaskPriority, int> priorityCounts = {
      TaskPriority.high: 0,
      TaskPriority.medium: 0,
      TaskPriority.low: 0,
    };

    for (final task in _tasks) {
      priorityCounts[task.priority] = (priorityCounts[task.priority] ?? 0) + 1;
    }

    final total = _tasks.length;

    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tasks by Priority',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ...TaskPriority.values.map((priority) {
              final count = priorityCounts[priority] ?? 0;
              final double percentage =
                  total == 0 ? 0 : (count / total);

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: priority.color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${priority.label} Priority',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '$count (${(percentage * 100).toStringAsFixed(0)}%)',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: percentage,
                        minHeight: 8,
                        backgroundColor: Colors.grey[200],
                        valueColor:
                            AlwaysStoppedAnimation<Color>(priority.color),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkloadBreakdownCard() {
    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Team Workload Breakdown',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 14),
            ..._members.map((member) {
              final memberTasks =
                  _tasks.where((t) => t.assignedMemberId == member.id).toList();
              final overdue = memberTasks
                  .where((t) =>
                      SlaCalculator.calculateSlaStatus(t) == SlaStatus.overdue)
                  .length;
              final atRisk = memberTasks
                  .where((t) =>
                      SlaCalculator.calculateSlaStatus(t) == SlaStatus.atRisk)
                  .length;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: const Color(0xFF4F46E5),
                      child: Text(
                        member.initials,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            member.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            member.role,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${memberTasks.length} ${memberTasks.length == 1 ? "task" : "tasks"}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        if (overdue > 0 || atRisk > 0)
                          Text(
                            '${overdue > 0 ? "$overdue overdue " : ""}${atRisk > 0 ? "$atRisk at risk" : ""}',
                            style: const TextStyle(
                              color: Color(0xFFEF4444),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSlaRulesReferenceCard() {
    return Card(
      elevation: 1.5,
      color: const Color(0xFF1E293B), // Deep Indigo / Dark Slate
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text(
                  'SLA Threshold Reference Rules',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildRuleRow(
              'High Priority',
              '<= 72 Hours Warning Window',
              const Color(0xFFEF4444),
            ),
            _buildRuleRow(
              'Medium Priority',
              '<= 48 Hours Warning Window',
              const Color(0xFFF59E0B),
            ),
            _buildRuleRow(
              'Low Priority',
              '<= 24 Hours Warning Window',
              const Color(0xFF06B6D4),
            ),
            _buildRuleRow(
              'Overdue Rule',
              'Current time > Task Due Date',
              const Color(0xFFF43F5E),
            ),
            _buildRuleRow(
              'Completed Rule',
              'Delivered task (Status == Completed)',
              const Color(0xFF10B981),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRuleRow(String label, String detail, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Text(
            '$label: ',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          Expanded(
            child: Text(
              detail,
              style: TextStyle(
                color: Colors.grey[300],
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
