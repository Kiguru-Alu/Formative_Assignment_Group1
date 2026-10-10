import 'package:flutter/material.dart';
import '../models/task.dart';
import '../models/task_enums.dart';
import '../models/team_member.dart';
import '../services/task_storage_service.dart';
import '../services/sample_data.dart';
import '../services/sample_team_members.dart';
import '../utils/sla_calculator.dart';
import '../widgets/task_card.dart';
import 'task_details_screen.dart';
import 'task_form_screen.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final TaskStorageService _storage = TaskStorageService();

  List<Task> _allTasks = [];
  Map<String, TeamMember> _membersById = {};
  bool _isLoading = true;

  String _searchQuery = '';
  SlaStatus? _slaFilter;
  TaskPriority? _priorityFilter;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await _storage.seedIfEmpty(buildSampleTasks());
    _membersById = {for (final m in sampleTeamMembers) m.id: m};
    await _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() => _isLoading = true);
    final tasks = await _storage.loadTasks();
    setState(() {
      _allTasks = tasks;
      _isLoading = false;
    });
  }

  List<Task> get _filteredTasks {
    return _allTasks.where((task) {
      final matchesSearch =
          _searchQuery.isEmpty || task.title.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesSla = _slaFilter == null || SlaCalculator.calculate(task) == _slaFilter;
      final matchesPriority = _priorityFilter == null || task.priority == _priorityFilter;
      return matchesSearch && matchesSla && matchesPriority;
    }).toList()
      ..sort((a, b) {
        final aDone = a.status == TaskStatus.completed;
        final bDone = b.status == TaskStatus.completed;
        if (aDone != bDone) return aDone ? 1 : -1;
        return a.dueDate.compareTo(b.dueDate);
      });
  }

  Future<void> _openTaskDetails(Task task) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => TaskDetailsScreen(taskId: task.id)),
    );
    if (mounted) _loadTasks();
  }

  Future<void> _openCreateTask() async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const TaskFormScreen()),
    );
    if (created == true) _loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredTasks;

    return Scaffold(
      appBar: AppBar(title: const Text('Tasks')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildSearchAndFilters(),
                Expanded(
                  child: filtered.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.only(top: 8, bottom: 80),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final task = filtered[index];
                            return TaskCard(
                              task: task,
                              assignee: _membersById[task.assignedMemberId],
                              onTap: () => _openTaskDetails(task),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openCreateTask,
        tooltip: 'Create task',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Search tasks by title...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              isDense: true,
            ),
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildSlaFilterChip(null, 'All'),
                for (final status in SlaStatus.values) _buildSlaFilterChip(status, status.label),
                const SizedBox(width: 12),
                _buildPriorityDropdown(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlaFilterChip(SlaStatus? status, String label) {
    final isSelected = _slaFilter == status;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => setState(() => _slaFilter = status),
      ),
    );
  }

  Widget _buildPriorityDropdown() {
    return DropdownButton<TaskPriority?>(
      value: _priorityFilter,
      hint: const Text('Priority'),
      items: [
        const DropdownMenuItem(value: null, child: Text('All priorities')),
        ...TaskPriority.values.map((p) => DropdownMenuItem(value: p, child: Text(p.label))),
      ],
      onChanged: (value) => setState(() => _priorityFilter = value),
    );
  }

  Widget _buildEmptyState() {
    final hasActiveFilters = _searchQuery.isNotEmpty || _slaFilter != null || _priorityFilter != null;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_outlined, size: 56, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              hasActiveFilters
                  ? 'No tasks match your search or filters.'
                  : 'No tasks yet. Tap + to create one.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}