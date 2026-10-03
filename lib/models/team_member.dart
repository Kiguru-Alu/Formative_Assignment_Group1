/// Represents a team member within the Project & SLA Task Tracker application.
class TeamMember {
  final String id;
  final String name;
  final String role;
  final String email;
  final String avatarColorHex;

  const TeamMember({
    required this.id,
    required this.name,
    required this.role,
    required this.email,
    required this.avatarColorHex,
  });

  String get initials {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';

    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts[0][0].toUpperCase();
    } else {
      final firstInitial = parts.first[0].toUpperCase();
      final lastInitial = parts.last[0].toUpperCase();
      return '$firstInitial$lastInitial';
    }
  }

  TeamMember copyWith({
    String? id,
    String? name,
    String? role,
    String? email,
    String? avatarColorHex,
  }) {
    return TeamMember(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      email: email ?? this.email,
      avatarColorHex: avatarColorHex ?? this.avatarColorHex,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'email': email,
      'avatarColorHex': avatarColorHex,
    };
  }

  factory TeamMember.fromJson(Map<String, dynamic> json) {
    return TeamMember(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Unknown Member',
      role: json['role'] as String? ?? 'Team Member',
      email: json['email'] as String? ?? '',
      avatarColorHex: json['avatarColorHex'] as String? ?? '#4F46E5',
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TeamMember &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}