import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/task.dart';
import '../models/task_enums.dart';
import '../services/task_storage_service.dart';
import '../services/sample_team_members.dart';
class Validators {
  static String? requiredField(String? value, {required String fieldName}) =>
      value == null || value.trim().isEmpty ? '$fieldName is required.' : null;

  static String? title(String? value) => requiredField(value, fieldName: 'Title');

  static String? description(String? value) => null;

  static String? assignee(String? value) =>
      value == null ? 'Please select an assignee.' : null;

  static String? deadline(
    DateTime? date, {
    required bool isEditingExisting,
    DateTime? originalDeadline,
  }) {
    if (date == null) return 'Due date is required.';
    final selected = DateTime(date.year, date.month, date.day);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final isUnchangedPastDate = isEditingExisting &&
        originalDeadline != null &&
        date.year == originalDeadline.year &&
        date.month == originalDeadline.month &&
        date.day == originalDeadline.day;
    if (selected.isBefore(today) && !isUnchangedPastDate) {
      return 'Due date cannot be in the past.';
    }
    return null;
  }
}

class TaskFormScreen extends StatefulWidget {
  final Task? existingTask;
  const TaskFormScreen({super.key, this.existingTask});

  bool get isEditing => existingTask != null;

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TaskStorageService _storage = TaskStorageService();
  static const _uuid = Uuid();

  late final TextEditingController _titleController;
  late final TextEditingController _categoryController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _notesController;

  String? _selectedAssigneeId;
  TaskPriority _selectedPriority = TaskPriority.medium;
  TaskStatus _selectedStatus = TaskStatus.toDo;
  DateTime? _selectedDueDate;

  bool _isSaving = false;
  bool _dueDateTouched = false;

  String _formatDate(DateTime date) {
    const months = <String>[
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  void initState() {
    super.initState();
    final existing = widget.existingTask;
    _titleController = TextEditingController(text: existing?.title ?? '');
    _categoryController = TextEditingController(text: existing?.category ?? '');
    _descriptionController = TextEditingController(text: existing?.description ?? '');
    _notesController = TextEditingController(text: existing?.notes ?? '');
    _selectedAssigneeId = existing?.assignedMemberId;
    _selectedPriority = existing?.priority ?? TaskPriority.medium;
    _selectedStatus = existing?.status ?? TaskStatus.toDo;
    _selectedDueDate = existing?.dueDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _categoryController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 2)),
    );
    if (picked != null) {
      setState(() {
        _selectedDueDate = picked;
        _dueDateTouched = true;
      });
    }
  }

  String? get _dueDateError => Validators.deadline(
        _selectedDueDate,
        isEditingExisting: widget.isEditing,
        originalDeadline: widget.existingTask?.dueDate,
      );

  Future<void> _handleSave() async {
    setState(() => _dueDateTouched = true);

    final isFormValid = _formKey.currentState?.validate() ?? false;
    final isDueDateValid = _dueDateError == null;

    if (!isFormValid || !isDueDateValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fix the errors before saving.')),
      );
      return;
    }

    setState(() => _isSaving = true);
    final now = DateTime.now();

    if (widget.isEditing) {
      final updated = widget.existingTask!.copyWith(
        title: _titleController.text.trim(),
        category: _categoryController.text.trim(),
        description: _descriptionController.text.trim(),
        notes: _notesController.text.trim(),
        assignedMemberId: _selectedAssigneeId,
        priority: _selectedPriority,
        dueDate: _selectedDueDate,
        status: _selectedStatus,
        updatedAt: now,
        lastActivityText: 'Task edited',
      );
      await _storage.updateTask(updated);
    } else {
      final newTask = Task(
        id: _uuid.v4(),
        title: _titleController.text.trim(),
        category: _categoryController.text.trim(),
        description: _descriptionController.text.trim(),
        assignedMemberId: _selectedAssigneeId!,
        createdAt: now,
        dueDate: _selectedDueDate!,
        priority: _selectedPriority,
        status: _selectedStatus,
        notes: _notesController.text.trim(),
        updatedAt: now,
        lastActivityText: 'Task created',
      );
      await _storage.addTask(newTask);
    }

    if (!mounted) return;
    setState(() => _isSaving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(widget.isEditing ? 'Task updated.' : 'Task created.')),
    );
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.isEditing ? 'Edit Task' : 'New Task')),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title *', border: OutlineInputBorder()),
              validator: Validators.title,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _categoryController,
              decoration: const InputDecoration(labelText: 'Category *', border: OutlineInputBorder()),
              validator: (v) => Validators.requiredField(v, fieldName: 'Category'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 3,
              validator: Validators.description,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedAssigneeId,
              decoration: const InputDecoration(labelText: 'Assignee *', border: OutlineInputBorder()),
              items: sampleTeamMembers
                  .map((m) => DropdownMenuItem(value: m.id, child: Text('${m.name} (${m.role})')))
                  .toList(),
              onChanged: (value) => setState(() => _selectedAssigneeId = value),
              validator: Validators.assignee,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<TaskPriority>(
              initialValue: _selectedPriority,
              decoration: const InputDecoration(labelText: 'Priority *', border: OutlineInputBorder()),
              items: TaskPriority.values.map((p) => DropdownMenuItem(value: p, child: Text(p.label))).toList(),
              onChanged: (value) {
                if (value != null) setState(() => _selectedPriority = value);
              },
            ),
            const SizedBox(height: 16),
            if (widget.isEditing) ...[
              DropdownButtonFormField<TaskStatus>(
                initialValue: _selectedStatus,
                decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
                items: TaskStatus.values.map((s) => DropdownMenuItem(value: s, child: Text(s.label))).toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _selectedStatus = value);
                },
              ),
              const SizedBox(height: 16),
            ],
            InkWell(
              onTap: _pickDueDate,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Due Date *',
                  border: const OutlineInputBorder(),
                  errorText: _dueDateTouched ? _dueDateError : null,
                  suffixIcon: const Icon(Icons.calendar_today_outlined),
                ),
                child: Text(_selectedDueDate == null ? 'Select a date' : _formatDate(_selectedDueDate!)),
              ),
            ),
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: _isSaving ? null : _handleSave,
              icon: _isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.save_outlined),
              label: Text(widget.isEditing ? 'Save Changes' : 'Create Task'),
            ),
          ],
        ),
      ),
    );
  }
}