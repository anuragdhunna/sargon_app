import 'package:equatable/equatable.dart';

/// Employee performance metrics aggregated from multiple sources
class EmployeePerformance extends Equatable {
  final String userId;
  final String userName;
  final String userRole;
  
  // Attendance Metrics
  final double attendanceRate; // 0.0 to 1.0
  final double punctualityScore; // 0.0 to 1.0
  final int totalDaysPresent;
  final int totalDaysLate;
  final int totalDaysAbsent;
  
  // Task Metrics
  final int tasksCompleted;
  final int tasksAssigned;
  final double taskCompletionRate; // 0.0 to 1.0
  final int crossRoleCompletions;
  
  // Incident Metrics
  final int incidentsReported;
  final int incidentsResolved;
  
  // Overall Score (weighted average)
  final double overallScore; // 0.0 to 100.0

  const EmployeePerformance({
    required this.userId,
    required this.userName,
    required this.userRole,
    required this.attendanceRate,
    required this.punctualityScore,
    required this.totalDaysPresent,
    required this.totalDaysLate,
    required this.totalDaysAbsent,
    required this.tasksCompleted,
    required this.tasksAssigned,
    required this.taskCompletionRate,
    required this.crossRoleCompletions,
    required this.incidentsReported,
    required this.incidentsResolved,
    required this.overallScore,
  });

  @override
  List<Object?> get props => [
        userId,
        userName,
        userRole,
        attendanceRate,
        punctualityScore,
        totalDaysPresent,
        totalDaysLate,
        totalDaysAbsent,
        tasksCompleted,
        tasksAssigned,
        taskCompletionRate,
        crossRoleCompletions,
        incidentsReported,
        incidentsResolved,
        overallScore,
      ];

  /// Get performance grade based on overall score
  String get grade {
    if (overallScore >= 90) return 'A+';
    if (overallScore >= 80) return 'A';
    if (overallScore >= 70) return 'B';
    if (overallScore >= 60) return 'C';
    if (overallScore >= 50) return 'D';
    return 'F';
  }
}
