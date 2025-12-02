import 'package:hotel_manager/core/models/audit_log.dart';
import 'package:hotel_manager/core/services/audit_service.dart';
import 'package:hotel_manager/features/attendance/data/attendance_repository.dart';
import 'package:hotel_manager/features/checklists/data/checklist_model.dart';
import 'package:hotel_manager/features/incidents/data/incident_model.dart';
import 'package:hotel_manager/features/performance/data/performance_model.dart';
import 'package:hotel_manager/features/staff_mgmt/data/user_model.dart';

class PerformanceRepository {
  final AttendanceRepository _attendanceRepo;
  final AuditService _auditService;

  PerformanceRepository({
    AttendanceRepository? attendanceRepo,
    AuditService? auditService,
  }) : _attendanceRepo = attendanceRepo ?? AttendanceRepository(),
       _auditService = auditService ?? AuditService();

  /// Calculate comprehensive performance metrics for an employee
  Future<EmployeePerformance> getEmployeePerformance(
    User user,
    List<Checklist> allChecklists,
    List<Incident> allIncidents,
  ) async {
    // Get attendance data for last 30 days
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));

    final attendanceHistory = await _attendanceRepo.getHistory(user.id);

    // Calculate attendance metrics
    int daysPresent = 0;
    int daysLate = 0;
    int daysAbsent = 0;

    for (int i = 0; i < 30; i++) {
      final date = thirtyDaysAgo.add(Duration(days: i));
      final dayStart = DateTime(date.year, date.month, date.day);
      final dayEnd = dayStart.add(const Duration(days: 1));

      final dayRecords = attendanceHistory
          .where(
            (r) =>
                r.timestamp.isAfter(dayStart) && r.timestamp.isBefore(dayEnd),
          )
          .toList();

      if (dayRecords.isEmpty) {
        daysAbsent++;
      } else {
        final checkIn = dayRecords.firstWhere(
          (r) => r.type == AttendanceType.checkIn,
          orElse: () => dayRecords.first,
        );

        if (checkIn.type == AttendanceType.checkIn) {
          final lateThreshold = DateTime(
            checkIn.timestamp.year,
            checkIn.timestamp.month,
            checkIn.timestamp.day,
            9,
            30,
          );

          if (checkIn.timestamp.isAfter(lateThreshold)) {
            daysLate++;
          } else {
            daysPresent++;
          }
        } else {
          daysAbsent++;
        }
      }
    }

    final attendanceRate = (daysPresent + daysLate) / 30;
    final punctualityScore =
        daysPresent / (daysPresent + daysLate + 0.01); // Avoid division by zero

    // Calculate task metrics from audit logs
    final auditLogs = _auditService.getAllLogs();
    final userTaskLogs = auditLogs
        .where(
          (log) =>
              log.userId == user.id &&
              log.entity == 'checklist_item' &&
              log.action == AuditAction.complete,
        )
        .toList();

    final tasksCompleted = userTaskLogs.length;

    // Count cross-role completions (tasks with reason metadata)
    final crossRoleCompletions = userTaskLogs
        .where((log) => log.metadata?['reason'] != null)
        .length;

    // Get tasks assigned to user's role
    final userRoleChecklists = allChecklists
        .where((c) => c.assignedRole.name == user.role.name)
        .toList();

    final tasksAssigned = userRoleChecklists.fold<int>(
      0,
      (sum, checklist) => sum + checklist.items.length,
    );

    final taskCompletionRate = tasksAssigned > 0
        ? tasksCompleted / tasksAssigned
        : 0.0;

    // Calculate incident metrics
    final userIncidents = allIncidents
        .where((i) => i.reportedBy == user.name)
        .toList();

    final incidentsReported = userIncidents.length;
    final incidentsResolved = userIncidents
        .where((i) => i.status == IncidentStatus.resolved)
        .length;

    // Calculate overall score (weighted average)
    // Weights: Attendance 40%, Tasks 30%, Punctuality 20%, Incidents 10%
    final attendanceScore = attendanceRate * 40;
    final taskScore = taskCompletionRate * 30;
    final punctualityScoreWeighted = punctualityScore * 20;
    final incidentScore = (incidentsResolved / (incidentsReported + 0.01)) * 10;

    final overallScore =
        attendanceScore + taskScore + punctualityScoreWeighted + incidentScore;

    return EmployeePerformance(
      userId: user.id,
      userName: user.name,
      userRole: user.role.name,
      attendanceRate: attendanceRate,
      punctualityScore: punctualityScore,
      totalDaysPresent: daysPresent,
      totalDaysLate: daysLate,
      totalDaysAbsent: daysAbsent,
      tasksCompleted: tasksCompleted,
      tasksAssigned: tasksAssigned,
      taskCompletionRate: taskCompletionRate,
      crossRoleCompletions: crossRoleCompletions,
      incidentsReported: incidentsReported,
      incidentsResolved: incidentsResolved,
      overallScore: overallScore,
    );
  }

  /// Get performance data for all employees
  Future<List<EmployeePerformance>> getAllEmployeesPerformance(
    List<User> users,
    List<Checklist> checklists,
    List<Incident> incidents,
  ) async {
    final performances = <EmployeePerformance>[];

    for (final user in users) {
      final performance = await getEmployeePerformance(
        user,
        checklists,
        incidents,
      );
      performances.add(performance);
    }

    // Sort by overall score descending
    performances.sort((a, b) => b.overallScore.compareTo(a.overallScore));

    return performances;
  }
}
