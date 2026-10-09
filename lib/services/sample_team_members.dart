import '../models/team_member.dart';

final List<TeamMember> sampleTeamMembers = [
  const TeamMember(
    id: 'member_1',
    name: 'Sarah Jenkins',
    role: 'Project Manager',
    email: 'sarah.j@projectflow.io',
    avatarColorHex: '#4F46E5',
  ),
  const TeamMember(
    id: 'member_2',
    name: 'Alex Rivera',
    role: 'UI/UX Designer',
    email: 'alex.r@projectflow.io',
    avatarColorHex: '#06B6D4',
  ),
  const TeamMember(
    id: 'member_3',
    name: 'Marcus Chen',
    role: 'Mobile Developer',
    email: 'marcus.c@projectflow.io',
    avatarColorHex: '#10B981',
  ),
  const TeamMember(
    id: 'member_4',
    name: 'Emily Davis',
    role: 'QA Engineer',
    email: 'emily.d@projectflow.io',
    avatarColorHex: '#F59E0B',
  ),
  const TeamMember(
    id: 'member_5',
    name: 'David Kim',
    role: 'Backend Developer',
    email: 'david.k@projectflow.io',
    avatarColorHex: '#8B5CF6',
  ),
];

void replaceSampleTeamMembers(List<TeamMember> members) {
  sampleTeamMembers
    ..clear()
    ..addAll(members);
}
