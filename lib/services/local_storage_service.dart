import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task_enums.dart';
import '../models/task_model.dart';
import '../models/team_member.dart';

/// Local storage service managing application persistence using SharedPreferences
/// and JSON serialization. Handles tasks, team members, active user session, and seed data initialization.
class LocalStorageService {
  static const String _keyTasks = 'sla_tracker_tasks';
  static const String _keyTeamMembers = 'sla_tracker_team_members';
  static const String _keyActiveUserId = 'sla_tracker_active_user_id';

  /// Initializes storage and seeds 5 team members and 8 realistic tasks if empty.
  Future<void> initAndSeedIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final membersJson = prefs.getString(_keyTeamMembers);
    final tasksJson = prefs.getString(_keyTasks);

    if (membersJson == null || tasksJson == null) {
      await resetToSeedData();
    }
  }

  /// Resets storage to standard initial seed data for live demonstrations.
  Future<void> resetToSeedData() async {
    final prefs = await SharedPreferences.getInstance();

    final seedMembers = _generateSeedMembers();
    final seedTasks = _generateSeedTasks();

    final membersString =
        jsonEncode(seedMembers.map((m) => m.toJson()).toList());
    final tasksString =
        jsonEncode(seedTasks.map((t) => t.toJson()).toList());

    await prefs.setString(_keyTeamMembers, membersString);
    await prefs.setString(_keyTasks, tasksString);
    await prefs.setString(_keyActiveUserId, 'member_3'); // Marcus Chen
  }

  // --- TEAM MEMBER CRUD ---

  /// Loads all team members from local storage.
  Future<List<TeamMember>> loadTeamMembers() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_keyTeamMembers);
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    final List<dynamic> decoded = jsonDecode(jsonString);
    return decoded
        .map((item) => TeamMember.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Adds a new team member to storage.
  Future<void> addTeamMember(TeamMember member) async {
    final members = await loadTeamMembers();
    members.add(member);
    await _saveTeamMembers(members);
  }

  /// Updates an existing team member in storage.
  Future<void> updateTeamMember(TeamMember member) async {
    final members = await loadTeamMembers();
    final index = members.indexWhere((m) => m.id == member.id);
    if (index != -1) {
      members[index] = member;
      await _saveTeamMembers(members);
    }
  }

  /// Deletes a team member by ID from storage.
  Future<void> deleteTeamMember(String memberId) async {
    final members = await loadTeamMembers();
    members.removeWhere((m) => m.id == memberId);
    await _saveTeamMembers(members);
  }

  Future<void> _saveTeamMembers(List<TeamMember> members) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString =
        jsonEncode(members.map((m) => m.toJson()).toList());
    await prefs.setString(_keyTeamMembers, jsonString);
  }

  // --- TASK CRUD ---

  /// Loads all tasks from local storage.
  Future<List<Task>> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_keyTasks);
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    final List<dynamic> decoded = jsonDecode(jsonString);
    return decoded
        .map((item) => Task.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Adds a new task to storage.
  Future<void> addTask(Task task) async {
    final tasks = await loadTasks();
    tasks.add(task);
    await _saveTasks(tasks);
  }

  /// Updates an existing task in storage.
  Future<void> updateTask(Task updatedTask) async {
    final tasks = await loadTasks();
    final index = tasks.indexWhere((t) => t.id == updatedTask.id);
    if (index != -1) {
      tasks[index] = updatedTask;
      await _saveTasks(tasks);
    }
  }

  /// Deletes a task by ID from storage.
  Future<void> deleteTask(String taskId) async {
    final tasks = await loadTasks();
    tasks.removeWhere((t) => t.id == taskId);
    await _saveTasks(tasks);
  }

  Future<void> _saveTasks(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(tasks.map((t) => t.toJson()).toList());
    await prefs.setString(_keyTasks, jsonString);
  }

  // --- ACTIVE USER SESSION ---

  /// Fetches the current active team member profile.
  Future<TeamMember> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final activeId = prefs.getString(_keyActiveUserId) ?? 'member_3';
    final members = await loadTeamMembers();

    return members.firstWhere(
      (m) => m.id == activeId,
      orElse: () => members.isNotEmpty
          ? members.first
          : const TeamMember(
              id: 'member_3',
              name: 'Marcus Chen',
              role: 'Mobile Developer',
              email: 'marcus.c@projectflow.io',
              avatarColorHex: '#10B981',
            ),
    );
  }

  /// Updates the current active user ID.
  Future<void> setCurrentUser(String memberId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyActiveUserId, memberId);
  }

  // --- SEED DATA GENERATORS ---

  static List<TeamMember> _generateSeedMembers() {
    return const [
      TeamMember(
        id: 'member_1',
        name: 'Sarah Jenkins',
        role: 'Project Manager',
        email: 'sarah.j@projectflow.io',
        avatarColorHex: '#4F46E5',
      ),
      TeamMember(
        id: 'member_2',
        name: 'Alex Rivera',
        role: 'UI/UX Designer',
        email: 'alex.r@projectflow.io',
        avatarColorHex: '#06B6D4',
      ),
      TeamMember(
        id: 'member_3',
        name: 'Marcus Chen',
        role: 'Mobile Developer',
        email: 'marcus.c@projectflow.io',
        avatarColorHex: '#10B981',
      ),
      TeamMember(
        id: 'member_4',
        name: 'Emily Davis',
        role: 'QA Engineer',
        email: 'emily.d@projectflow.io',
        avatarColorHex: '#F59E0B',
      ),
      TeamMember(
        id: 'member_5',
        name: 'David Kim',
        role: 'Backend Developer',
        email: 'david.k@projectflow.io',
        avatarColorHex: '#8B5CF6',
      ),
    ];
  }

  static List<Task> _generateSeedTasks() {
    final now = DateTime.now();

    return [
      // 1. Completed Task (High Priority)
      Task(
        id: 'task_101',
        title: 'Setup CI/CD Pipeline & GitHub Actions',
        category: 'Backend (Local)',
        description:
            'Configure automated testing and containerized build pipelines for continuous delivery.',
        assignedMemberId: 'member_5',
        createdAt: now.subtract(const Duration(days: 5)),
        dueDate: now.add(const Duration(days: 1)),
        priority: TaskPriority.high,
        status: TaskStatus.completed,
        notes: 'Pipeline verified with 100% build success.',
        updatedAt: now.subtract(const Duration(hours: 3)),
        lastActivityText: 'David Kim completed CI/CD pipeline setup',
      ),

      // 2. Completed Task (Medium Priority)
      Task(
        id: 'task_102',
        title: 'Create User Journey Wireframes',
        category: 'UI/UX Design',
        description:
            'Design low-fidelity wireframes for user onboarding and main dashboard flows.',
        assignedMemberId: 'member_2',
        createdAt: now.subtract(const Duration(days: 6)),
        dueDate: now.subtract(const Duration(days: 1)),
        priority: TaskPriority.medium,
        status: TaskStatus.completed,
        notes: 'Approved by product manager.',
        updatedAt: now.subtract(const Duration(days: 1)),
        lastActivityText: 'Alex Rivera finalized wireframe specs',
      ),

      // 3. Overdue Task (High Priority - Past due date)
      Task(
        id: 'task_103',
        title: 'Implement SharedPreferences Storage Engine',
        category: 'Mobile Development',
        description:
            'Build local data persistence layer for tasks and team members with JSON serialization.',
        assignedMemberId: 'member_3',
        createdAt: now.subtract(const Duration(days: 4)),
        dueDate: now.subtract(const Duration(hours: 14)),
        priority: TaskPriority.high,
        status: TaskStatus.inProgress,
        notes: 'Needs immediate completion for Member 3 handoff.',
        updatedAt: now.subtract(const Duration(hours: 2)),
        lastActivityText: 'Marcus Chen updated task progress to 80%',
      ),

      // 4. Overdue Task (Medium Priority - Past due date)
      Task(
        id: 'task_104',
        title: 'API Authentication Endpoints Audit',
        category: 'Backend (Local)',
        description:
            'Audit local mock authentication tokens and session expiration logic.',
        assignedMemberId: 'member_5',
        createdAt: now.subtract(const Duration(days: 7)),
        dueDate: now.subtract(const Duration(days: 2)),
        priority: TaskPriority.medium,
        status: TaskStatus.toDo,
        notes: 'Blocked pending security review.',
        updatedAt: now.subtract(const Duration(days: 2)),
        lastActivityText: 'David Kim assigned task to Backend team',
      ),

      // 5. At Risk Task (High Priority - 36h remaining <= 72h threshold)
      Task(
        id: 'task_105',
        title: 'Build SLA Calculation Engine & Metrics',
        category: 'Mobile Development',
        description:
            'Implement priority-weighted SLA warning windows, compliance rate formulas, and status explanations.',
        assignedMemberId: 'member_3',
        createdAt: now.subtract(const Duration(days: 2)),
        dueDate: now.add(const Duration(hours: 36)),
        priority: TaskPriority.high,
        status: TaskStatus.inProgress,
        notes: '36 hours remaining before SLA breach.',
        updatedAt: now.subtract(const Duration(hours: 1)),
        lastActivityText: 'Marcus Chen started implementation',
      ),

      // 6. At Risk Task (Medium Priority - 20h remaining <= 48h threshold)
      Task(
        id: 'task_106',
        title: 'Design Material 3 Dark Theme Tokens',
        category: 'UI/UX Design',
        description:
            'Define indigo primary palette and semantic SLA color tokens for Material 3.',
        assignedMemberId: 'member_2',
        createdAt: now.subtract(const Duration(days: 1)),
        dueDate: now.add(const Duration(hours: 20)),
        priority: TaskPriority.medium,
        status: TaskStatus.toDo,
        notes: '20 hours remaining in 48h warning window.',
        updatedAt: now.subtract(const Duration(hours: 5)),
        lastActivityText: 'Alex Rivera drafted color specifications',
      ),

      // 7. On Track Task (High Priority - 120h remaining > 72h threshold)
      Task(
        id: 'task_107',
        title: 'Dashboard Statistics & SLA Charts View',
        category: 'UI/UX Design',
        description:
            'Assemble summary cards and interactive vertical bar charts for executive dashboard.',
        assignedMemberId: 'member_1',
        createdAt: now,
        dueDate: now.add(const Duration(days: 5)),
        priority: TaskPriority.high,
        status: TaskStatus.inProgress,
        notes: 'Progressing on schedule.',
        updatedAt: now,
        lastActivityText: 'Sarah Jenkins updated design layout',
      ),

      // 8. On Track Task (Low Priority - 96h remaining > 24h threshold)
      Task(
        id: 'task_108',
        title: 'Write Automated Widget & Unit Tests',
        category: 'Quality Assurance',
        description:
            'Cover model serialization, SLA calculation rules, and local storage CRUD with unit test suite.',
        assignedMemberId: 'member_4',
        createdAt: now,
        dueDate: now.add(const Duration(days: 4)),
        priority: TaskPriority.low,
        status: TaskStatus.toDo,
        notes: 'Scheduled for QA sprint cycle.',
        updatedAt: now,
        lastActivityText: 'Emily Davis created test plan document',
      ),
    ];
  }
}
