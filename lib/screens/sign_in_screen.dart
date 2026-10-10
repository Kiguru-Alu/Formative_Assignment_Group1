import 'package:flutter/material.dart';

import '../app/app_shell.dart';
import '../models/team_member.dart';
import '../services/local_storage_service.dart';
import '../widgets/member_avatar.dart';
import '../widgets/theme_toggle_button.dart';

class SignInScreen extends StatefulWidget {
  final LocalStorageService storageService;

  const SignInScreen({super.key, required this.storageService});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  List<TeamMember>? _members;
  String? _selectedId;
  String? _error;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    final members = await widget.storageService.loadTeamMembers();
    if (!mounted) return;
    setState(() => _members = members);
  }

  Future<void> _continue() async {
    final id = _selectedId;
    if (id == null) {
      setState(() => _error = 'Select a profile to continue.');
      return;
    }
    setState(() => _busy = true);
    await widget.storageService.setCurrentUser(id);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => AppShell(storageService: widget.storageService)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final members = _members;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            const Positioned(top: 4, right: 4, child: ThemeToggleButton()),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 36, 20, 16),
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(color: scheme.primaryContainer, shape: BoxShape.circle),
                    child: Icon(Icons.speed, size: 32, color: scheme.primary),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Project & SLA Task Tracker',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text('Know what needs attention, instantly.',
                      style: TextStyle(color: scheme.onSurfaceVariant)),
                  const SizedBox(height: 24),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Select your profile', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: members == null
                        ? const Center(child: CircularProgressIndicator())
                        : members.isEmpty
                            ? Center(
                                child: Text('No team members found.',
                                    style: TextStyle(color: scheme.onSurfaceVariant)),
                              )
                            : ListView(
                                children: [for (final m in members) _memberCard(context, m)],
                              ),
                  ),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, size: 16, color: scheme.error),
                          const SizedBox(width: 4),
                          Text(_error!,
                              style: TextStyle(color: scheme.error, fontWeight: FontWeight.w600, fontSize: 12)),
                        ],
                      ),
                    ),
                  FilledButton.icon(
                    onPressed: _busy ? null : _continue,
                    icon: const Icon(Icons.arrow_forward),
                    iconAlignment: IconAlignment.end,
                    label: const Text('Continue'),
                  ),
                  const SizedBox(height: 12),
                  Text('Data is stored on this device. No account needed.',
                      style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _memberCard(BuildContext context, TeamMember m) {
    final scheme = Theme.of(context).colorScheme;
    final selected = m.id == _selectedId;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Semantics(
        button: true,
        selected: selected,
        label: '${m.name}, ${m.role}',
        excludeSemantics: true,
        child: Material(
          color: selected ? scheme.primaryContainer : scheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: selected ? scheme.primary : scheme.outlineVariant, width: selected ? 2 : 1),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => setState(() {
              _selectedId = m.id;
              _error = null;
            }),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 60),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    MemberAvatar(member: m, size: 40),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(m.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                          Text(m.role, style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
                        ],
                      ),
                    ),
                    Icon(Icons.check_circle, color: selected ? scheme.primary : Colors.transparent),
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
