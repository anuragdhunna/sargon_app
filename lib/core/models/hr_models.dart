import 'base_entity.dart';

/// Attendance status enum
enum AttendanceStatus { present, absent, late, halfDay, onLeave }

/// Extension for AttendanceStatus
extension AttendanceStatusExtension on AttendanceStatus {
  String get displayName {
    switch (this) {
      case AttendanceStatus.present:
        return 'Present';
      case AttendanceStatus.absent:
        return 'Absent';
      case AttendanceStatus.late:
        return 'Late';
      case AttendanceStatus.halfDay:
        return 'Half Day';
      case AttendanceStatus.onLeave:
        return 'On Leave';
    }
  }
}

/// AttendanceRecord model for daily attendance tracking
class AttendanceRecord extends BaseEntity {
  final String userId;
  final String userName;
  final DateTime date;
  final DateTime? checkIn;
  final DateTime? checkOut;
  final AttendanceStatus status;
  final String? notes;
  final String? location;

  const AttendanceRecord({
    required super.id,
    required super.hotelId,
    required this.userId,
    required this.userName,
    required this.date,
    this.checkIn,
    this.checkOut,
    required this.status,
    this.notes,
    this.location,
    super.createdBy,
    super.createdOn,
    super.updatedBy,
    super.updatedOn,
    super.isDeleted,
  });

  double get workHours {
    if (checkIn == null || checkOut == null) return 0;
    return checkOut!.difference(checkIn!).inMinutes / 60;
  }

  @override
  List<Object?> get props => [
    ...super.props,
    userId,
    userName,
    date,
    checkIn,
    checkOut,
    status,
    notes,
    location,
  ];

  AttendanceRecord copyWith({
    String? id,
    String? hotelId,
    DateTime? checkIn,
    DateTime? checkOut,
    AttendanceStatus? status,
  }) {
    return AttendanceRecord(
      id: id ?? this.id,
      hotelId: hotelId ?? this.hotelId,
      userId: userId,
      userName: userName,
      date: date,
      checkIn: checkIn ?? this.checkIn,
      checkOut: checkOut ?? this.checkOut,
      status: status ?? this.status,
      notes: notes,
      location: location,
      createdBy: createdBy,
      createdOn: createdOn,
      updatedBy: updatedBy,
      updatedOn: updatedOn,
      isDeleted: isDeleted,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toAuditJson(),
      'userId': userId,
      'userName': userName,
      'date': date.toIso8601String(),
      'checkIn': checkIn?.toIso8601String(),
      'checkOut': checkOut?.toIso8601String(),
      'status': status.name,
      'notes': notes,
      'location': location,
    };
  }

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      id: json['id'] as String,
      hotelId: json['hotelId'] as String? ?? 'default',
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      date: BaseEntity.parseDateTime(json['date']) ?? DateTime.now(),
      checkIn: BaseEntity.parseDateTime(json['checkIn']),
      checkOut: BaseEntity.parseDateTime(json['checkOut']),
      status: AttendanceStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => AttendanceStatus.absent,
      ),
      notes: json['notes'] as String?,
      location: json['location'] as String?,
      createdBy: json['createdBy'] as String?,
      createdOn: BaseEntity.parseDateTime(json['createdOn']),
      updatedBy: json['updatedBy'] as String?,
      updatedOn: BaseEntity.parseDateTime(json['updatedOn']),
      isDeleted: json['isDeleted'] ?? false,
    );
  }
}

/// Employee performance metrics
class EmployeePerformance extends BaseEntity {
  final String userId;
  final String userName;
  final String userRole;
  final double attendanceRate;
  final double punctualityScore;
  final int totalDaysPresent;
  final int totalDaysLate;
  final int totalDaysAbsent;
  final int tasksCompleted;
  final int tasksAssigned;
  final double taskCompletionRate;
  final int crossRoleCompletions;
  final int incidentsReported;
  final int incidentsResolved;
  final double overallScore;
  final DateTime periodStart;
  final DateTime periodEnd;

  const EmployeePerformance({
    required super.id,
    required super.hotelId,
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
    required this.periodStart,
    required this.periodEnd,
    super.createdBy,
    super.createdOn,
    super.updatedBy,
    super.updatedOn,
    super.isDeleted,
  });

  String get grade {
    if (overallScore >= 90) return 'A+';
    if (overallScore >= 80) return 'A';
    if (overallScore >= 70) return 'B';
    if (overallScore >= 60) return 'C';
    if (overallScore >= 50) return 'D';
    return 'F';
  }

  @override
  List<Object?> get props => [
    ...super.props,
    userId,
    userName,
    userRole,
    overallScore,
  ];

  EmployeePerformance copyWith({
    String? id,
    String? hotelId,
    double? overallScore,
  }) {
    return EmployeePerformance(
      id: id ?? this.id,
      hotelId: hotelId ?? this.hotelId,
      userId: userId,
      userName: userName,
      userRole: userRole,
      attendanceRate: attendanceRate,
      punctualityScore: punctualityScore,
      totalDaysPresent: totalDaysPresent,
      totalDaysLate: totalDaysLate,
      totalDaysAbsent: totalDaysAbsent,
      tasksCompleted: tasksCompleted,
      tasksAssigned: tasksAssigned,
      taskCompletionRate: taskCompletionRate,
      crossRoleCompletions: crossRoleCompletions,
      incidentsReported: incidentsReported,
      incidentsResolved: incidentsResolved,
      overallScore: overallScore ?? this.overallScore,
      periodStart: periodStart,
      periodEnd: periodEnd,
      createdBy: createdBy,
      createdOn: createdOn,
      updatedBy: updatedBy,
      updatedOn: updatedOn,
      isDeleted: isDeleted,
    );
  }

  @override
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
    };
  }

  factory EmployeePerformance.fromJson(Map<String, dynamic> json) {
    return EmployeePerformance(
      id: json['id'] as String? ?? json['userId'] as String,
      hotelId: json['hotelId'] as String? ?? 'default',
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
