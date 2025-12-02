import 'package:equatable/equatable.dart';

/// Model for attendance regularization by managers
class AttendanceRegularization extends Equatable {
  final String id;
  final String attendanceId;
  final String userId;
  final String userName;
  final DateTime date;
  final String reason;
  final String regularizedBy;  // Manager/Admin user ID
  final String regularizedByName;
  final DateTime regularizedAt;

  const AttendanceRegularization({
    required this.id,
    required this.attendanceId,
    required this.userId,
    required this.userName,
    required this.date,
    required this.reason,
    required this.regularizedBy,
    required this.regularizedByName,
    required this.regularizedAt,
  });

  @override
  List<Object?> get props => [
        id,
        attendanceId,
        userId,
        userName,
        date,
        reason,
        regularizedBy,
        regularizedByName,
        regularizedAt,
      ];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'attendanceId': attendanceId,
      'userId': userId,
      'userName': userName,
      'date': date.toIso8601String(),
      'reason': reason,
      'regularizedBy': regularizedBy,
      'regularizedByName': regularizedByName,
      'regularizedAt': regularizedAt.toIso8601String(),
    };
  }
}

enum ReportPeriod { weekly, monthly, halfYearly, yearly }

extension ReportPeriodExtension on ReportPeriod {
  String get displayName {
    switch (this) {
      case ReportPeriod.weekly:
        return 'Weekly';
      case ReportPeriod.monthly:
        return 'Monthly';
      case ReportPeriod.halfYearly:
        return 'Half-Yearly';
      case ReportPeriod.yearly:
        return 'Yearly';
    }
  }
}
