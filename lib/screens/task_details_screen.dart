import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import '../models/task.dart';
import '../models/task_enums.dart';
import '../models/team_member.dart';
import '../services/task_storage_service.dart';
import '../services/sample_team_members.dart';
import '../utils/sla_calculator.dart';
import '../widgets/sla_chip.dart';
import 'task_form_screen.dart';

class TaskDetailsScreen extends StatefulWidget {
  final String taskId;
  const TaskDetailsScreen({super.key, required this.taskId});

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  final TaskStorageService _storage = TaskStorageService();
  Task? _task;
  TeamMember? _assignee;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTask();
  }

  Future<void> _loadTask() async {
    final tasks = await _storage.loadTasks();
    final match = tasks.where((t) => t.id == widget.taskId).toList();
    final task = match.isNotEmpty ? match.first : null;

    TeamMember? assignee;
    if (task != null) {
      final memberMatch = sampleTeamMembers.where((m) => m.id == task.assignedMemberId);
      assignee = memberMatch.isNotEmpty ? memberMatch.first : null;
    }

    setState(() {
      _task = task;
      _assignee = assignee;
      _isLoading = false;
    });
  }

  Future<void> _updateStatus(TaskStatus newStatus) async {
    final task = _task;
    if (task == null) return;
    final updated = task.copyWith(
      status: newStatus,
      updatedAt: DateTime.now(),
      lastActivityText: 'Status changed to "${newStatus.label}"',
    );
    await _storage.updateTask(updated);
    setState(() => _task = updated);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Status updated to "${newStatus.label}"')),
      );
    }
  }

  Future<void> _editTask() async {
    final task = _task;
    if (task == null) return;
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => TaskFormScreen(existingTask: task)),
    );
    if (result == true) _loadTask();
  }

  Future<void> _confirmDelete() async {
    final task = _task;
    if (task == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete task?'),
        content: Text('This will permanently delete "${task.title}".'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _storage.deleteTask(task.id);
      if (mounted) Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
        actions: _task == null
            ? null
            : [
                IconButton(icon: const Icon(Icons.edit_outlined), onPressed: _editTask),
                IconButton(icon: const Icon(Icons.delete_outline), onPressed: _confirmDelete),
              ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _task == null
              ? const Center(child: Text('Task not found.'))
              : _buildDetails(_task!),
    );
  }

  Widget _buildDetails(Task task) {
    final slaStatus = SlaCalculator.calculate(task);
    final dateFormat = intl.DateFormat('EEEE, MMM d, yyyy');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(task.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              ),
              SlaChip(status: slaStatus),
            ],
          ),
          const SizedBox(height: 4),
          Text(task.category, style: TextStyle(color: Colors.grey.shade600, fontStyle: FontStyle.italic)),
          const SizedBox(height: 16),
          _InfoRow(icon: Icons.person_outline, label: 'Assignee', value: _assignee?.name ?? 'Unassigned'),
          _InfoRow(icon: Icons.flag_outlined, label: 'Priority', value: task.priority.label),
          _InfoRow(icon: Icons.event_outlined, label: 'Due Date', value: dateFormat.format(task.dueDate)),
          _InfoRow(icon: Icons.schedule_outlined, label: 'Created', value: dateFormat.format(task.createdAt)),
          _InfoRow(icon: Icons.update_outlined, label: 'Updated', value: dateFormat.format(task.updatedAt)),
          const SizedBox(height: 16),
          const Text('Description', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(
            task.description.isEmpty ? 'No description provided.' : task.description,
            style: TextStyle(color: task.description.isEmpty ? Colors.grey : null),
          ),
          const SizedBox(height: 16),
          const Text('Notes', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(
            task.notes.isEmpty ? 'No notes added.' : task.notes,
            style: TextStyle(color: task.notes.isEmpty ? Colors.grey : null),
          ),
          const SizedBox(height: 16),
          Text('Last activity: ${task.lastActivityText}',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
          const SizedBox(height: 24),
          const Text('Update Status', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: TaskStatus.values.map((status) {
              final isSelected = task.status == status;
              return ChoiceChip(
                label: Text(status.label),
                selected: isSelected,
                onSelected: (_) => _updateStatus(status),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade700),
          const SizedBox(width: 10),
          SizedBox(width: 90, child: Text(label, style: TextStyle(color: Colors.grey.shade700))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}