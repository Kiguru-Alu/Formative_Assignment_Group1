import 'package:flutter/material.dart';

import '../app/theme.dart';
import '../models/team_member.dart';

class MemberAvatar extends StatelessWidget {
  final TeamMember? member;
  final double size;

  const MemberAvatar({super.key, required this.member, this.size = 40});

  static Color parseHex(String hex) {
    try {
      return Color(int.parse('FF${hex.replaceAll('#', '')}', radix: 16));
    } catch (_) {
      return AppColors.navy;
    }
  }

  @override
  Widget build(BuildContext context) {
    final m = member;
    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: m == null
              ? Theme.of(context).colorScheme.onSurfaceVariant
              : parseHex(m.avatarColorHex),
        ),
        child: Text(
          m?.initials ?? '?',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: size * 0.38,
          ),
        ),
      ),
    );
  }
}
