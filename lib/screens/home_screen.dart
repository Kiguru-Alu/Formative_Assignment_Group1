import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../app/task_screens.dart';
import '../app/theme.dart';
import '../models/task_enums.dart';
import '../models/task_model.dart';
import '../models/team_member.dart';
import '../services/local_storage_service.dart';
import '../services/sla_calculator.dart';
import '../utils/due_labels.dart';
import '../widgets/health_panel.dart';
import '../widgets/member_avatar.dart';
import '../widgets/sla_status_badge.dart';
import '../widgets/theme_toggle_button.dart';
import '../widgets/urgency_task_card.dart';
import 'statistics_screen.dart';

class HomeScreen extends StatefulWidget {
  final LocalStorageService storageService;

  final ValueListenable<int> refreshSignal;

  final VoidCallback onOpenTasks;
  final VoidCallback onOpenProfile;
  final VoidCallback onTasksChanged;

  const HomeScreen({
    super.key,
    required this.storageService,
    required this.refreshSignal,
    required this.onOpenTasks,
    required this.onOpenProfile,
    required this.onTasksChanged,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Task> _tasks = const [];
  Map<String, TeamMember> _membersById = const {};
  TeamMember? _user;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    widget.refreshSignal.addListener(_load);
    _load();
  }

  @override
  void dispose() {
    widget.refreshSignal.removeListener(_load);
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final tasks = await widget.storageService.loadTasks();
      final members = await widget.storageService.loadTeamMembers();
      final user = await widget.storageService.getCurrentUser();
      if (!mounted) return;
      setState(() {
        _tasks = tasks;
        _membersById = {for (final m in members) m.id: m};
        _user = user;
        _error = null;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Could not load your tasks.';
        _loading = false;
      });
    }
  }

  List<Task> _needsAttention() {
    final items = <(Task, SlaStatus)>[];
    for (final t in _tasks) {
      final s = SlaCalculator.calculateSlaStatus(t);
      if (s == SlaStatus.overdue || s == SlaStatus.atRisk) items.add((t, s));
    }
    int rank(SlaStatus s) => s == SlaStatus.overdue ? 0 : 1;
    items.sort((a, b) {
      final byStatus = rank(a.$2).compareTo(rank(b.$2));
      return byStatus != 0 ? byStatus : a.$1.dueDate.compareTo(b.$1.dueDate);
    });
    return [for (final i in items) i.$1];
  }

  Future<void> _openTask(Task task) async {
    await openTaskDetails(context, task.id);
    if (!mounted) return;
    widget.onTasksChanged();
    _load();
  }

  Future<void> _createTask() async {
    final created = await openCreateTask(context);
    if (!mounted) return;
    if (created == true) widget.onTasksChanged();
    _load();
  }

