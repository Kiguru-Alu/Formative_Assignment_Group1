import 'package:flutter/material.dart';
import '../models/task_enums.dart';
import '../models/task_model.dart';
import '../models/team_member.dart';
import '../services/local_storage_service.dart';
import '../services/sla_calculator.dart';

/// Screen displaying the team roster, active member task workloads, and member CRUD management.
class TeamMembersScreen extends StatefulWidget {
  final LocalStorageService storageService;
  final VoidCallback? onActiveUserChanged;

  const TeamMembersScreen({
    super.key,
    required this.storageService,
    this.onActiveUserChanged,
  });

  @override
  State<TeamMembersScreen> createState() => _TeamMembersScreenState();
}

class _TeamMembersScreenState extends State<TeamMembersScreen> {
  List<TeamMember> _members = [];
  List<Task> _tasks = [];
  TeamMember? _activeUser;
  String _searchQuery = '';
  bool _isLoading = true;

  final TextEditingController _searchController = TextEditingController();

  // Preset hex color palette for avatar avatars
  final List<String> _avatarColors = [
    '#4F46E5', // Indigo
    '#06B6D4', // Cyan
    '#10B981', // Emerald
    '#F59E0B', // Amber
    '#8B5CF6', // Purple
    '#EC4899', // Pink
    '#EF4444', // Rose
    '#64748B', // Slate
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final members = await widget.storageService.loadTeamMembers();
    final tasks = await widget.storageService.loadTasks();
    final activeUser = await widget.storageService.getCurrentUser();

    if (mounted) {
      setState(() {
        _members = members;
        _tasks = tasks;
        _activeUser = activeUser;
        _isLoading = false;
      });
    }
  }

  List<TeamMember> get _filteredMembers {
    if (_searchQuery.trim().isEmpty) return _members;
    final query = _searchQuery.toLowerCase().trim();
    return _members.where((m) {
      return m.name.toLowerCase().contains(query) ||
          m.role.toLowerCase().contains(query) ||
          m.email.toLowerCase().contains(query);
    }).toList();
  }

  Color _parseColorHex(String hexString) {
    try {
      final cleanHex = hexString.replaceAll('#', '');
      return Color(int.parse('FF$cleanHex', radix: 16));
    } catch (_) {
      return const Color(0xFF4F46E5);
    }
  }

  int _getAssignedTaskCount(String memberId) {
    return _tasks.where((t) => t.assignedMemberId == memberId).length;
  }

  int _getWarningTaskCount(String memberId) {
    return _tasks.where((t) {
      if (t.assignedMemberId != memberId) return false;
      final sla = SlaCalculator.calculateSlaStatus(t);
      return sla == SlaStatus.overdue || sla == SlaStatus.atRisk;
    }).length;
  }

