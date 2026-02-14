import 'base_entity.dart';

/// Employee performance metrics aggregated from multiple sources
///
/// This model is synced with Firebase Realtime Database.
/// Schema version: 1
class EmployeePerformance extends BaseEntity {
  final String userId;
  final String userName;
  final String userRole;

  // Attendance Metrics
  final double attendanceRate;
  final double punctualityScore;
  final int totalDaysPresent;
  final int totalDaysLate;
  final int totalDaysAbsent;

  // Task Metrics
  final int tasksCompleted;
  final int tasksAssigned;
  final double taskCompletionRate;
  final int crossRoleCompletions;

  // Incident Metrics
  final int incidentsReported;
  final int incidentsResolved;

  // Overall Score (weighted average)
  final double overallScore;

  // Time period
  final DateTime periodStart;
  final DateTime periodEnd;

  // Schema version for migrations
  static const int schemaVersion = 1;

  EmployeePerformance({
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
    DateTime? periodStart,
    DateTime? periodEnd,
    String? createdBy,
    DateTime? createdOn,
    String? updatedBy,
    DateTime? updatedOn,
    bool isDeleted = false,
  }) : periodStart =
           periodStart ?? DateTime.now().subtract(const Duration(days: 30)),
       periodEnd = periodEnd ?? DateTime.now(),
       super(
         id: userId,
         createdOn: createdOn,
         createdBy: createdBy,
         updatedBy: updatedBy,
         updatedOn: updatedOn,
         isDeleted: isDeleted,
       );

  @override
  List<Object?> get props => [
    ...super.props,
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
    periodStart,
    periodEnd,
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

  Map<String, dynamic> toJson() {
    return {
      ...super.toAuditJson(),
      'userId': userId,
      'userName': userName,
      'userRole': userRole,
      'attendanceRate': attendanceRate,
      'punctualityScore': punctualityScore,
      'totalDaysPresent': totalDaysPresent,
      'totalDaysLate': totalDaysLate,
      'totalDaysAbsent': totalDaysAbsent,
      'tasksCompleted': tasksCompleted,
      'tasksAssigned': tasksAssigned,
      'taskCompletionRate': taskCompletionRate,
      'crossRoleCompletions': crossRoleCompletions,
      'incidentsReported': incidentsReported,
      'incidentsResolved': incidentsResolved,
      'overallScore': overallScore,
      'periodStart': periodStart.toIso8601String(),
      'periodEnd': periodEnd.toIso8601String(),
      '_schemaVersion': schemaVersion,
    };
  }

  factory EmployeePerformance.fromJson(Map<String, dynamic> json) {
    return EmployeePerformance(
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      userRole: json['userRole'] as String,
      attendanceRate: (json['attendanceRate'] as num).toDouble(),
      punctualityScore: (json['punctualityScore'] as num).toDouble(),
      totalDaysPresent: json['totalDaysPresent'] as int,
      totalDaysLate: json['totalDaysLate'] as int,
      totalDaysAbsent: json['totalDaysAbsent'] as int,
      tasksCompleted: json['tasksCompleted'] as int,
      tasksAssigned: json['tasksAssigned'] as int,
      taskCompletionRate: (json['taskCompletionRate'] as num).toDouble(),
      crossRoleCompletions: json['crossRoleCompletions'] as int,
      incidentsReported: json['incidentsReported'] as int,
      incidentsResolved: json['incidentsResolved'] as int,
      overallScore: (json['overallScore'] as num).toDouble(),
      periodStart:
          BaseEntity.parseDateTime(json['periodStart']) ?? DateTime.now(),
      periodEnd: BaseEntity.parseDateTime(json['periodEnd']) ?? DateTime.now(),
      createdBy: json['createdBy'] as String?,
      createdOn: BaseEntity.parseDateTime(json['createdOn']),
      updatedBy: json['updatedBy'] as String?,
      updatedOn: BaseEntity.parseDateTime(json['updatedOn']),
      isDeleted: json['isDeleted'] ?? false,
    );
  }
}
