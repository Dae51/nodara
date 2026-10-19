/// The signed-in student, used across the greeting header and the
/// "Mis Postulaciones" progress dashboard.
class StudentProfile {
  const StudentProfile({
    required this.name,
    required this.avatarUrl,
    required this.level,
    required this.completedHours,
    required this.requiredHours,
    required this.activeProjects,
    required this.accredited,
    required this.career,
  });

  final String name;
  final String avatarUrl;
  final int level;
  final int completedHours;
  final int requiredHours;
  final int activeProjects;
  final int accredited;
  final String career;

  int get remainingHours => requiredHours - completedHours;

  double get progress =>
      requiredHours == 0 ? 0 : (completedHours / requiredHours).clamp(0, 1);

  int get progressPercent => (progress * 100).round();
}