  Future<void> _setActiveUser(TeamMember member) async {
    await widget.storageService.setCurrentUser(member.id);
    await _loadData();
    if (widget.onActiveUserChanged != null) {
      widget.onActiveUserChanged!();
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Active user set to ${member.name}'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF4F46E5),
        ),
      );
    }
  }

  Future<void> _deleteMember(TeamMember member) async {
    final assignedCount = _getAssignedTaskCount(member.id);
    if (assignedCount > 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Cannot delete ${member.name}: $assignedCount ${assignedCount == 1 ? "task is" : "tasks are"} currently assigned to this member.',
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xFFEF4444),
            duration: const Duration(seconds: 4),
          ),
        );
      }
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Team Member'),
        content: Text('Are you sure you want to remove ${member.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await widget.storageService.deleteTeamMember(member.id);
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${member.name} removed from team.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showMemberFormModal([TeamMember? existingMember]) {
    final formKey = GlobalKey<FormState>();
    final nameController =
        TextEditingController(text: existingMember?.name ?? '');
    final roleController =
        TextEditingController(text: existingMember?.role ?? '');
    final emailController =
        TextEditingController(text: existingMember?.email ?? '');
    String selectedHex = existingMember?.avatarColorHex ?? _avatarColors.first;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (bottomSheetContext, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 24,
                bottom: MediaQuery.of(bottomSheetContext).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            existingMember == null
                                ? 'Add Team Member'
                                : 'Edit Team Member',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(ctx),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: 'Full Name',
                          hintText: 'e.g. Sarah Jenkins',
                          prefixIcon: const Icon(Icons.person_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter member name';
                          }
                          if (value.trim().length < 2) {
                            return 'Name must be at least 2 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: roleController,
                        decoration: InputDecoration(
                          labelText: 'Role',
                          hintText: 'e.g. Mobile Developer',
                          prefixIcon: const Icon(Icons.badge_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a role';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Email Address',
                          hintText: 'e.g. sarah.j@projectflow.io',
                          prefixIcon: const Icon(Icons.email_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter email address';
                          }
                          final emailRegex =
                              RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                          if (!emailRegex.hasMatch(value.trim())) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Avatar Color Theme',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: _avatarColors.map((hex) {
                          final isSelected = hex == selectedHex;
                          final color = _parseColorHex(hex);
                          return GestureDetector(
                            onTap: () {
                              setModalState(() => selectedHex = hex);
                            },
                            child: CircleAvatar(
                              radius: 18,
                              backgroundColor: color,
                              child: isSelected
                                  ? const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 18,
                                    )
                                  : null,
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4F46E5),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              final member = TeamMember(
                                id: existingMember?.id ??
                                    'member_${DateTime.now().millisecondsSinceEpoch}',
                                name: nameController.text.trim(),
                                role: roleController.text.trim(),
                                email: emailController.text.trim(),
                                avatarColorHex: selectedHex,
                              );

                              if (existingMember == null) {
                                await widget.storageService.addTeamMember(member);
                              } else {
                                await widget.storageService
                                    .updateTeamMember(member);
                              }

                              if (ctx.mounted) {
                                Navigator.pop(ctx);
                              }

                              if (mounted) {
                                _loadData();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      existingMember == null
                                          ? '${member.name} added to team.'
                                          : '${member.name}\'s profile updated.',
                                    ),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            }
                          },
                          child: Text(
                            existingMember == null
                                ? 'Add Member'
                                : 'Save Changes',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Team Roster',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1_rounded),
            tooltip: 'Add Member',
            onPressed: () => _showMemberFormModal(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  // Search Bar
                  TextField(
                    controller: _searchController,
                    onChanged: (val) {
                      setState(() => _searchQuery = val);
                    },
                    decoration: InputDecoration(
                      hintText: 'Search by name, role, or email...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withValues(alpha: 0.5),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Team Members Count Summary Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Members (${_filteredMembers.length})',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        'Total Tasks: ${_tasks.length}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Members List
                  Expanded(
                    child: _filteredMembers.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.people_outline,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  _searchQuery.isEmpty
                                      ? 'No team members found'
                                      : 'No members matching "$_searchQuery"',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: _filteredMembers.length,
                            itemBuilder: (context, index) {
                              final member = _filteredMembers[index];
                              final isActive = _activeUser?.id == member.id;
                              final avatarColor =
                                  _parseColorHex(member.avatarColorHex);
                              final assignedTasksCount =
                                  _getAssignedTaskCount(member.id);
                              final warningTasksCount =
                                  _getWarningTaskCount(member.id);

                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                elevation: isActive ? 2 : 1,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: isActive
                                      ? const BorderSide(
                                          color: Color(0xFF4F46E5), width: 2)
                                      : BorderSide.none,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Initials Avatar
                                      Stack(
                                        children: [
                                          CircleAvatar(
                                            radius: 26,
                                            backgroundColor: avatarColor,
                                            child: Text(
                                              member.initials,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                              ),
                                            ),
                                          ),
                                          if (isActive)
                                            Positioned(
                                              right: 0,
                                              bottom: 0,
                                              child: Container(
                                                padding: const EdgeInsets.all(2),
                                                decoration: const BoxDecoration(
                                                  color: Color(0xFF10B981),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(
                                                  Icons.check,
                                                  size: 12,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(width: 14),

                                      // Member Details
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    member.name,
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ),
                                                if (isActive)
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 2,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: const Color(
                                                              0xFF4F46E5)
                                                          .withValues(alpha: 0.12),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                    child: const Text(
                                                      'Active User',
                                                      style: TextStyle(
                                                        color: Color(0xFF4F46E5),
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              member.role,
                                              style: TextStyle(
                                                color: Colors.grey[700],
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              member.email,
                                              style: TextStyle(
                                                color: Colors.grey[500],
                                                fontSize: 12,
                                              ),
                                            ),
                                            const SizedBox(height: 10),

                                            // Task Metrics Badges
                                            Row(
                                              children: [
                                                _buildBadge(
                                                  label:
                                                      '$assignedTasksCount ${assignedTasksCount == 1 ? "Task" : "Tasks"}',
                                                  backgroundColor:
                                                      Colors.grey[200]!,
                                                  textColor: Colors.grey[800]!,
                                                  icon: Icons.assignment_outlined,
                                                ),
                                                if (warningTasksCount > 0) ...[
                                                  const SizedBox(width: 8),
                                                  _buildBadge(
                                                    label:
                                                        '$warningTasksCount Warning',
                                                    backgroundColor:
                                                        const Color(0xFFEF4444)
                                                            .withValues(alpha: 0.15),
                                                    textColor:
                                                        const Color(0xFFEF4444),
                                                    icon: Icons
                                                        .warning_amber_rounded,
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Context Popup Menu
                                      PopupMenuButton<String>(
                                        onSelected: (val) {
                                          if (val == 'edit') {
                                            _showMemberFormModal(member);
                                          } else if (val == 'set_active') {
                                            _setActiveUser(member);
                                          } else if (val == 'delete') {
                                            _deleteMember(member);
                                          }
                                        },
                                        itemBuilder: (context) => [
                                          const PopupMenuItem(
                                            value: 'edit',
                                            child: Row(
                                              children: [
                                                Icon(Icons.edit_outlined,
                                                    size: 20),
                                                SizedBox(width: 10),
                                                Text('Edit Profile'),
                                              ],
                                            ),
                                          ),
                                          if (!isActive)
                                            const PopupMenuItem(
                                              value: 'set_active',
                                              child: Row(
                                                children: [
                                                  Icon(
                                                      Icons.person_pin_outlined,
                                                      size: 20),
                                                  SizedBox(width: 10),
                                                  Text('Set as Active User'),
                                                ],
                                              ),
                                            ),
                                          const PopupMenuItem(
                                            value: 'delete',
                                            child: Row(
                                              children: [
                                                Icon(Icons.delete_outline,
                                                    size: 20,
                                                    color: Color(0xFFEF4444)),
                                                SizedBox(width: 10),
                                                Text(
                                                  'Delete Member',
                                                  style: TextStyle(
                                                      color: Color(0xFFEF4444)),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF4F46E5),
        foregroundColor: Colors.white,
        onPressed: () => _showMemberFormModal(),
        icon: const Icon(Icons.add),
        label: const Text('Add Member'),
      ),
    );
  }

  Widget _buildBadge({
    required String label,
    required Color backgroundColor,
    required Color textColor,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
