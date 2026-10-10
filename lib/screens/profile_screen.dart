import 'package:flutter/material.dart';
import '../models/task_model.dart' as sla_task;
import '../models/task_enums.dart';
import '../models/team_member.dart';
import '../services/local_storage_service.dart';
import '../services/sla_calculator.dart';
import 'statistics_screen.dart';

/// Screen displaying the active team member profile, personal task SLA metrics,
/// user switcher selector, profile edit form, and demo seed data reset button.
class ProfileScreen extends StatefulWidget {
  final LocalStorageService storageService;
  final VoidCallback? onProfileUpdated;

  const ProfileScreen({
    super.key,
    required this.storageService,
    this.onProfileUpdated,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  TeamMember? _activeUser;
  List<TeamMember> _allMembers = [];
  List<sla_task.Task> _userTasks = [];
  bool _isLoading = true;

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
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    setState(() => _isLoading = true);
    final activeUser = await widget.storageService.getCurrentUser();
    final allMembers = await widget.storageService.loadTeamMembers();
    final allTasks = await widget.storageService.loadTasks();

    final userTasks =
        allTasks.where((t) => t.assignedMemberId == activeUser.id).toList();

    if (mounted) {
      setState(() {
        _activeUser = activeUser;
        _allMembers = allMembers;
        _userTasks = userTasks;
        _isLoading = false;
      });
    }
  }

  Color _parseColorHex(String hexString) {
    try {
      final cleanHex = hexString.replaceAll('#', '');
      return Color(int.parse('FF$cleanHex', radix: 16));
    } catch (_) {
      return const Color(0xFF4F46E5);
    }
  }

  Future<void> _switchActiveUser(TeamMember selectedMember) async {
    await widget.storageService.setCurrentUser(selectedMember.id);
    await _loadProfileData();
    if (widget.onProfileUpdated != null) {
      widget.onProfileUpdated!();
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Switched active profile to ${selectedMember.name}'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF4F46E5),
        ),
      );
    }
  }

  Future<void> _resetDemoData() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Demo Data'),
        content: const Text(
          'Are you sure you want to restore all tasks and team members to the initial 8-task SLA demo state? Custom changes will be overwritten.',
        ),
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
            child: const Text('Reset All Data'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await widget.storageService.resetToSeedData();
      await _loadProfileData();
      if (widget.onProfileUpdated != null) {
        widget.onProfileUpdated!();
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Demo data successfully reset!'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Color(0xFF10B981),
          ),
        );
      }
    }
  }

  void _showEditProfileModal() {
    if (_activeUser == null) return;

    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: _activeUser!.name);
    final roleController = TextEditingController(text: _activeUser!.role);
    final emailController = TextEditingController(text: _activeUser!.email);
    String selectedHex = _activeUser!.avatarColorHex;

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
                            'Edit Active Profile',
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
                          prefixIcon: const Icon(Icons.person_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Please enter full name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: roleController,
                        decoration: InputDecoration(
                          labelText: 'Role / Designation',
                          prefixIcon: const Icon(Icons.badge_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Please enter role';
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
                          prefixIcon: const Icon(Icons.email_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Please enter email';
                          }
                          final emailRegex =
                              RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                          if (!emailRegex.hasMatch(val.trim())) {
                            return 'Please enter valid email format';
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
                              final updatedMember = _activeUser!.copyWith(
                                name: nameController.text.trim(),
                                role: roleController.text.trim(),
                                email: emailController.text.trim(),
                                avatarColorHex: selectedHex,
                              );

                              await widget.storageService
                                  .updateTeamMember(updatedMember);
                              if (mounted) {
                                if (ctx.mounted) {
                                  Navigator.pop(ctx);
                                }
                                _loadProfileData();
                                if (widget.onProfileUpdated != null) {
                                  widget.onProfileUpdated!();
                                }
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Profile updated successfully!'),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            }
                          },
                          child: const Text(
                            'Save Profile Changes',
                            style: TextStyle(
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

  void _showUserSwitcherDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Switch Active User'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _allMembers.length,
            itemBuilder: (context, index) {
              final member = _allMembers[index];
              final isSelected = member.id == _activeUser?.id;
              final color = _parseColorHex(member.avatarColorHex);

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: color,
                  child: Text(
                    member.initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  member.name,
                  style: TextStyle(
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                subtitle: Text(member.role),
                trailing: isSelected
                    ? const Icon(Icons.check_circle, color: Color(0xFF4F46E5))
                    : null,
                onTap: () {
                  Navigator.pop(ctx);
                  _switchActiveUser(member);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final active = _activeUser!;
    final avatarColor = _parseColorHex(active.avatarColorHex);

    final summary = SlaCalculator.getSlaSummaryCounts(_userTasks);
    final onTrackCount = summary[SlaStatus.onTrack] ?? 0;
    final atRiskCount = summary[SlaStatus.atRisk] ?? 0;
    final overdueCount = summary[SlaStatus.overdue] ?? 0;
    final completedCount = summary[SlaStatus.completed] ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'User Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // --- ACTIVE MEMBER HEADER CARD ---
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 44,
                      backgroundColor: avatarColor,
                      child: Text(
                        active.initials,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      active.name,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      active.role,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      active.email,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[500],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Active User Chip
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4F46E5).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.verified,
                            size: 16,
                            color: Color(0xFF4F46E5),
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Active App Session User',
                            style: TextStyle(
                              color: Color(0xFF4F46E5),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // --- PERSONAL SLA METRICS CARD ---
            Card(
              elevation: 1.5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'My SLA Task Metrics',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        Text(
                          '${_userTasks.length} Assigned',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildPersonalMetricTile(
                            label: 'On Track',
                            count: onTrackCount,
                            color: const Color(0xFF10B981),
                          ),
                        ),
                        Expanded(
                          child: _buildPersonalMetricTile(
                            label: 'At Risk',
                            count: atRiskCount,
                            color: const Color(0xFFF59E0B),
                          ),
                        ),
                        Expanded(
                          child: _buildPersonalMetricTile(
                            label: 'Overdue',
                            count: overdueCount,
                            color: const Color(0xFFEF4444),
                          ),
                        ),
                        Expanded(
                          child: _buildPersonalMetricTile(
                            label: 'Completed',
                            count: completedCount,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // --- ACTION OPTIONS ---
            Card(
              elevation: 1.5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.edit_outlined,
                        color: Color(0xFF4F46E5)),
                    title: const Text('Edit Profile Details'),
                    subtitle: const Text('Update name, role, email, or avatar'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _showEditProfileModal,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.swap_horiz_outlined,
                        color: Color(0xFF06B6D4)),
                    title: const Text('Switch Active User'),
                    subtitle: const Text('Change the active user session'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _showUserSwitcherDialog,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.analytics_outlined,
                        color: Color(0xFF10B981)),
                    title: const Text('View Full SLA Statistics'),
                    subtitle:
                        const Text('Detailed SLA charts and workload breakdown'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => StatisticsScreen(
                            storageService: widget.storageService,
                          ),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.restore_outlined,
                        color: Color(0xFFEF4444)),
                    title: const Text(
                      'Reset Demo Data',
                      style: TextStyle(color: Color(0xFFEF4444)),
                    ),
                    subtitle: const Text(
                        'Restore default 8 tasks and 5 team members'),
                    trailing: const Icon(Icons.chevron_right,
                        color: Color(0xFFEF4444)),
                    onTap: _resetDemoData,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalMetricTile({
    required String label,
    required int count,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
