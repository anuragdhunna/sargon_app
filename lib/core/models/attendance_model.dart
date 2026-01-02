import 'package:equatable/equatable.dart';

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
///
/// This model is synced with Firebase Realtime Database.
/// Schema version: 1
class AttendanceRecord extends Equatable {
  final String id;
  final String oderId;
  final String userName;
  final DateTime date;
  final DateTime? checkIn;
  final DateTime? checkOut;
  final AttendanceStatus status;
  final String? notes;
  final String? location; // GPS location if tracked

  // Schema version for migrations
  static const int schemaVersion = 1;

  const AttendanceRecord({
    required this.id,
    required this.oderId,
    required this.userName,
    required this.date,
    this.checkIn,
    this.checkOut,
    required this.status,
    this.notes,
    this.location,
  });

  /// Calculate work hours
  double get workHours {
    if (checkIn == null || checkOut == null) return 0;
    return checkOut!.difference(checkIn!).inMinutes / 60;
  }

  bool get isCheckedIn => checkIn != null;
  bool get isCheckedOut => checkOut != null;

  @override
  List<Object?> get props => [
    id,
    oderId,
    userName,
    date,
    checkIn,
    checkOut,
    status,
    notes,
    location,
  ];

  AttendanceRecord copyWith({
    DateTime? checkIn,
    DateTime? checkOut,
    AttendanceStatus? status,
    String? notes,
    String? location,
  }) {
    return AttendanceRecord(
      id: id,
      oderId: oderId,
      userName: userName,
      date: date,
      checkIn: checkIn ?? this.checkIn,
      checkOut: checkOut ?? this.checkOut,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      location: location ?? this.location,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': oderId,
      'userName': userName,
      'date': date.toIso8601String(),
      'checkIn': checkIn?.toIso8601String(),
      'checkOut': checkOut?.toIso8601String(),
      'status': status.name,
      'notes': notes,
      'location': location,
      '_schemaVersion': schemaVersion,
    };
  }

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      id: json['id'] as String,
      oderId: json['userId'] as String,
      userName: json['userName'] as String,
      date: DateTime.parse(json['date'] as String),
      checkIn: json['checkIn'] != null
          ? DateTime.parse(json['checkIn'] as String)
          : null,
      checkOut: json['checkOut'] != null
          ? DateTime.parse(json['checkOut'] as String)
          : null,
      status: AttendanceStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => AttendanceStatus.absent,
      ),
      notes: json['notes'] as String?,
      location: json['location'] as String?,
    );
  }
}