  Future<void> _complete(Task task) async {
    final updated = task.copyWith(
      status: TaskStatus.completed,
      updatedAt: DateTime.now(),
      lastActivityText: '${_user?.name ?? 'A teammate'} marked this task complete',
    );
    await widget.storageService.updateTask(updated);
    await _load();
    if (!mounted) return;
    widget.onTasksChanged();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text('Marked "${task.title}" complete'),
        persist: false,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () async {
            await widget.storageService.updateTask(task);
            await _load();
            if (mounted) widget.onTasksChanged();
          },
        ),
      ));
  }

  void _openInsights() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => StatisticsScreen(storageService: widget.storageService)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final firstName = (_user?.name ?? '').trim().split(RegExp(r'\s+')).first;
    final greeting = firstName.isEmpty ? 'Hello' : 'Hello, $firstName';

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(greeting, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            Text(longDate(DateTime.now()),
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: scheme.onSurfaceVariant)),
          ],
        ),
        actions: [
          const ThemeToggleButton(),
          IconButton(
            tooltip: 'Open profile',
            onPressed: widget.onOpenProfile,
            icon: MemberAvatar(member: _user, size: 32),
          ),
          const SizedBox(width: 4),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createTask,
        tooltip: 'Create task',
        child: const Icon(Icons.add),
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_loading) return const _HomeSkeleton();
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 44, color: Theme.of(context).colorScheme.onSurfaceVariant),
              const SizedBox(height: 8),
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  setState(() => _loading = true);
                  _load();
                },
                child: const Text('Try again'),
              ),
            ],
          ),
        ),
      );
    }

    final counts = SlaCalculator.getSlaSummaryCounts(_tasks);
    final compliance = SlaCalculator.getSlaComplianceRate(_tasks);
    final attentionAll = _needsAttention();
    final attention = attentionAll.take(4).toList();
    final shownIds = attention.map((t) => t.id).toSet();
    final now = DateTime.now();
    final upcoming = (_tasks
            .where((t) =>
                t.status != TaskStatus.completed && t.dueDate.isAfter(now) && !shownIds.contains(t.id))
            .toList()
          ..sort((a, b) => a.dueDate.compareTo(b.dueDate)))
        .take(3)
        .toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      children: [
        HealthPanel(counts: counts, complianceRate: compliance, onTileTap: widget.onOpenTasks),
        if (_tasks.isEmpty)
          _EmptyState(onCreate: _createTask)
        else ...[
          _SectionHeader(
            title: 'Needs attention',
            badge: attentionAll.length,
            onSeeAll: widget.onOpenTasks,
          ),
          if (attention.isEmpty)
            const _AllClear()
          else
            for (final t in attention)
              UrgencyTaskCard(
                task: t,
                assignee: _membersById[t.assignedMemberId],
                onTap: () => _openTask(t),
                onComplete: () => _complete(t),
              ),
          const _SectionHeader(title: 'Upcoming deadlines'),
          if (upcoming.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text('No other upcoming deadlines.',
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            )
          else
            for (final t in upcoming)
              _DeadlineRow(
                task: t,
                assignee: _membersById[t.assignedMemberId],
                onTap: () => _openTask(t),
              ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: Icon(Icons.insights_outlined, color: Theme.of(context).colorScheme.primary),
              title: const Text('Project insights', style: TextStyle(fontWeight: FontWeight.w700)),
              subtitle: const Text('Workload, priorities and more'),
              trailing: const Icon(Icons.chevron_right),
              onTap: _openInsights,
            ),
          ),
        ],
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final int? badge;
  final VoidCallback? onSeeAll;

  const _SectionHeader({required this.title, this.badge, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Row(
        children: [
          Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
          if (badge != null && badge! > 0) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
              decoration: BoxDecoration(
                color: AppColors.overdueSolid,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text('$badge',
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
            ),
          ],
          const Spacer(),
          if (onSeeAll != null) TextButton(onPressed: onSeeAll, child: const Text('See all')),
        ],
      ),
    );
  }
}

class _AllClear extends StatelessWidget {
  const _AllClear();

  @override
  Widget build(BuildContext context) {
    final b = Theme.of(context).brightness;
    final fg = AppColors.slaForeground(SlaStatus.onTrack, b);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.slaBackground(SlaStatus.onTrack, b),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(Icons.verified_outlined, color: fg, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('All clear', style: TextStyle(color: fg, fontWeight: FontWeight.w700)),
                Text('No tasks are at risk or overdue.', style: TextStyle(color: fg, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onCreate;

  const _EmptyState({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    final sub = Theme.of(context).colorScheme.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Icon(Icons.assignment_outlined, size: 44, color: sub),
          const SizedBox(height: 8),
          const Text('No tasks yet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text('Create your first task to start tracking SLAs.', style: TextStyle(color: sub)),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onCreate,
            icon: const Icon(Icons.add),
            label: const Text('Create task'),
          ),
        ],
      ),
    );
  }
}

class _DeadlineRow extends StatelessWidget {
  final Task task;
  final TeamMember? assignee;
  final VoidCallback onTap;

  const _DeadlineRow({required this.task, required this.assignee, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final sla = SlaCalculator.calculateSlaStatus(task);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 60),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('${task.dueDate.day}',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, height: 1.1)),
                        Text(shortDate(task.dueDate).split(' ').last,
                            style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant, height: 1.1)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(task.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w700)),
                        Text('${assignee?.name ?? 'Unassigned'} \u00B7 ${dueLabel(task)}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  SlaStatusBadge(status: sla),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeSkeleton extends StatelessWidget {
  const _HomeSkeleton();

  @override
  Widget build(BuildContext context) {
    final fill = Theme.of(context).colorScheme.surfaceContainerHighest;
    Widget block(double h) => Container(
          height: h,
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(color: fill, borderRadius: BorderRadius.circular(14)),
        );
    return Semantics(
      label: 'Loading',
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [block(200), block(88), block(88)],
      ),
    );
  }
}
